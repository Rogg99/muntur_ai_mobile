import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/forum_details.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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

  bool _sending = false;
  int _lastMessageCount = -1;
  UIMessage? _replyTo;

  String get _discId => widget.disc?.id ?? 'none';

  String get _userId => ref.watch(authStateProvider).valueOrNull?.id ?? 'user';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    if (text.isEmpty || _sending) return;

    final replyId = _replyTo?.id;
    _messageController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sending = true;
      _replyTo = null;
    });

    try {
      await ref.read(chatMessagesProvider(_discId, isForum: true).notifier).sendForumMessage(
            text,
            senderId: _userId,
            answerToId: replyId ?? 'none',
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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
                final canSend = value.text.trim().isNotEmpty && !_sending;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);
    final accent = _senderColor(message.emetteur);
    final bubbleColor =
        isMine ? colorScheme.primary : colorScheme.surfaceContainer;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;

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
