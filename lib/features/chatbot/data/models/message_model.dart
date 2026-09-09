import 'dart:convert';

import 'package:isar/isar.dart';

import 'media_ref.dart';

part 'message_model.g.dart';

@Collection()
class MessageModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel.create(
      id: json['id'] ?? 'auto_${DateTime.now().millisecondsSinceEpoch}',
      discId: json['disc_id'] ?? json['discId'] ?? 'none',
      tempId: json['temp_id'] ?? json['tempId'] ?? 'none',
      senderId: json['emetteur'] ?? json['senderId'] ?? 'none',
      senderName: json['emetteurName'] ?? json['senderName'] ?? 'none',
      senderPhoto: json['emetteurPhoto'] ?? json['senderPhoto'] ?? 'none',
      contenu: json['contenu'] ?? '',
      answerTo: json['answerTo'] ?? 'none',
      media: _encodeMedia(json),
      mediaName: json['mediaName'] ?? 'none',
      mediaSize: json['mediaSize'] ?? 'none',
      announced: json['announced'] ?? 'no',
      messageState: json['state'] ?? 'pending',
      isAI: json['isAI'] ?? false,
      pendingSync: json['pendingSync'] ?? false,
      dateEnvoi: json['date_envoi'] != null
          ? DateTime.tryParse(json['date_envoi']) ?? DateTime.now()
          : (json['dateEnvoi'] != null
              ? DateTime.tryParse(json['dateEnvoi']) ?? DateTime.now()
              : DateTime.now()),
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
    );
  }
}
