import 'package:isar/isar.dart';

part 'discussion_model.g.dart';

@Collection()
class DiscussionModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  String title = 'New Discussion';
  String initiateur = 'none';
  String interlocuteur = 'none';
  String last_message = 'none';
  String last_date = '1970-01-01 00:00';
  String last_writer = 'none';
  String photo = 'none';

  @Index()
  String type = 'none';

  int last_check = 0;
  int unreadCount = 0;
  bool pendingSync = false;

  DiscussionModel();

  static DiscussionModel create({
    required String id,
    String title = 'New Discussion',
    String initiateur = 'none',
    String interlocuteur = 'none',
    String last_message = 'none',
    String last_date = '1970-01-01 00:00',
    String last_writer = 'none',
    String photo = 'none',
    String type = 'none',
    int last_check = 0,
    int unreadCount = 0,
    bool pendingSync = false,
  }) {
    final m = DiscussionModel();
    m.id = id;
    m.title = title;
    m.initiateur = initiateur;
    m.interlocuteur = interlocuteur;
    m.last_message = last_message;
    m.last_date = last_date;
    m.last_writer = last_writer;
    m.photo = photo;
    m.type = type;
    m.last_check = last_check;
    m.unreadCount = unreadCount;
    m.pendingSync = pendingSync;
    return m;
  }

  DiscussionModel copyWith({
    String? id,
    String? title,
    String? initiateur,
    String? interlocuteur,
    String? last_message,
    String? last_date,
    String? last_writer,
    String? photo,
    String? type,
    int? last_check,
    int? unreadCount,
    bool? pendingSync,
  }) {
    return DiscussionModel.create(
      id: id ?? this.id,
      title: title ?? this.title,
      initiateur: initiateur ?? this.initiateur,
      interlocuteur: interlocuteur ?? this.interlocuteur,
      last_message: last_message ?? this.last_message,
      last_date: last_date ?? this.last_date,
      last_writer: last_writer ?? this.last_writer,
      photo: photo ?? this.photo,
      type: type ?? this.type,
      last_check: last_check ?? this.last_check,
      unreadCount: unreadCount ?? this.unreadCount,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
