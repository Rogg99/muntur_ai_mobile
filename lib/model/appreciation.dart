import 'dart:convert';
import 'package:munturai/model/user.dart';

class Like {
  int id;
  String user;
  String cible;
  String appreciation; //LIKE, DISLIKE, SUPER_LIKE

  Like({
    this.id = 1,
    this.user = "none",
    this.cible = "none",
    this.appreciation = "LIKE",
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
        id : json["id"],
        user : json["user"],
        cible : json["cible"],
        appreciation : json["appreciation"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'user' : user,
      'cible' : cible,
      'appreciation' : appreciation,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

  }

class UnreciprocatedLike {
  int id;
  String userId;
  String userPhoto;
  String userName;
  String userAge;
  String appreciation; //LIKE, DISLIKE, SUPER_LIKE

  UnreciprocatedLike({
    this.id = 1,
    this.userId = "none",
    this.userPhoto = "none",
    this.userName = "none",
    this.userAge = "none",
    this.appreciation = "LIKE",
  });

  factory UnreciprocatedLike.fromJson(Map<String, dynamic> json) {
    return UnreciprocatedLike(
      id : json["id"],
      userName : json["user"]["prenom"],
      userPhoto : json["user"]["photo_de_profil"],
      userAge : json["user"]["age"],
      userId : json["user"]["id"],
      appreciation : json["appreciation"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'userName' : userName,
      'userPhoto' : userPhoto,
      'userAge' : userAge,
      'userId' : userId,
      'appreciation' : appreciation,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

}

class Match {
  int id;
  String userId;
  String userPhoto;
  String userName;
  String userAge;

  Match({
    this.id = 1,
    this.userId = "none",
    this.userPhoto = "none",
    this.userName = "none",
    this.userAge = "none",
  });

  factory Match.fromJson(Map<String, dynamic> json,User user) {
    if (user.id == json["like1"]["id"]) {
      return Match(
        id : json["id"],
        userName : json["like2"]["prenom"],
        userPhoto : json["like2"]["photo_de_profil"],
        userAge : json["like2"]["age"],
        userId : json["like2"]["id"],
      );
    } else {
      return Match(
        id : json["id"],
        userName : json["like1"]["prenom"],
        userPhoto : json["like1"]["photo_de_profil"],
        userAge : json["like1"]["age"],
        userId : json["like1"]["id"],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'userName' : userName,
      'userPhoto' : userPhoto,
      'userAge' : userAge,
      'userId' : userId,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

}
