import 'package:isar/isar.dart';

part 'notification_model.g.dart';

@Collection()
class NotificationModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  String title = '';
  String text = '';
  String image = '';
  String url = '';
  bool isRead = false;
  int time = 0;

  NotificationModel();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final m = NotificationModel();
    m.id = json['id']?.toString() ?? '';
    m.title = json['title'] ?? '';
    m.text = json['contenu'] ?? json['text'] ?? '';
    m.image = json['image'] ?? '';
    m.url = json['url'] ?? '';
    m.isRead = json['isRead'] == true || json['statut'] == 'read';
    m.time = (json['time'] as num?)?.toInt() ?? 0;
    return m;
  }
}
