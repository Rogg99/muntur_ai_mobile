import 'package:isar/isar.dart';

part 'news_model.g.dart';

@Collection()
class NewsModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id = '';

  String title = '';
  String image = '';
  String contenu = '';
  String path = '';
  String statut = 'none';
  int time = 0;
  int likes = 0;
  int comments = 0;
  bool liked = false;
  bool stale = false;

  NewsModel();

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final m = NewsModel();
    m.id = json['id']?.toString() ?? '';
    m.title = json['title'] ?? '';
    m.image = json['image'] ?? '';
    m.contenu = json['contenu'] ?? '';
    m.path = json['path'] ?? '';
    m.statut = json['statut'] ?? 'none';
    m.time = (json['time'] as num?)?.toInt() ?? 0;
    m.likes = (json['reactions'] ?? json['likes'] as num?)?.toInt() ?? 0;
    m.comments = (json['comments'] as num?)?.toInt() ?? 0;
    m.liked = json['liked'] == true;
    return m;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'image': image,
        'contenu': contenu,
        'path': path,
        'statut': statut,
        'time': time,
        'likes': likes,
        'comments': comments,
        'liked': liked,
      };
}
