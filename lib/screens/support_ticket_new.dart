import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/support/presentation/providers/support_provider.dart';
import 'package:munturai/screens/support_ticket_thread.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// New support ticket. [sourceDiscussionId] is set when opened via the
/// chat's escalate_human suggested action — the backend snapshots that
/// discussion's context_summary onto the ticket automatically, nothing
/// else to send for that. [initialSubject] pre-fills the subject field in
/// that case ("Escalade depuis le chat") but stays editable.
class SupportTicketNew extends ConsumerStatefulWidget {
  const SupportTicketNew({super.key, this.sourceDiscussionId, this.initialSubject});

  final String? sourceDiscussionId;
  final String? initialSubject;

  @override
  ConsumerState<SupportTicketNew> createState() => _SupportTicketNewState();
}

class _SupportTicketNewState extends ConsumerState<SupportTicketNew> {
  late final _subjectController =
      TextEditingController(text: widget.initialSubject ?? '');
  final _messageController = TextEditingController();
  final List<File> _photos = [];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _photos.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      setState(() => _error = 'Renseignez un sujet et un message.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(supportRepositoryProvider);
      final mediaIds = <String>[];
      for (final file in _photos) {
        final id = await repo.uploadAttachment(file);
        if (id != null) mediaIds.add(id);
      }
      final ticket = await repo.createTicket(
        subject: subject,
        contenu: message,
        mediaIds: mediaIds,
        sourceDiscussionId: widget.sourceDiscussionId,
      );
      ref.invalidate(supportTicketsProvider);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SupportTicketThread(ticketId: ticket.id)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(titleTxt: 'Contacter l\'assistance'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.sourceDiscussionId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Le contexte de votre conversation avec Autosynx sera transmis automatiquement à l'assistance.",
                style: appStyle.H6(color: Colors.grey),
              ),
            ),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Sujet'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final file in _photos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
                ),
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Envoyer',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
