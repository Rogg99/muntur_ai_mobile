import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'dart:convert';
import '../../data/models/discussion_model.dart';
import '../../data/models/forum_detail.dart';
import '../../data/models/media_ref.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories_impl/chatbot_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:isar/isar.dart';

part 'chatbot_provider.g.dart';

@riverpod
ChatbotRepositoryImpl chatbotRepository(Ref ref) {
  final apiClient = ApiClient();
  return ChatbotRepositoryImpl(apiClient);
}

@riverpod
Future<ForumDetail?> forumDetail(Ref ref, String forumId) {
  return ref.read(chatbotRepositoryProvider).getForumDetail(forumId);
}

/// Patches the preview fields of the discussion/forum matching [discId] and
/// moves it to the front (most-recent-first), instead of a full re-fetch —
/// used to apply a WS push's own message data directly. Returns null if
/// [discId] isn't in [current] yet (e.g. a brand-new discussion the list
/// hasn't been told about), so the caller can fall back to a real refresh.
List<DiscussionModel>? _applyIncomingPreview(
  List<DiscussionModel> current, {
  required String discId,
  required String contenu,
  required String lastWriter,
  required DateTime dateEnvoi,
}) {
  final index = current.indexWhere((d) => d.id == discId);
  if (index == -1) return null;
  final updated = [...current];
  final disc = updated.removeAt(index);
  updated.insert(
    0,
    disc.copyWith(
      last_message: contenu,
      last_date: dateEnvoi.toIso8601String(),
      last_writer: lastWriter,
    ),
  );
  return updated;
}

@riverpod
class Discussions extends _$Discussions {
  @override
  FutureOr<List<DiscussionModel>> build() async {
    // Online-first: try API, fallback to Isar
    try {
      return await ref.read(chatbotRepositoryProvider).getMyDiscussions();
    } catch (_) {
      final isar = IsarDb.instance;
      return await isar.discussionModels
          .filter()
          .typeEqualTo('discussion')
          .findAll();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(chatbotRepositoryProvider).getMyDiscussions();
    });
  }

  /// Applies a `discussion_message` WS push's preview directly — see
  /// [RealtimeDispatcher]. Falls back to [refresh] only if this discussion
  /// isn't cached yet.
  void applyIncomingMessage({
    required String discId,
    required String contenu,
    required String lastWriter,
    required DateTime dateEnvoi,
  }) {
    final current = state.value;
    if (current == null) return;
    final updated = _applyIncomingPreview(current,
        discId: discId, contenu: contenu, lastWriter: lastWriter, dateEnvoi: dateEnvoi);
    if (updated == null) {
      refresh();
      return;
    }
    state = AsyncValue.data(updated);
  }
}

