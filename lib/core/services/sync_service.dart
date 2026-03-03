import 'package:isar/isar.dart';
import '../../features/chatbot/data/models/message_model.dart';
import '../../features/chatbot/data/repositories_impl/chatbot_repository_impl.dart';
import '../../core/database/isar_db.dart';
import '../../core/network/api_client.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _repository = ChatbotRepositoryImpl(ApiClient());

  /// Syncs all pending messages (pendingSync == true) to the backend.
  /// Called at app startup and when connectivity is restored.
  Future<void> syncPendingData() async {
    final isar = IsarDb.instance;

    final pendingMessages =
        await isar.messageModels.filter().pendingSyncEqualTo(true).findAll();

    for (final message in pendingMessages) {
      try {
        // Determine if this is a forum message (discId contains 'forum')
        // or an AI chat message based on the discussion context.
        // For now, re-send as AI messages (discussions).
        final aiResponse = await _repository.askQuestion(
          query: message.contenu,
          discussionId: message.discId != 'new' ? message.discId : null,
        );

        if (aiResponse != null) {
          // Mark the pending message as synced
          await isar.writeTxn(() async {
            final synced = message.copyWith(pendingSync: false);
            await isar.messageModels.put(synced);
          });
        }
      } catch (e) {
        // Continue — will retry on next launch
      }
    }
  }
}
