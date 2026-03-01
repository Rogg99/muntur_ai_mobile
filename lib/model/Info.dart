import 'dart:convert';

class Info {
  late String id;
  late String image;
  late String title;
  late String contenu;
  late bool liked;
  late int likes;
  late int comments;
  late String path;
  late String statut;
  late int time;

  Info({
    this.id='none',
    this.image='none',
    this.title='none',
    this.contenu='none',
    this.path='none',
    this.statut='none',
    this.liked=false,
    this.likes=0,
    this.comments=0,
    this.time=0,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'],
      path: json['path'],
      statut: json['statut'],
      image: json['image'],
      title: json['title'],
      contenu: json['contenu'],
      liked: json['liked'],
      likes: json['reactions'],
      comments: json['comments'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contenu': contenu,
      'image': image,
      'path': path,
      'statut': statut,
      'time': time,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

}
