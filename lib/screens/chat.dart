import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/data/models/media_ref.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/widgets/widget_message2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../widgets/CustomAppBar.dart';

enum _AttachSheetChoice { camera, gallery }

enum _AttachmentStatus { uploading, uploaded, failed }

enum _AttachmentKind { image, audio }

/// One picked photo or recorded voice note, tracked client-side from the
/// moment it's picked/recorded through upload — uploading starts immediately
/// (not at send time) so the composer can show real progress instead of
/// blocking the whole send on a big file.
class _PendingAttachment {
  _PendingAttachment({
    required this.file,
    required this.kind,
    this.duration,
  });

  final File file;
  final _AttachmentKind kind;
  final Duration? duration;
  _AttachmentStatus status = _AttachmentStatus.uploading;
  double progress = 0;
  MediaRef? mediaRef;
}

class ChatView extends ConsumerStatefulWidget {
  final DiscussionModel? disc;

  const ChatView({super.key, this.disc});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _sending = false;
  int _lastMessageCount = -1;

  final List<_PendingAttachment> _attachments = [];
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTicker;

  String get _discId => widget.disc?.id ?? 'new';

  // Must be ref.watch, not ref.read: authStateProvider is a plain (autoDispose)
  // provider, so a bare read() drops it the moment this call returns and the
  // next access rebuilds it from scratch — re-fetching the profile and
  // re-running its WS-connect side effect on every message row. Watching
  // keeps one subscription alive for the screen's lifetime instead.
  String get _userId => ref.watch(authStateProvider).valueOrNull?.id ?? 'user';

