import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:munturai/screens/forum_details.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

enum _AttachSheetChoice { camera, gallery }

enum _AttachmentStatus { uploading, uploaded, failed }

enum _AttachmentKind { image, video }

/// A picked photo or video, tracked from the moment it's picked through
/// upload — uploading starts immediately (not at send time) so the composer
/// can show real progress instead of blocking the whole send on a big file.
class _PendingAttachment {
  _PendingAttachment({required this.file, required this.kind});

  final File file;
  final _AttachmentKind kind;
  _AttachmentStatus status = _AttachmentStatus.uploading;
  double progress = 0;
  MediaRef? mediaRef;
}

/// Telegram-style name colors, picked deterministically per sender id so the
/// same person always reads in the same color across the whole group —
/// that per-sender identity is the whole point of a group chat and is
/// exactly what the 1:1 AI screen has no use for.
const List<Color> _senderPalette = [
  Color(0xFFE17076),
  Color(0xFFEDA86C),
  Color(0xFFA695E7),
  Color(0xFF7BC862),
  Color(0xFF6EC9CB),
  Color(0xFF65AADD),
  Color(0xFFE586C0),
  Color(0xFFD29D57),
];

Color _senderColor(String id) =>
    _senderPalette[id.hashCode.abs() % _senderPalette.length];

class ForumChatView extends ConsumerStatefulWidget {
  final DiscussionModel? disc;
  const ForumChatView({super.key, this.disc});

  @override
  ConsumerState<ForumChatView> createState() => _ForumChatViewState();
}

class _ForumChatViewState extends ConsumerState<ForumChatView> {
  final TextEditingController _messageController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _sending = false;
  int _lastMessageCount = -1;
  UIMessage? _replyTo;
  final List<_PendingAttachment> _attachments = [];

  String get _discId => widget.disc?.id ?? 'none';

  String get _userId => ref.watch(authStateProvider).valueOrNull?.id ?? 'user';

  bool get _hasBlockingAttachment => _attachments.any((a) =>
      a.status == _AttachmentStatus.uploading ||
      a.status == _AttachmentStatus.failed);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static const _videoExtensions = {'mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'};

