import 'dart:convert';

class Discussion {
  String id;
  String initiateur;
  String interlocuteur;
  String last_message;
  String last_date;
  String last_writer;
  String title;
  String photo;
  String type;
  String silence;
  int last_check;

  Discussion({
    this.id = "auto",
    this.initiateur = "none",
    this.interlocuteur = "none",
    this.last_message = "none",
    this.last_date = "1970-01-01 00:00",
    this.last_writer = "none",
    this.title = "New Discussion",
    this.photo = "none",
    this.silence = "yes",
    this.type = "none",
    this.last_check=0
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
        id : json["id"],
        initiateur : json["initiateur"],
        interlocuteur : json["interlocuteur"],
        last_message : json["last_message"],
        last_date : json["last_date"],
        last_writer : json["last_writer"],
        title : json["title"],
        photo : json["photo"],
        type : json["type"]
    );
  }
  bool equals(Discussion disc){
    if(this.id==disc.id && this.last_message==disc.last_message && this.last_date==disc.last_date && this.last_writer==disc.last_writer)
    return true;
    else return false;
  }
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'initiateur' : initiateur,
      'interlocuteur' : interlocuteur,
      'last_message' : last_message,
      'last_date' : last_date,
      'last_writer' : last_writer,
      'title' : title,
      'photo' : photo,
      'type' : type,
      'last_check' : last_check
    };
  }
  String toJson() {
    return json.encode(this.toMap());
  }
  }
