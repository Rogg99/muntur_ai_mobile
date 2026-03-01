import 'dart:convert';

class UIMessage {
  String id;
  String disc_id;
  String temp_id;
  String emetteur;
  String emetteurName;
  String emetteurPhoto;
  String contenu;
  String state;
  String announced;
  String answerTo;
  String media;
  String mediaName;
  String mediaSize;
  String date_envoi;

  UIMessage({
    this.id = "auto",
    this.disc_id = "none",
    this.temp_id = "none",
    this.emetteur = "none",
    this.emetteurName = "none",
    this.emetteurPhoto = "none",
    this.contenu = "none",
    this.answerTo = "none",
    this.mediaName = "none",
    this.mediaSize = "none",
    this.announced = "no",
    this.media = "[]",
    this.state = 'pending', //pending,sent,received,read,failed
    this.date_envoi = "1970-01-01 00:00",
  });

  factory UIMessage.fromJson(Map<String, dynamic> json) {
    return UIMessage(
        id : json["id"],
        disc_id : json["disc_id"],
        emetteur : json["emetteur"],
        emetteurName: json["emetteurName"]??'none',
        emetteurPhoto: json["emetteurPhoto"]??'none',
        contenu : json["contenu"],
        media : json["media"].toString(),
        answerTo : json["answerTo"]??'none',
        mediaName : json["mediaName"]??'none',
        mediaSize : json["mediaSize"]??'none',
        announced : json["announced"]?? 'no',
        state : json["state"].toString().toLowerCase(),
        date_envoi : json["date_envoi"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'disc_id' : disc_id,
      'temp_id' : temp_id,
      'emetteur' : emetteur,
      'emetteurName' : emetteurName,
      'emetteurPhoto' : emetteurPhoto,
      'contenu' : contenu,
      'state' : state,
      'media' : media,
      'mediaName' : mediaName,
      'mediaSize' : mediaSize,
      'answerTo' : answerTo,
      'date_envoi' : date_envoi,
      'announced' : announced,
    };
  }


  Map<String, dynamic> toMap2() {
    return {
      'id' : id,
      'disc_id' : disc_id,
      'temp_id' : temp_id,
      'emetteur' : emetteur,
      'contenu' : contenu,
      'state' : state,
      'media' : media,
      'mediaName' : mediaName,
      'mediaSize' : mediaSize,
      'answerTo' : answerTo,
      'date_envoi' : date_envoi,
      'announced' : announced,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

  }