  Future<void> _showAttachSheet() async {
    final choice = await showModalBottomSheet<_AttachSheetChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(sheetContext, _AttachSheetChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(sheetContext, _AttachSheetChoice.gallery),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    if (choice == _AttachSheetChoice.camera) {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;
      _addAttachment(_PendingAttachment(
        file: File(photo.path),
        kind: _AttachmentKind.image,
      ));
      return;
    }

    // pickMedia lets the user pick either a photo or a video from the same
    // gallery picker — the kind is only known afterward, from the file
    // extension, since the API returns a plain XFile either way.
    final picked = await _imagePicker.pickMedia();
    if (picked == null) return;
    final extension = picked.path.split('.').last.toLowerCase();
    final kind =
        _videoExtensions.contains(extension) ? _AttachmentKind.video : _AttachmentKind.image;
    _addAttachment(_PendingAttachment(file: File(picked.path), kind: kind));
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

  int _indexOfMessage(List<UIMessage> messages, String id) =>
      messages.indexWhere((m) => m.id == id);

  Future<void> _scrollToMessage(List<UIMessage> messages, String id) async {
    final index = _indexOfMessage(messages, id);
    if (index == -1) return;
    await _scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _startReply(UIMessage message) {
    setState(() => _replyTo = message);
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

    final replyId = _replyTo?.id;
    _messageController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sending = true;
      _replyTo = null;
      _attachments.clear();
    });

    try {
      await ref.read(chatMessagesProvider(_discId, isForum: true).notifier).sendForumMessage(
            text,
            senderId: _userId,
            answerToId: replyId ?? 'none',
            media: uploaded,
          );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(chatMessagesProvider(_discId, isForum: true));

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
      appBar: _GroupAppBar(disc: widget.disc),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList(context, messagesState, messages)),
            if (_replyTo != null) _buildReplyPreview(context),
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
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(chatMessagesProvider(_discId, isForum: true)),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Aucun message. Sois le premier à écrire dans ce groupe !',
                    textAlign: TextAlign.center,
                    style: AppStyle.of(context)
                        .H4(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(chatMessagesProvider(_discId, isForum: true)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.emetteur == _userId;
            final prev = index > 0 ? messages[index - 1] : null;
            final next = index < messages.length - 1 ? messages[index + 1] : null;
            final isFirstOfRun = prev == null || prev.emetteur != message.emetteur;
            final isLastOfRun = next == null || next.emetteur != message.emetteur;

            UIMessage? repliedTo;
            if (message.answerTo != 'none') {
              final idx = _indexOfMessage(messages, message.answerTo);
              if (idx != -1) repliedTo = messages[idx];
            }

            return AutoScrollTag(
              key: ValueKey(message.id),
              controller: _scrollController,
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: isLastOfRun ? 10 : 2),
                child: _GroupMessageBubble(
                  message: message,
                  isMine: isMine,
                  showHeader: !isMine && isFirstOfRun,
                  reserveAvatarSpace: !isMine,
                  repliedTo: repliedTo,
                  onReply: () => _startReply(message),
                  onTapReply: repliedTo != null
                      ? () => _scrollToMessage(messages, repliedTo!.id)
                      : null,
                ),
              ),
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
              'Impossible de charger le groupe',
              textAlign: TextAlign.center,
              style: appStyle.H5(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(chatMessagesProvider(_discId, isForum: true)),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    final reply = _replyTo!;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _senderColor(reply.emetteur);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.emetteur == _userId ? 'Toi' : reply.emetteurName,
                  style: AppStyle.of(context).H6(color: accent, weight: 'bold'),
                ),
                Text(
                  reply.contenu,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.of(context).H6(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _replyTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
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
                  onPressed: _showAttachSheet,
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppStyle.of(context).H5(),
                      decoration: InputDecoration(
                        hintText: 'Message au groupe...',
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
                : Icon(Icons.videocam, color: colorScheme.primary),
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

/// Group-chat appbar — an avatar and a static "Groupe" line instead of the
/// plain title bar the 1:1 AI screen uses, so this reads as a different
/// place the moment it opens.
class _GroupAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final DiscussionModel? disc;
  const _GroupAppBar({required this.disc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final title = disc?.title ?? 'Groupe';
    final initial = title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?';
    final photo = disc?.photo ?? 'none';
    final detailAsync =
        disc != null ? ref.watch(forumDetailProvider(disc!.id)) : null;
    final membersCount = detailAsync?.valueOrNull?.membersCount;
    final subtitle = membersCount != null
        ? '$membersCount membre${membersCount > 1 ? 's' : ''}'
        : 'Groupe';

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: InkWell(
        onTap: disc == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ForumDetailsScreen(forum: disc!)),
                ),
        child: Row(
          children: [
            SizedBox(
              height: 38,
              width: 38,
              child: photo.startsWith('http')
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _GroupAvatarFallback(initial: initial),
                        errorWidget: (_, __, ___) =>
                            _GroupAvatarFallback(initial: initial),
                      ),
                    )
                  : _GroupAvatarFallback(initial: initial),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: appStyle.H4(weight: 'bold'),
                  ),
                  Text(
                    subtitle,
                    style: appStyle.H6(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GroupAvatarFallback extends StatelessWidget {
  final String initial;
  const _GroupAvatarFallback({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ConstantsProvider.getColorFromLetter(context, initial),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppStyle.of(context).H5(weight: 'bold', color: Colors.white),
      ),
    );
  }
}

/// A single group message: avatar + colored sender name (Telegram
/// convention — the sender's identity, not the bubble, carries the color),
/// an optional quoted-reply block, and the message text.
class _GroupMessageBubble extends StatelessWidget {
  final UIMessage message;
  final bool isMine;
  final bool showHeader;
  final bool reserveAvatarSpace;
  final UIMessage? repliedTo;
  final VoidCallback onReply;
  final VoidCallback? onTapReply;

  const _GroupMessageBubble({
    required this.message,
    required this.isMine,
    required this.showHeader,
    required this.reserveAvatarSpace,
    required this.repliedTo,
    required this.onReply,
    required this.onTapReply,
  });

  List<Map<String, dynamic>> _mediaItems() {
    try {
      final decoded = jsonDecode(message.media);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);
    final accent = _senderColor(message.emetteur);
    final bubbleColor =
        isMine ? colorScheme.primary : colorScheme.surfaceContainer;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;
    final mediaItems = _mediaItems();
    final hasText = message.contenu.trim().isNotEmpty;

    final avatarInitial = message.emetteurName.isNotEmpty
        ? message.emetteurName.substring(0, 1).toUpperCase()
        : '?';

    Widget avatar = SizedBox(
      width: 30,
      height: 30,
      child: message.emetteurPhoto.startsWith('http')
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: message.emetteurPhoto,
                fit: BoxFit.cover,
                placeholder: (_, __) => _GroupAvatarFallback(initial: avatarInitial),
                errorWidget: (_, __, ___) =>
                    _GroupAvatarFallback(initial: avatarInitial),
              ),
            )
          : _GroupAvatarFallback(initial: avatarInitial),
    );

    return Row(
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (reserveAvatarSpace) ...[
          SizedBox(width: 30, height: 30, child: showHeader ? avatar : null),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: GestureDetector(
              onLongPress: onReply,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message.emetteurName,
                          style: appStyle.H6(color: accent, weight: 'bold'),
                        ),
                      ),
                    for (final item in mediaItems) ...[
                      _GroupMediaAttachment(
                        url: item['file']?.toString() ?? '',
                        kind: item['kind']?.toString() ?? 'unknown',
                        foreground: textColor,
                      ),
                      if (hasText || repliedTo != null) const SizedBox(height: 6),
                    ],
                    if (repliedTo != null)
                      GestureDetector(
                        onTap: onTapReply,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                  color: _senderColor(repliedTo!.emetteur),
                                  width: 3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                repliedTo!.emetteurName,
                                style: appStyle.H6(
                                  color: _senderColor(repliedTo!.emetteur),
                                  weight: 'bold',
                                ),
                              ),
                              Text(
                                repliedTo!.contenu,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: appStyle.H6(color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasText)
                      Text(
                        message.contenu,
                        style: appStyle.H5(color: textColor),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dispatches a single media item to the renderer matching its `kind`.
class _GroupMediaAttachment extends StatelessWidget {
  final String url;
  final String kind;
  final Color foreground;

  const _GroupMediaAttachment({
    required this.url,
    required this.kind,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    switch (kind) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final total = progress.expectedTotalBytes;
              return SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: total != null
                        ? progress.cumulativeBytesLoaded / total
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              width: 220,
              height: 220,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      case 'video':
        return _GroupVideoAttachment(url: url);
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file, size: 18, color: foreground),
            const SizedBox(width: 4),
            Text(kind, style: TextStyle(color: foreground, fontSize: 12)),
          ],
        );
    }
  }
}

/// An inline video player — tap the play overlay to start/pause. Owns its
/// own controller so playback state never forces a rebuild of the
/// surrounding message list.
class _GroupVideoAttachment extends StatefulWidget {
  final String url;
  const _GroupVideoAttachment({required this.url});

  @override
  State<_GroupVideoAttachment> createState() => _GroupVideoAttachmentState();
}

class _GroupVideoAttachmentState extends State<_GroupVideoAttachment> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 220,
        height: 220,
        child: !_ready
            ? Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : GestureDetector(
                onTap: () => setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                }),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => _controller.value.isPlaying
                          ? const SizedBox()
                          : const Icon(Icons.play_circle_fill,
                              size: 56, color: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
