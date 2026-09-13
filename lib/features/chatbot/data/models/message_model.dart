import 'dart:convert';

import 'package:isar/isar.dart';

import 'media_ref.dart';

part 'message_model.g.dart';

@Collection()
class MessageModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = '';

  @Index()
  String discId = '';

  String tempId = 'none';
  String senderId = '';
  String senderName = 'none';
  String senderPhoto = 'none';
  String contenu = '';
  String answerTo = 'none';
  String media = '[]';
  String mediaName = 'none';
  String mediaSize = 'none';
  String announced = 'no';
  String messageState = 'pending';
  bool isAI = false;
  bool pendingSync = false;
  DateTime dateEnvoi = DateTime.now();

  /// JSON-encoded `{id, title, media, link}` map, or 'null' when the backend
  /// found no relevant match (keyword-based, not systematic — see
  /// services/related_article.py server-side).
  String relatedArticle = 'null';

  /// The current user's own feedback on this (AI) message: 'useful' /
  /// 'not_useful' / 'none'. Drives which thumb renders as active.
  String userFeedback = 'none';

  MessageModel();

  static MessageModel create({
    required String id,
    required String discId,
    String tempId = 'none',
    required String senderId,
    String senderName = 'none',
    String senderPhoto = 'none',
    required String contenu,
    String answerTo = 'none',
    String media = '[]',
    String mediaName = 'none',
    String mediaSize = 'none',
    String announced = 'no',
    String messageState = 'pending',
    bool isAI = false,
    bool pendingSync = false,
    required DateTime dateEnvoi,
    String relatedArticle = 'null',
    String userFeedback = 'none',
  }) {
    final m = MessageModel();
    m.id = id;
    m.discId = discId;
    m.tempId = tempId;
    m.senderId = senderId;
    m.senderName = senderName;
    m.senderPhoto = senderPhoto;
    m.contenu = contenu;
    m.answerTo = answerTo;
    m.media = media;
    m.mediaName = mediaName;
    m.mediaSize = mediaSize;
    m.announced = announced;
    m.messageState = messageState;
    m.isAI = isAI;
    m.pendingSync = pendingSync;
    m.dateEnvoi = dateEnvoi;
    m.relatedArticle = relatedArticle;
    m.userFeedback = userFeedback;
    return m;
  }

  /// Normalizes the server's media shape to a JSON-encoded list of
  /// [MediaRef] maps, regardless of which key it arrived under — the 202
  /// echo of the user's own message uses "media", the WS AI-reply push uses
  /// "medias" (same underlying MediaSerializer shape, pre-existing key
  /// mismatch between the two on the backend).
  static String _encodeMedia(Map<String, dynamic> json) {
    final raw = json['medias'] ?? json['media'];
    if (raw is! List) return '[]';
    final refs = raw
        .whereType<Map>()
        .map((m) => MediaRef.fromJson(m.cast<String, dynamic>()).toJson())
        .toList();
    return jsonEncode(refs);
  }

  /// The backend isn't consistent about the shape of "emetteur": the echo of
  /// the user's own message (MessageSerializer) sends a bare profile UUID
  /// string, while WS discussion_message/forum_message pushes and
  /// MessageReadSerializer-backed reads (the AI's replies) send the nested
  /// Profile object. Handle both so a nested emetteur doesn't get assigned
  /// straight into the String senderId field and throw.
  static String _senderId(Map<String, dynamic> json) {
    final emetteur = json['emetteur'];
    if (emetteur is Map) return emetteur['id']?.toString() ?? 'none';
    if (emetteur != null) return emetteur.toString();
    return json['senderId']?.toString() ?? 'none';
  }

  static String _senderName(Map<String, dynamic> json) {
    final emetteur = json['emetteur'];
    if (emetteur is Map) {
      final name = '${emetteur['nom'] ?? ''} ${emetteur['prenom'] ?? ''}'.trim();
      if (name.isNotEmpty) return name;
    }
    return json['emetteurName'] ?? json['senderName'] ?? 'none';
  }

  static String _senderPhoto(Map<String, dynamic> json) {
    final emetteur = json['emetteur'];
    if (emetteur is Map) return emetteur['photo'] ?? 'none';
    return json['emetteurPhoto'] ?? json['senderPhoto'] ?? 'none';
  }

  /// The related-article suggestion arrives as a nested object (or null) —
  /// re-encoded to a string so it fits the same flat Isar schema as the rest
  /// of this model, mirroring _encodeMedia's approach.
  static String _encodeRelatedArticle(Map<String, dynamic> json) {
    final raw = json['related_article'];
    if (raw is! Map) return 'null';
    return jsonEncode(raw);
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel.create(
      id: json['id'] ?? 'auto_${DateTime.now().millisecondsSinceEpoch}',
      // A forum's WS push identifies itself with "forum_id" instead of
      // "disc_id"/"discId" — same underlying field (DiscussionModel.type
      // distinguishes discussion vs. forum), just a different push key.
      discId: json['disc_id'] ?? json['discId'] ?? json['forum_id'] ?? 'none',
      tempId: json['temp_id'] ?? json['tempId'] ?? 'none',
      senderId: _senderId(json),
      senderName: _senderName(json),
      senderPhoto: _senderPhoto(json),
      contenu: json['contenu'] ?? '',
      answerTo: json['answerTo'] ?? 'none',
      media: _encodeMedia(json),
      mediaName: json['mediaName'] ?? 'none',
      mediaSize: json['mediaSize'] ?? 'none',
      announced: json['announced'] ?? 'no',
      messageState: json['state'] ?? 'pending',
      isAI: json['isAI'] ?? false,
      pendingSync: json['pendingSync'] ?? false,
      relatedArticle: _encodeRelatedArticle(json),
      userFeedback: json['user_feedback']?.toString() ?? 'none',
      // The WS discussion_message/forum_message push and the raw
      // MessageSerializer/MessageReadSerializer payloads (fields='__all__')
      // date-stamp as "date_creation" — only the ask-question 202 echo uses
      // "date_envoi"/"dateEnvoi".
      dateEnvoi: DateTime.tryParse(json['date_envoi']?.toString() ?? '') ??
          DateTime.tryParse(json['dateEnvoi']?.toString() ?? '') ??
          DateTime.tryParse(json['date_creation']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  MessageModel copyWith({
    String? id,
    String? discId,
    String? tempId,
    String? senderId,
    String? senderName,
    String? senderPhoto,
    String? contenu,
    String? answerTo,
    String? media,
    String? mediaName,
    String? mediaSize,
    String? announced,
    String? messageState,
    bool? isAI,
    bool? pendingSync,
    DateTime? dateEnvoi,
    String? relatedArticle,
    String? userFeedback,
  }) {
    return MessageModel.create(
      id: id ?? this.id,
      discId: discId ?? this.discId,
      tempId: tempId ?? this.tempId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      contenu: contenu ?? this.contenu,
      answerTo: answerTo ?? this.answerTo,
      media: media ?? this.media,
      mediaName: mediaName ?? this.mediaName,
      mediaSize: mediaSize ?? this.mediaSize,
      announced: announced ?? this.announced,
      messageState: messageState ?? this.messageState,
      isAI: isAI ?? this.isAI,
      pendingSync: pendingSync ?? this.pendingSync,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      relatedArticle: relatedArticle ?? this.relatedArticle,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }
}
