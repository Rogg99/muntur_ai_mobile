import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../models/discussion_model.dart';
import '../models/media_ref.dart';
import '../models/message_model.dart';
import 'package:isar/isar.dart';

/// last_message.emetteur is always a nested Profile object
/// (MessageReadSerializer) — extract its id defensively (falling back to a
/// bare string) so discussion/forum previews can compare it against the
/// current user's own profile id to decide whether to show "Vous: ...".
String _lastMessageSenderId(dynamic lastMessage) {
  if (lastMessage is! Map) return 'none';
  final emetteur = lastMessage['emetteur'];
  if (emetteur is Map) return emetteur['id']?.toString() ?? 'none';
  return emetteur?.toString() ?? 'none';
}

class ChatbotRepositoryImpl {
  final ApiClient _apiClient;

  ChatbotRepositoryImpl(this._apiClient);

  Future<List<DiscussionModel>> getMyDiscussions() async {
    try {
      final response = await _apiClient.get('/discussions/my-discussions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = asResponseList(response.data);
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
            // DiscussionReadSerializer has no top-level "last_writer" field —
            // the actual sender id lives nested in last_message.emetteur
            // (a full Profile object, per MessageReadSerializer).
            last_writer: _lastMessageSenderId(json["last_message"]),
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
        final List<dynamic> data = asResponseList(response.data);
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
            last_writer: _lastMessageSenderId(json['last_message']),
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

  /// Uploads a single local file to the shared media store and returns its
  /// UUID, to be passed as one of [askQuestion]'s [mediaIds]. The filename
  /// (and thus its extension) is what the backend uses to detect content
  /// type, so callers must pass a path with a real extension (.jpg, .m4a…).
  Future<MediaRef?> uploadMedia(File file, {ProgressCallback? onSendProgress}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });
      final response = await _apiClient.postMultipart(
        '/medias/',
        form,
        onSendProgress: onSendProgress,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return MediaRef.fromJson(data);
      }
    } catch (e) {
      // caller keeps the attachment in a failed state and may retry
    }
    return null;
  }

  /// Sends the user's message to the AI chatbot. [mediaIds] are UUIDs
  /// previously returned by [uploadMedia] — [query] may be empty as long as
  /// at least one media id is attached (validated server-side too). The
  /// backend acks with the saved user message only (202,
  /// `ai_response_status: "pending"`) — the AI reply is generated in the
  /// background and delivered later as a `discussion_message` WebSocket
  /// event, not in this response. Returns the real discussion id the message
  /// was filed under (relevant when [discussionId] was null/'auto' and the
  /// backend had to create one).
  Future<({MessageModel message, String discId})?> askQuestion(
      {String query = '',
      String? discussionId,
      List<MediaRef> media = const []}) async {
    final isar = IsarDb.instance;
    final tempMessage = MessageModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      discId: discussionId ?? 'new_disc',
      senderId: 'user', // Replace with actual user ID
      contenu: query,
      media: jsonEncode(media.map((m) => m.toJson()).toList()),
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
        if (media.isNotEmpty) 'media': media.map((m) => m.id).toList(),
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
      // The real endpoint (MessageViewSet.discussion_messages, registered
      // under the "messages/" router) — "/discussions/$discId/messages/"
      // doesn't exist and 404s. Its items are raw MessageSerializer objects
      // with neither "disc_id" nor "date_envoi" (only "date_creation"), so
      // both are filled in/normalized per item before handing off to
      // MessageModel.fromJson.
      final response =
          await _apiClient.get('/messages/discussion/$discId/messages/');
      if (response.statusCode == 200) {
        final body = response.data;
        final items = body is Map ? body['messages']?['items'] : null;
        final messages = (items is List ? items : const [])
            .whereType<Map>()
            .map((json) => MessageModel.fromJson({
                  ...json.cast<String, dynamic>(),
                  'disc_id': discId,
                }))
            .toList();

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
