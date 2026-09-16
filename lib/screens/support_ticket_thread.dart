import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/support/data/models/support_models.dart';
import 'package:munturai/features/support/presentation/providers/support_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations t) => {
  'open': t.support_status_open,
  'in_progress': t.support_status_in_progress,
  'resolved': t.support_status_resolved,
  'closed': t.support_status_closed,
};

/// One ticket's thread — chat-style bubbles (mine vs. support staff),
/// composer with an optional photo attach. Staff replies land here via the
/// support_ticket_message WS event (see realtime_dispatcher.dart), which
/// just invalidates this provider — the push payload is minimal (no
/// media/date), so a light refetch is simpler than trying to merge it in.
class SupportTicketThread extends ConsumerStatefulWidget {
  const SupportTicketThread({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<SupportTicketThread> createState() => _SupportTicketThreadState();
}

class _SupportTicketThreadState extends ConsumerState<SupportTicketThread> {
  final _messageController = TextEditingController();
  File? _photo;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _photo = File(picked.path));
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _photo == null) return;
    setState(() => _sending = true);
    try {
      final repo = ref.read(supportRepositoryProvider);
      final mediaIds = <String>[];
      if (_photo != null) {
        final id = await repo.uploadAttachment(_photo!);
        if (id != null) mediaIds.add(id);
      }
      await repo.replyToTicket(
        ticketId: widget.ticketId,
        contenu: text,
        mediaIds: mediaIds,
      );
      _messageController.clear();
      setState(() => _photo = null);
      ref.invalidate(supportTicketDetailProvider(widget.ticketId));
      ref.invalidate(supportTicketsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.support_send_failed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ticketAsync = ref.watch(supportTicketDetailProvider(widget.ticketId));
    final myId = ref.watch(authStateProvider).valueOrNull?.id ?? '';

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        titleTxt: ticketAsync.valueOrNull?.subject ?? translator.support_ticket_default_title,
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(translator.support_load_ticket_error, style: appStyle.H5())),
        data: (ticket) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _statusLabels(translator)[ticket.status] ?? ticket.status,
                  style: appStyle.H6(color: colorScheme.primary, weight: 'bold'),
                ),
              ),
            ),
            Expanded(
              child: ticket.messages.isEmpty
                  ? Center(child: Text(translator.support_no_messages, style: appStyle.H5()))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: ticket.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final message = ticket.messages[index];
                        return _TicketMessageBubble(
                          message: message,
                          mine: message.emetteurId == myId,
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_photo != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_photo!, width: 56, height: 56, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () => setState(() => _photo = null),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.black87, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
                          onPressed: _sending ? null : _pickPhoto,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: appStyle.H5(),
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: translator.support_message_hint,
                              filled: true,
                              fillColor: colorScheme.surfaceContainer,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: _sending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: colorScheme.primary))
                              : Icon(Icons.send, color: colorScheme.primary),
                          onPressed: _sending ? null : _send,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketMessageBubble extends StatelessWidget {
  const _TicketMessageBubble({required this.message, required this.mine});

  final SupportTicketMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = mine ? colorScheme.primary : colorScheme.surfaceContainer;
    final textColor = mine ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(AppLocalizations.of(context)!.support_staff_label,
                      style: appStyle.H6(weight: 'bold', color: colorScheme.primary)),
                ),
              for (final media in message.medias) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(ApiClient.resolveMediaUrl(media.file),
                      width: 180, height: 180, fit: BoxFit.cover),
                ),
                if (message.contenu.isNotEmpty) const SizedBox(height: 6),
              ],
              if (message.contenu.isNotEmpty)
                Text(message.contenu, style: appStyle.H5(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
