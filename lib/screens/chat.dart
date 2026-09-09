import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/widgets/widget_message2.dart';

import '../widgets/CustomAppBar.dart';

class ChatView extends ConsumerStatefulWidget {
  final DiscussionModel? disc;

  const ChatView({super.key, this.disc});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  int _lastMessageCount = -1;

  String get _discId => widget.disc?.id ?? 'new';

  String get _userId => ref.read(authStateProvider).valueOrNull?.id ?? 'user';

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

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    _messageController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _sending = true);

    try {
      await ref.read(chatMessagesProvider(_discId).notifier).askQuestion(text);
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
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
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
                    hintText: 'Message ...',
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
