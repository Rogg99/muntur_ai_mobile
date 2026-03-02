import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../data/models/discussion_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories_impl/chatbot_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

part 'chatbot_provider.g.dart';

@riverpod
ChatbotRepositoryImpl chatbotRepository(ChatbotRepositoryRef ref) {
  final apiClient = ApiClient(); // Should ideally use a core provider
  return ChatbotRepositoryImpl(apiClient);
}

@riverpod
class Discussions extends _$Discussions {
  @override
  FutureOr<List<DiscussionModel>> build() async {
    return ref.read(chatbotRepositoryProvider).getMyDiscussions();
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
    return ref.read(chatbotRepositoryProvider).getForums();
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
    final isar = IsarDb.instance;
    return await isar.messageModels
        .filter()
        .discIdEqualTo(discussionId)
        .findAll();
  }

  Future<void> askQuestion(String query) async {
    // Optimistic UI update:
    final tempMsg = MessageModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      discId: discussionId,
      senderId: 'user',
      contenu: query,
      dateEnvoi: DateTime.now(),
      pendingSync: true,
    );

    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, tempMsg]);

    try {
      final aiResponse = await ref.read(chatbotRepositoryProvider).askQuestion(
            query: query,
            discussionId: discussionId != 'new' ? discussionId : null,
          );

      if (aiResponse != null) {
        // Replace temp msg with real sent status (fake updating for now), and add AI response
        final updatedList = state.value!
            .map((m) => m.id == tempMsg.id ? m.copyWith(pendingSync: false) : m)
            .toList();
        state = AsyncValue.data([...updatedList, aiResponse]);
      }
    } catch (e) {
      // Keep it pending, sync service will handle it
    }
  }
}
