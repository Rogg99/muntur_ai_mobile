import 'dart:convert';

class Comment {
  late String id;
  late String image;
  late String info;
  late String userName;
  late String userId;
  late String userPhoto;
  late String contenu;
  late bool liked;
  late int likes;
  late int comments;
  late String replyTo;
  late String lineal;
  late String replyUserName;
  late int time;

  Comment({
    this.id='none',
    this.image='none',
    this.info='none',
    this.userId='none',
    this.userName='none',
    this.userPhoto='none',
    this.contenu='none',
    this.replyTo='none',
    this.lineal='none',
    this.replyUserName='none',
    this.liked=false,
    this.likes=0,
    this.comments=0,
    this.time=0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      replyTo: json['replyTo'],
      lineal: json['lineal'],
      replyUserName: json['replyUserName']??'none',
      userPhoto: json['userphoto'],
      userName: json['username'],
      image: json['image'],
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
      'info': info,
      'user': userId,
      'contenu': contenu,
      'image': image,
      'replyTo': replyTo,
      'lineal': lineal,
      'time': time,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

}