@riverpod
class Forums extends _$Forums {
  @override
  FutureOr<List<DiscussionModel>> build() async {
    try {
      return await ref.read(chatbotRepositoryProvider).getForums();
    } catch (_) {
      final isar = IsarDb.instance;
      return await isar.discussionModels
          .filter()
          .typeEqualTo('forum')
          .findAll();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(chatbotRepositoryProvider).getForums();
    });
  }

  /// Applies a `forum_message` WS push's preview directly — see
  /// [RealtimeDispatcher]. Falls back to [refresh] only if this forum isn't
  /// cached yet.
  void applyIncomingMessage({
    required String forumId,
    required String contenu,
    required String lastWriter,
    required DateTime dateEnvoi,
  }) {
    final current = state.value;
    if (current == null) return;
    final updated = _applyIncomingPreview(current,
        discId: forumId, contenu: contenu, lastWriter: lastWriter, dateEnvoi: dateEnvoi);
    if (updated == null) {
      refresh();
      return;
    }
    state = AsyncValue.data(updated);
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  FutureOr<List<MessageModel>> build(String discussionId,
      {bool isForum = false}) async {
    // 'new' is a local-only placeholder for a discussion that doesn't exist
    // on the backend yet (it's created on the first message) — nothing to
    // load or refresh until then.
    if (discussionId == 'new') return [];

    // 1. Load from Isar immediately (offline-first)
    final isar = IsarDb.instance;
    final localMessages = await isar.messageModels
        .filter()
        .discIdEqualTo(discussionId)
        .sortByDateEnvoi()
        .findAll();

    // 2. Try to refresh from API in background
    _refreshFromApi(discussionId);

    return localMessages;
  }

  /// Applies a message pushed over the WebSocket (AI reply, another party's
  /// forum message, ...) directly into Isar + state — no REST re-fetch. Used
  /// by [RealtimeDispatcher] in place of invalidating this provider, which
  /// would otherwise hit a GET-messages endpoint on every single message a
  /// WS push delivers while this discussion/forum is open.
  Future<void> applyIncoming(MessageModel message) async {
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.messageModels.put(message);
    });
    final current = state.value ?? [];
    final updated = [
      for (final m in current)
        if (m.id != message.id) m,
      message,
    ]..sort((a, b) => a.dateEnvoi.compareTo(b.dateEnvoi));
    state = AsyncValue.data(updated);
  }

  void _refreshFromApi(String discussionId) async {
    try {
      final repo = ref.read(chatbotRepositoryProvider);
      final fresh = isForum
          ? await repo.getMessagesForForum(discussionId)
          : await repo.getMessagesForDiscussion(discussionId);
      if (fresh.isNotEmpty) {
        state = AsyncValue.data(fresh);
      }
    } catch (_) {
      // silently fail — Isar data already shown
    }
  }

  /// Sends a user message to the AI chatbot. The AI's reply is NOT returned
  /// here anymore — the backend acks the user's message and generates the
  /// reply in the background, delivering it as a `discussion_message` WS
  /// event (see RealtimeDispatcher), which invalidates this provider and
  /// refetches the thread once the reply lands.
  Future<void> askQuestion(String query, {List<MediaRef> media = const []}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty && media.isEmpty) return;

    // Was hardcoded to the literal string 'user' — since rendering decides
    // which side a bubble goes on by comparing this against the real
    // logged-in user's id, that made every message sent through here look
    // like it came from the bot instead of the sender.
    final myId = ref.read(authStateProvider).valueOrNull?.id ?? 'user';

    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: myId,
      contenu: trimmed,
      media: jsonEncode(media.map((m) => m.toJson()).toList()),
      dateEnvoi: DateTime.now(),
      pendingSync: true,
    );

    // Optimistic UI update
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, tempMsg]);

    try {
      final result = await ref.read(chatbotRepositoryProvider).askQuestion(
            query: trimmed,
            discussionId: discussionId != 'new' ? discussionId : null,
            media: media,
            senderId: myId,
          );

      if (result != null) {
        final updatedList = (state.value ?? [])
            .map((m) => m.id == tempMsg.id ? result.message : m)
            .toList();
        state = AsyncValue.data(updatedList);

        // A brand-new AI discussion got a real id from the backend — refresh
        // the discussion list so it shows up. Note: this screen instance
        // stays keyed on 'new', so the AI reply (delivered via WS against the
        // real id) won't appear here until the user reopens the discussion
        // by its real id.
        if (discussionId == 'new' && result.discId != 'new') {
          ref.invalidate(discussionsProvider);
        }
      }
    } catch (e) {
      // Message stays as pendingSync=true — SyncService will retry
    }
  }

  /// Sends a message to a forum discussion (no AI response expected).
  /// [content] may be empty as long as at least one media ref is attached.
  Future<void> sendForumMessage(String content,
      {String senderId = 'user',
      String senderName = '',
      String answerToId = 'none',
      List<MediaRef> media = const []}) async {
    if (content.trim().isEmpty && media.isEmpty) return;

    final isar = IsarDb.instance;
    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: senderId,
      senderName: senderName,
      contenu: content,
      answerTo: answerToId,
      media: jsonEncode(media.map((m) => m.toJson()).toList()),
      dateEnvoi: DateTime.now(),
      pendingSync: true,
    );

    // Save to Isar immediately (optimistic)
    await isar.writeTxn(() async {
      await isar.messageModels.put(tempMsg);
    });

    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, tempMsg]);

    try {
      final response =
          await ref.read(chatbotRepositoryProvider).sendForumMessage(
                discId: discussionId,
                content: content,
                answerTo: answerToId,
                media: media,
              );
      if (response != null) {
        await isar.writeTxn(() async {
          // Remove temp and insert real
          final tempInDb = await isar.messageModels
              .filter()
              .idEqualTo(tempMsg.id)
              .findFirst();
          if (tempInDb != null) {
            await isar.messageModels.delete(tempInDb.isarId);
          }
          await isar.messageModels.put(response);
        });
        final updatedList = (state.value ?? [])
            .where((m) => m.id != tempMsg.id)
            .toList()
          ..add(response);
        updatedList.sort((a, b) => a.dateEnvoi.compareTo(b.dateEnvoi));
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      // stays pending — SyncService will retry
    }
  }

  /// Optimistically flips the thumb, then confirms with the backend —
  /// reverts on failure so the UI never shows feedback that wasn't recorded.
  Future<void> setMessageFeedback(String messageId, bool useful) async {
    final current = state.value ?? [];
    final index = current.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    final previous = current[index];
    final optimistic = previous.copyWith(
      userFeedback: useful ? 'useful' : 'not_useful',
    );
    state = AsyncValue.data([
      for (final m in current) if (m.id == messageId) optimistic else m,
    ]);

    final ok = await ref
        .read(chatbotRepositoryProvider)
        .sendMessageFeedback(messageId, useful);

    if (ok) {
      final isar = IsarDb.instance;
      await isar.writeTxn(() async {
        await isar.messageModels.put(optimistic);
      });
    } else {
      final reverted = state.value ?? [];
      state = AsyncValue.data([
        for (final m in reverted) if (m.id == messageId) previous else m,
      ]);
    }
  }
}
