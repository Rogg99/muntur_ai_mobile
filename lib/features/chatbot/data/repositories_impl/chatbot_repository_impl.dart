import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../models/discussion_model.dart';
import '../models/message_model.dart';
import 'package:isar/isar.dart';

class ChatbotRepositoryImpl {
  final ApiClient _apiClient;

  ChatbotRepositoryImpl(this._apiClient);

  Future<List<DiscussionModel>> getMyDiscussions() async {
    try {
      final response = await _apiClient.get('/discussions/my-discussions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final discussions = data.map((json) {
          return DiscussionModel.create(
            id: json["id"],
            title: json["title"] ?? json["titre"] ?? 'New Discussion',
            initiateur: json["initiateur"] ?? 'none',
            interlocuteur: json["interlocuteur"] ?? 'none',
            last_message: json["last_message"] is String
                ? json["last_message"]
                : (json["last_message"] != null
                    ? json["last_message"]["contenu"]
                    : 'none'),
            last_date: json["last_date"] ??
                (json["last_message"] != null
                    ? json["last_message"]["date_creation"]
                    : '1970-01-01'),
            last_writer: json["last_writer"] ?? 'none',
            photo: json["photo"] ?? 'none',
            type: json["type"] ?? 'discussion',
          );
        }).toList();

        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.discussionModels.putAll(discussions);
        });

        return discussions;
      }
    } catch (e) {
      // Fallback to local DB
      final isar = IsarDb.instance;
      return await isar.discussionModels
          .filter()
          .typeEqualTo('discussion')
          .findAll();
    }
    return [];
  }

  Future<List<DiscussionModel>> getForums() async {
    try {
      final response = await _apiClient.get('/forums/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final forums = data.map((json) {
          return DiscussionModel.create(
            id: json["id"],
            title: json['titre'] ?? 'Forum',
            last_message: json['last_message'] != null
                ? json['last_message']['contenu'] ?? 'none'
                : 'none',
            last_date: json['last_message'] != null
                ? (json['last_message']['date_creation'] as String)
                    .substring(0, 10)
                : '1970-01-01',
            last_writer: json['last_message'] != null &&
                    json['last_message']['emetteur'] != null
                ? json['last_message']['emetteur']['nom'] ?? 'none'
                : 'none',
            photo: json['photo'] ?? 'none',
            type: "forum",
          );
        }).toList();

        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.discussionModels.putAll(forums);
        });

        return forums;
      }
    } catch (e) {
      final isar = IsarDb.instance;
      return await isar.discussionModels
          .filter()
          .typeEqualTo('forum')
          .findAll();
    }
    return [];
  }

  /// Sends the user's message to the AI chatbot. The backend acks with the
  /// saved user message only (202, `ai_response_status: "pending"`) — the AI
  /// reply is generated in the background and delivered later as a
  /// `discussion_message` WebSocket event, not in this response. Returns the
  /// real discussion id the message was filed under (relevant when
  /// [discussionId] was null/'auto' and the backend had to create one).
  Future<({MessageModel message, String discId})?> askQuestion(
      {required String query, String? discussionId}) async {
    final isar = IsarDb.instance;
    final tempMessage = MessageModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      discId: discussionId ?? 'new_disc',
      senderId: 'user', // Replace with actual user ID
      contenu: query,
      dateEnvoi: DateTime.now(),
      pendingSync: true,
    );

    await isar.writeTxn(() async {
      await isar.messageModels.put(tempMessage);
    });

    try {
      final response = await _apiClient.post('/ask-question', data: {
        'contenu': query,
        'discussion': discussionId ?? 'auto',
      });

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data['data'];
        final discId = data['disc_id'].toString();
        final confirmedMessage = tempMessage.copyWith(
          id: data['id']?.toString() ?? tempMessage.id,
          discId: discId,
          pendingSync: false,
        );

        await isar.writeTxn(() async {
          final tempInDb = await isar.messageModels
              .filter()
              .idEqualTo(tempMessage.id)
              .findFirst();
          if (tempInDb != null) {
            await isar.messageModels.delete(tempInDb.isarId);
          }
          await isar.messageModels.put(confirmedMessage);
        });

        return (message: confirmedMessage, discId: discId);
      }
    } catch (e) {
      // Leave tempMessage as pending_sync for Background SyncService
    }
    return null;
  }

  Future<MessageModel?> sendForumMessage({
    required String discId,
    required String content,
    String answerTo = 'none',
  }) async {
    try {
      final response =
          await _apiClient.post('/forums/$discId/messages/', data: {
        'contenu': content,
        if (answerTo != 'none') 'answer_to': answerTo,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg =
            MessageModel.fromJson(response.data['data'] ?? response.data);
        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.messageModels.put(msg);
        });
        return msg;
      }
    } catch (e) {
      // offline — keep pending
    }
    return null;
  }

  Future<List<MessageModel>> getMessagesForDiscussion(String discId) async {
    try {
      final response = await _apiClient.get('/discussions/$discId/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final messages =
            data.map((json) => MessageModel.fromJson(json)).toList();

        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.messageModels.putAll(messages);
        });

        return messages;
      }
    } catch (e) {
      // fallback to local
    }
    final isar = IsarDb.instance;
    return await isar.messageModels
        .filter()
        .discIdEqualTo(discId)
        .sortByDateEnvoi()
        .findAll();
  }
}
