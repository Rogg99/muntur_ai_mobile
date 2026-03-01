import 'dart:convert';

class Notification {
  late String id;
  late String image;
  late String title;
  late String text;
  late String url;
  late String isRead;
  late int time;

  Notification({
    this.id='none',
    this.image='none',
    this.title='none',
    this.text='none',
    this.url='',
    this.isRead='no',
    this.time=0,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      url: json['url']??'',
      text: json['contenu'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contenu': text,
      'image': image,
      'statut': isRead,
      'time': time,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

}
