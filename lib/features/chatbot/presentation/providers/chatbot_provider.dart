import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'dart:convert';
import '../../data/models/discussion_model.dart';
import '../../data/models/media_ref.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories_impl/chatbot_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import 'package:isar/isar.dart';

part 'chatbot_provider.g.dart';

@riverpod
ChatbotRepositoryImpl chatbotRepository(Ref ref) {
  final apiClient = ApiClient();
  return ChatbotRepositoryImpl(apiClient);
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
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  FutureOr<List<MessageModel>> build(String discussionId) async {
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

  void _refreshFromApi(String discussionId) async {
    try {
      final fresh = await ref
          .read(chatbotRepositoryProvider)
          .getMessagesForDiscussion(discussionId);
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

    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: 'user',
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
  Future<void> sendForumMessage(String content,
      {String senderId = 'user',
      String senderName = '',
      String answerToId = 'none'}) async {
    if (content.trim().isEmpty) return;

    final isar = IsarDb.instance;
    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: senderId,
      senderName: senderName,
      contenu: content,
      answerTo: answerToId,
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
}