  bool get _hasBlockingAttachment => _attachments.any((a) =>
      a.status == _AttachmentStatus.uploading ||
      a.status == _AttachmentStatus.failed);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordTicker?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _showAttachSheet() async {
    final choice = await showModalBottomSheet<_AttachSheetChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(sheetContext, _AttachSheetChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir une photo'),
              onTap: () => Navigator.pop(sheetContext, _AttachSheetChoice.gallery),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final photo = await _imagePicker.pickImage(
      source: choice == _AttachSheetChoice.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo == null) return;
    _addAttachment(_PendingAttachment(
      file: File(photo.path),
      kind: _AttachmentKind.image,
    ));
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _recordTicker?.cancel();
      final seconds = _recordSeconds;
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      if (path != null) {
        _addAttachment(_PendingAttachment(
          file: File(path),
          kind: _AttachmentKind.audio,
          duration: Duration(seconds: seconds),
        ));
      }
      return;
    }

    if (!await _audioRecorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(), path: path);
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordSeconds++);
    });
  }

  void _addAttachment(_PendingAttachment attachment) {
    setState(() => _attachments.add(attachment));
    _uploadAttachment(attachment);
  }

  void _removeAttachment(_PendingAttachment attachment) {
    setState(() => _attachments.remove(attachment));
  }

  Future<void> _uploadAttachment(_PendingAttachment attachment) async {
    attachment.status = _AttachmentStatus.uploading;
    attachment.progress = 0;
    if (mounted) setState(() {});

    final mediaRef = await ref.read(chatbotRepositoryProvider).uploadMedia(
      attachment.file,
      onSendProgress: (sent, total) {
        if (total <= 0 || !mounted) return;
        setState(() => attachment.progress = sent / total);
      },
    );

    if (!mounted) return;
    setState(() {
      attachment.mediaRef = mediaRef;
      attachment.status =
          mediaRef != null ? _AttachmentStatus.uploaded : _AttachmentStatus.failed;
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    final uploaded = _attachments
        .where((a) => a.status == _AttachmentStatus.uploaded)
        .map((a) => a.mediaRef!)
        .toList();
    if ((text.isEmpty && uploaded.isEmpty) || _sending || _hasBlockingAttachment) {
      return;
    }

    _messageController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sending = true;
      _attachments.clear();
    });

    try {
      await ref
          .read(chatMessagesProvider(_discId).notifier)
          .askQuestion(text, media: uploaded);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final translator = AppLocalizations.of(context)!;
    final messagesState = ref.watch(chatMessagesProvider(_discId));

    List<UIMessage> messages = [];
    if (messagesState is AsyncData) {
      messages = (messagesState.value ?? [])
          .map((m) => UIMessage(
                id: m.id,
                disc_id: m.discId,
                temp_id: m.tempId,
                emetteur: m.senderId,
                emetteurName: m.senderName,
                emetteurPhoto: m.senderPhoto,
                contenu: m.contenu,
                answerTo: m.answerTo,
                media: m.media,
                mediaName: m.mediaName,
                mediaSize: m.mediaSize,
                announced: m.announced,
                state: m.messageState,
                date_envoi: m.dateEnvoi.toIso8601String(),
              ))
          .toList()
        ..sort((a, b) =>
            DateTime.parse(a.date_envoi).compareTo(DateTime.parse(b.date_envoi)));
    }

    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom(animate: false));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        titleTxt: widget.disc?.title ?? translator.newDiscussion,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(context, messagesState, messages),
            ),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    AsyncValue<Object?> messagesState,
    List<UIMessage> messages,
  ) {
    if (messagesState is AsyncLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState is AsyncError && messages.isEmpty) {
      return _buildError(context);
    }

    if (messages.isEmpty) {
      return Center(child: MessageWidget2(message: UIMessage(), head: true));
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(chatMessagesProvider(_discId)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: messages.length + (_sending ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            if (index == messages.length) return const _TypingBubble();
            final message = messages[index];
            return MessageWidget2(
              message: message,
              sender: message.emetteur == _userId,
              head: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger la conversation',
              textAlign: TextAlign.center,
              style: appStyle.H5(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(chatMessagesProvider(_discId)),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
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
            if (_attachments.isNotEmpty) _buildAttachmentsRow(colorScheme),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                  onPressed: _isRecording ? null : _showAttachSheet,
                ),
                Expanded(
                  child: _isRecording
                      ? _buildRecordingIndicator(colorScheme)
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 120),
                          child: TextField(
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppStyle.of(context).H5(),
                            decoration: InputDecoration(
                              hintText: 'Message ...',
                              filled: true,
                              fillColor: colorScheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                ),
                const SizedBox(width: 4),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, _) {
                    final hasUploaded = _attachments
                        .any((a) => a.status == _AttachmentStatus.uploaded);
                    final canSend = (value.text.trim().isNotEmpty || hasUploaded) &&
                        !_sending &&
                        !_hasBlockingAttachment;
                    if (_isRecording) {
                      return IconButton(
                        icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
                        onPressed: _toggleRecording,
                      );
                    }
                    if (!_sending &&
                        value.text.trim().isEmpty &&
                        _attachments.isEmpty) {
                      return IconButton(
                        icon: Icon(Icons.mic_none_rounded, color: colorScheme.primary),
                        onPressed: _toggleRecording,
                      );
                    }
                    return IconButton(
                      icon: _sending
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          : Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              color: canSend
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(alpha: 0.3),
                              size: 32,
                            ),
                      onPressed: canSend ? _handleSend : null,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator(ColorScheme colorScheme) {
    final minutes = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordSeconds % 60).toString().padLeft(2, '0');
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: AppStyle.of(context).H5()),
        ],
      ),
    );
  }

  Widget _buildAttachmentsRow(ColorScheme colorScheme) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        itemCount: _attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return _AttachmentChip(
            attachment: attachment,
            colorScheme: colorScheme,
            onRemove: () => _removeAttachment(attachment),
            onRetry: () => _uploadAttachment(attachment),
          );
        },
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.colorScheme,
    required this.onRemove,
    required this.onRetry,
  });

  final _PendingAttachment attachment;
  final ColorScheme colorScheme;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.kind == _AttachmentKind.image;
    return GestureDetector(
      onTap: attachment.status == _AttachmentStatus.failed ? onRetry : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.surfaceContainer,
            ),
            child: isImage
                ? Image.file(attachment.file, fit: BoxFit.cover)
                : Icon(Icons.mic, color: colorScheme.primary),
          ),
          if (attachment.status == _AttachmentStatus.uploading)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    value: attachment.progress > 0 ? attachment.progress : null,
                  ),
                ),
              ),
            ),
          if (attachment.status == _AttachmentStatus.failed)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value - i * 0.2) % 1.0;
                final opacity =
                    0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: opacity,
                    child: const CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.white,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
