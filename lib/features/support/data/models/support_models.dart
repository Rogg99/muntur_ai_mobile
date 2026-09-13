/// Mirrors api/apps/api/serializers.py's SupportTicketReadSerializer exactly
/// (fields='__all__' on SupportTicket, nested messages via
/// MessageReadSerializer — same Message model discussions/forums use, so
/// most of its fields are irrelevant here and simply ignored).
library;

class SupportMediaItem {
  final String id;
  final String file;
  final String kind;

  const SupportMediaItem({required this.id, required this.file, this.kind = 'unknown'});

  factory SupportMediaItem.fromJson(Map<String, dynamic> json) => SupportMediaItem(
        id: json['id']?.toString() ?? '',
        file: json['file']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'unknown',
      );
}

class SupportTicketMessage {
  final String id;
  final String contenu;
  final String emetteurId;
  final String emetteurName;
  final List<SupportMediaItem> medias;
  final String dateCreation;

  const SupportTicketMessage({
    required this.id,
    this.contenu = '',
    this.emetteurId = '',
    this.emetteurName = '',
    this.medias = const [],
    this.dateCreation = '',
  });

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    final emetteur = json['emetteur'];
    String emetteurId = '';
    String emetteurName = '';
    if (emetteur is Map) {
      emetteurId = emetteur['id']?.toString() ?? '';
      emetteurName = '${emetteur['nom'] ?? ''} ${emetteur['prenom'] ?? ''}'.trim();
    } else if (emetteur != null) {
      emetteurId = emetteur.toString();
    }
    return SupportTicketMessage(
      id: json['id']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      emetteurId: emetteurId,
      emetteurName: emetteurName,
      medias: (json['medias'] as List? ?? [])
          .whereType<Map>()
          .map((e) => SupportMediaItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
      dateCreation: json['date_creation']?.toString() ?? '',
    );
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String status; // open | in_progress | resolved | closed
  final String contextSummary;
  final String? sourceDiscussion;
  final List<SupportTicketMessage> messages;
  final String dateCreation;

  const SupportTicket({
    required this.id,
    this.subject = '',
    this.status = 'open',
    this.contextSummary = '',
    this.sourceDiscussion,
    this.messages = const [],
    this.dateCreation = '',
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        status: json['status']?.toString() ?? 'open',
        contextSummary: json['context_summary']?.toString() ?? '',
        sourceDiscussion: json['source_discussion']?.toString(),
        messages: (json['messages'] as List? ?? [])
            .whereType<Map>()
            .map((e) => SupportTicketMessage.fromJson(e.cast<String, dynamic>()))
            .toList(),
        dateCreation: json['date_creation']?.toString() ?? '',
      );
}
