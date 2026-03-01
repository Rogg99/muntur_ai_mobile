import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/message.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../logging.dart';

class DatabaseHelper {
  late Future<Database> database = CreateLocalDB();

  //LocalDatabase
  Future<Database> CreateLocalDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // log('MunturAi DEBUG: local database already existing');
      return openDatabase(join(await getDatabasesPath(), 'userData.db'));
    } on Exception catch (e) {
      final database = openDatabase(
        join(await getDatabasesPath(), 'userData.db'),
      );
      return database;
    }
  }

  Future<bool> createTables() async {
    openDatabase(join(await getDatabasesPath(), 'userData.db')).then((db) => {
      log('MunturAi DEBUG:  creating local database tables'),
      //(id, code, nom, prenom, sexe, date_naissance, telephone, email, password, photo, type, parti, matricule, inscrit, parrain, photocard, preinscrit, region, pays, departement, commune, departement_org, cni, sympatisant, comite_base, sous_comite_arr)

      db.execute(
          'CREATE TABLE Notification(id TEXT PRIMARY KEY,message TEXT,title TEXT, photo TEXT, type TEXT)')
          .then((value) => log('MunturAi DEBUG: Notification table created')),
      db.execute(
          'CREATE TABLE Discussion(id TEXT PRIMARY KEY, initiateur TEXT,interlocuteur TEXT,last_message TEXT,last_check INTEGER,last_date TEXT,last_writer TEXT, title TEXT, photo TEXT, type TEXT)')
          .then((value) => log('MunturAi DEBUG: Discussion table created')),
      db.execute(
          'CREATE TABLE Message(id TEXT PRIMARY KEY, temp_id TEXT, disc_id TEXT,emetteur TEXT,recepteur TEXT,contenu TEXT,state TEXT,media TEXT,mediaName TEXT,mediaSize TEXT,answerTo TEXT,date_envoi TEXT,announced TEXT)')
          .then((value) => log('MunturAi DEBUG: Message table created')),
    });
    return true;
  }

  //Discussion operations
  Future<void> insertDiscussion(Discussion disc) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'Discussion',
      disc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('MunturAi DEBUG: inserting event in local database');
  }

  Future<bool> updateDiscussion(Discussion disc) async {
    final db = await database;
    //log('MunturAi DEBUG: updating disc in local database');
    try {
      await db.update(
        'Discussion',
        disc.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'id = ?',
        // Pass the Dog's id as a whereArg to prdisc SQL injection.
        whereArgs: [disc.id],
      ).whenComplete(() async => {
        //log('MunturAi DEBUG: discussion members count :' + await getDiscussion().then((value) => value.length.toString())),
      });
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<List<Discussion>> getDiscussion() async {
    // Get a reference to the database.
    final db = await database;
    //log('MunturAi DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Discussion');
      return List.generate(maps.length, (i) {
        return Discussion(
            id : maps[i]["id"],
            initiateur : maps[i]["initiateur"],
            interlocuteur : maps[i]["interlocuteur"],
            last_message : maps[i]["last_message"],
            photo : maps[i]["photo"],
            last_date : (maps[i]["last_date"]),
            last_writer : maps[i]["last_writer"],
            title : maps[i]["title"],
            last_check : maps[i]["last_check"],
            type : maps[i]["type"]
        );
      });
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<Discussion>> getDiscussionId(String id) async {
    // Get a reference to the database.
    final db = await database;
    //log('MunturAi DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Discussion');
      var l= List.generate(maps.length, (i) {
        return Discussion(
            id : maps[i]["id"],
            initiateur : maps[i]["initiateur"],
            interlocuteur : maps[i]["interlocuteur"],
            last_message : maps[i]["last_message"],
            last_date : maps[i]["last_date"],
            photo : maps[i]["photo"],
            last_writer : maps[i]["last_writer"],
            title : maps[i]["title"],
            last_check : maps[i]["last_check"],
            type : maps[i]["type"]
        );
      });
      List<Discussion> found=[];
      l.forEach((element) {
        if(element.id==id)
          found.add(element);
      });
      return found;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<bool> deleteDiscussion(Discussion disc) async {
    final db = await database;
    log('MunturAi DEBUG: updating disc in local database');
    try {
      await db.delete(
        'Discussion',
        where: 'id = ?',
        whereArgs: [disc.id],
      );
    } on DatabaseException catch (e) {
      return false;
    }
    return true;
  }

  //Message operations
  Future<void> insertMessage(UIMessage mes) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'Message',
      mes.toMap2(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ).whenComplete(() async {
      log('message added successfully');
      //log('MunturAi DEBUG: message members count :' + await getMessage().then((value) => value.length.toString())),
    });
    log('MunturAi DEBUG: inserting message in local database');
  }

  Future<bool> updateMessage(UIMessage mes,{String id='none'}) async {
    final db = await database;
    log('MunturAi DEBUG: updating message in local database');
    try {
      await db.update(
        'Message',
        mes.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'id = ?',
        // Pass the Dog's id as a whereArg to prmes SQL injection.
        whereArgs: [mes.id],
      ).whenComplete(() async {
        log('message updated successfully');
      });
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<List<UIMessage>> getMessageDetail(String id) async {
    // Get a reference to the database.
    final db = await database;
    //log('MunturAi DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      var L = List.generate(maps.length, (i) {
        return UIMessage(
          id : maps[i]["id"],
          temp_id :  maps[i]["temp_id"],
          disc_id :  maps[i]["disc_id"],
          emetteur :  maps[i]["emetteur"],
          emetteurName :  maps[i]["emetteurName"]??'none',
          emetteurPhoto: maps[i]["emetteurPhoto"]??'none',
          contenu :  maps[i]["contenu"],
          state :  maps[i]["state"],
          date_envoi :  maps[i]["date_envoi"],
        );
      });
      List<UIMessage> res = [];
      for(var i=0;i<L.length;i++) {
        if (L[i].id == id) {
          res.add(L[i]);
          break;
        }
      }
      return res;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<UIMessage>> getMessage() async {
    // Get a reference to the database.
    final db = await database;
    //log('MunturAi DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      return List.generate(maps.length, (i) {
        return UIMessage(
          id : maps[i]["id"],
          disc_id :  maps[i]["disc_id"],
          emetteur :  maps[i]["emetteur"],
          emetteurName :  maps[i]["emetteurName"]??"none",
          emetteurPhoto: maps[i]["emetteurPhoto"]??'none',
          media :  maps[i]["media"],
          mediaName :  maps[i]["mediaName"],
          mediaSize :  maps[i]["mediaSize"],
          contenu :  maps[i]["contenu"],
          state :  maps[i]["state"],
          date_envoi :  maps[i]["date_envoi"],
        );
      });
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<UIMessage>> getMessagesFromDisc(String disc_id) async {
    // Get a reference to the database.
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      //log('MunturAi DEBUG: message members count :' + await getMessage().then((value) => value.length.toString()));
      var L= List.generate(maps.length, (i) {
        return UIMessage(
          id : maps[i]["id"],
          disc_id :  maps[i]["disc_id"],
          emetteur :  maps[i]["emetteur"],
          emetteurName :  maps[i]["emetteurName"]??'none',
          emetteurPhoto: maps[i]["emetteurPhoto"]??'none',
          media :  maps[i]["media"],
          mediaName :  maps[i]["mediaName"],
          mediaSize :  maps[i]["mediaSize"],
          contenu :  maps[i]["contenu"],
          state :  maps[i]["state"],
          date_envoi :  maps[i]["date_envoi"],
        );
      });
      List<UIMessage> result=[];
      for (var i=0;i<L.length;i++){
        if (L[i].disc_id==disc_id)
          result.add(L[i]);
      }
      return result;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<bool> deleteMessage(UIMessage mes) async {
    final db = await database;
    log('MunturAi DEBUG: updating mes in local database');
    try {
      await db.delete(
        'Message',
        where: 'id = ?',
        whereArgs: [mes.id],
      );
    } on DatabaseException catch (e) {
      return false;
    }
    return true;
  }

}
