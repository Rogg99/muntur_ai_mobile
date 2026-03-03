import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../data/models/discussion_model.dart';
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

  /// Sends a user message to the AI chatbot.
  /// Uses optimistic UI update via Isar, then sends to API.
  Future<void> askQuestion(String query) async {
    if (query.trim().isEmpty) return;

    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: 'user',
      contenu: query,
      dateEnvoi: DateTime.now(),
      pendingSync: true,
    );

    // Optimistic UI update
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, tempMsg]);

    try {
      final aiResponse = await ref.read(chatbotRepositoryProvider).askQuestion(
            query: query,
            discussionId: discussionId != 'new' ? discussionId : null,
          );

      if (aiResponse != null) {
        final updatedList = (state.value ?? [])
            .map((m) => m.id == tempMsg.id ? m.copyWith(pendingSync: false) : m)
            .toList();
        state = AsyncValue.data([...updatedList, aiResponse]);
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
