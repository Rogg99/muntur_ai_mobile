import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/model/user.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'helper.dart';
import 'auth.dart';
import '../logging.dart';

class ChatApi {
  String Api_ =   ApiHelper().apiBaseUrl;
  var auth = AuthApi();
  var dbHelper = DatabaseHelper();
  late String authorization = "Bearer ";

  Future<http.Response> askAI(UIMessage message) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var body = json.encode({
      'contenu' : message.contenu,
      'disc_id' : message.disc_id,
      'media' : []
    });
    print(body.toString());
    var url = Uri.parse('https://$Api_/ask-question');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> startAIChat() async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/start-ai-discussion/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> startChat(String profileId) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/start-discussion/$profileId/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getMessage(String id) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/messages/$id/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getMessagesFromDisc({String disc_id='none',int time=0}) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/$disc_id/messages/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }


  Future<http.Response> getMessagesFromForum({String disc_id='none',int time=0}) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var body = {"id": disc_id,'time':time.toString()};
    var url = Uri.parse('https://$Api_/forums/$disc_id/messages/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> markMessagesAsRead(String disc_id,{bool typeDisc=true}) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/$disc_id/markasread/');
    if(!typeDisc) {
      url = Uri.parse('https://$Api_/forums/$disc_id/markasread/');
    }
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> createMessage(UIMessage message,String discussionId,{bool typeDisc=true}) async {
    message.state = 'sent';
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/messages/discussion/$discussionId/');
    if(!typeDisc) {
      url = Uri.parse('https://$Api_/messages/forum/$discussionId/');
    }
    print(url.toString());
    var body = message.toJson();
    var fileUploaded = false;
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    if (message.media != 'none' && message.media != ''){
      var urlUp = Uri.parse('https://$Api_/medias/');
      print('uploading file to ' + urlUp.toString());
      var requestUpload = new http.MultipartRequest("POST", urlUp);
      requestUpload.headers["Authorization"] = authorization;
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file', message.media);
      // store a copy in app directory
      Directory directory = await getApplicationDocumentsDirectory();
      File newImage = await File(message.media).copy('${directory.path}/muntur_${DateTime.now().millisecondsSinceEpoch.toInt()}${message.media.split('.').last}');
      // send request
      requestUpload.files.add(multipartFile);
      File media = File(message.media);
      await requestUpload.send().then((response) async =>{
        if (response.statusCode==200){
          message.mediaSize = convertSize(await media.length()),
          message.mediaName = message.media.split('/').last,
          body = message.toJson(),
          fileUploaded=true,
        }
        else{
          print(response.stream.bytesToString()),
        }
      });
    }
    if (message.media != 'none' && fileUploaded) {
      return http.post(url, headers: headers, body: body).then((http.Response response) {
        return response;
      });
    } else if (message.media == 'none') {
      return http
          .post(url, headers: headers, body: body)
          .then((http.Response response) {
        return response;
      });
    } else {
      http.Response resp = http.Response('Upload Failed',500);
      return resp;
    }
  }

  Future<http.StreamedResponse> createMedia(String mediaPath) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var urlUp = Uri.parse('https://$Api_/medias/');
    print('uploading file to ' + urlUp.toString());
    var requestUpload = http.MultipartRequest("POST", urlUp);
    requestUpload.headers["Authorization"] = authorization;
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file',mediaPath);
    requestUpload.files.add(multipartFile);
    return requestUpload.send().then((response){
      return response;
    });
  }

  Future<http.Response> addMediaToMessage(String message_id,String media_id) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/messages/$message_id/media/add/$media_id/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  // Discussions
  Future<http.Response> createDiscussion(String disc) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.post(url, headers: headers, body: disc).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateDiscussion(String body,String id_disc) async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/$id_disc/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getDiscussions() async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/discussions/my-discussions/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getForums() async {
    authorization = await auth.getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$Api_/forums/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  String convertSize(int size){
    if(size/1024<1024)
      return (size/1024).toStringAsFixed(2) + 'Kb';
    else
      return (size/(1024*1024)).toStringAsFixed(2) + 'Mb';
  }

  Future<void> syncDiscussions() async {
    var results;
    var done;
    List<Discussion> discs = [];
    bool is_in = false;
    List<Discussion> updatedListDiscussions;
    await getDiscussions().then((response) async => {
      //log("DEBUG MunturAi : "+response.body),
      if (response.statusCode == 200)
        {
          results = json.decode(response.body),
          done = results['data'],
          for (var i = 0; i < done.length; i++)
            {
              discs.add(Discussion(
                  id: done[i]["id"],
                  initiateur : done[i]["initiateur"],
                  interlocuteur : done[i]["interlocuteur"],
                  last_message : done[i]["last_message"],
                  last_date : done[i]["last_date"],
                  last_writer : done[i]["last_writer"],
                  title : done[i]["title"],
                  photo : done[i]["photo"]??'none',
                  type : done[i]["type"]
              )),
            },
          for (var i = 0; i < discs.length; i++)
            {
              updatedListDiscussions = await dbHelper.getDiscussion().then((value) => value),
              if (updatedListDiscussions.isEmpty)
                {//log("DEBUG MunturAi : inserting new local event "),
                  await dbHelper.insertDiscussion(discs[i])}
              else
                {
                  is_in = false,
                  for (var ie = 0; ie < updatedListDiscussions.length; ie++)
                    {
                      if (updatedListDiscussions[ie].id == discs[i].id)
                        {
                          is_in = true,
                        }
                    },
                  if (is_in)
                    {
                      await dbHelper.updateDiscussion(discs[i]).then((value) => {
                        //log("DEBUG MunturAi : updating discussion succeed"),
                      }),
                    }
                  else
                    {
                      //log("DEBUG MunturAi : inserting new local discussion "),
                      await dbHelper.insertDiscussion(discs[i]),
                    }
                }
            },
          updatedListDiscussions = await dbHelper.getDiscussion().then((value) => value),
          for (var ie = 0; ie < updatedListDiscussions.length; ie++)
            {
              is_in = false,
              for (var ia = 0; ia < discs.length; ia++)
                {
                  if (updatedListDiscussions[ie].id == discs[ia].id)
                    {
                      is_in = true,
                    }
                },
              if (is_in == false)
                {
                  await dbHelper.deleteDiscussion(updatedListDiscussions[ie]).then((value) => {
                    log("DEBUG MunturAi : deleting discussion succeed"),
                  }),
                }
            }
        }
    });
  }

  Future<void> syncMessages() async {
    var results;
    var done;
    List<UIMessage> messages = [];
    bool is_in = false;
    var idx=0;
    var selfUser=await auth.getUser().then((value) => value);

    List<UIMessage> updatedListMessages;
    await dbHelper.getDiscussion().then((discs)  async => {
      for (var i = 0; i < discs.length; i++){
        await getMessagesFromDisc(disc_id:discs[i].id,time: (await getLastTimeDisc(discs[i].id)+12)).then((response) async => {
          //log(response.body.toString()),
          if (response.statusCode == 200)
            {
              results = json.decode(response.body),
              done = results['data'],
              for (var i = 0; i < done.length; i++)
                {
                  messages.add(UIMessage(
                    id : done[i]["id"],
                    disc_id : done[i]["disc_id"],
                    temp_id : done[i]["temp_id"],
                    emetteur : done[i]["emetteur"],
                    emetteurName : done[i]["emetteurName"],
                    emetteurPhoto: done[i]["emetteurPhoto"]??'none',
                    contenu : done[i]["contenu"],
                    media : done[i]["media"],
                    answerTo : done[i]["answerTo"],
                    mediaName : done[i]["mediaName"],
                    state : done[i]["is_read"]==true?'read':'sent',
                    date_envoi : done[i]["creation_date"]??0,
                  )),
                },
              updatedListMessages = await dbHelper.getMessage().then((value) => value),
              for (var i = 0; i < messages.length; i++)
                {
                  if (updatedListMessages.isEmpty)
                    {log("DEBUG MunturAi : inserting new local message "),
                      await dbHelper.insertMessage(messages[i])
                    }
                  else
                    {
                      is_in = false,
                      idx=-1,
                      for (var ie = 0; ie < updatedListMessages.length; ie++)
                        {
                          if (updatedListMessages[ie].id == messages[i].id || updatedListMessages[ie].id == messages[i].temp_id )
                            {
                              is_in = true,
                              idx=ie,
                            }
                        },
                      if (is_in)
                        {
                          if(updatedListMessages[idx].id == messages[i].temp_id)
                            await dbHelper.updateMessage(messages[i],id: updatedListMessages[idx].id).then((value) => {
                              log("DEBUG MunturAi : updating message succeed"),
                            }),
                          if( messages[i].emetteur != selfUser.id && updatedListMessages[idx].announced =='no'){
                            ApiHelper().Notify(messages[i].emetteurName, messages[i].contenu),
                            messages[i].announced='yes',
                            log("DEBUG MunturAi : announcing message"),
                            await dbHelper.updateMessage(messages[i]).then((value) => {
                              log("DEBUG MunturAi : updating message succeed"),
                            })
                          },
                          if(updatedListMessages[idx].state !='delete' && updatedListMessages[idx].state != messages[i].state)
                            await dbHelper.updateMessage(messages[i]).then((value) => {
                              log("DEBUG MunturAi : updating message succeed"),
                            }),
                        }
                      else
                        {
                          log("DEBUG MunturAi : inserting new local message "),
                          await dbHelper.insertMessage(messages[i]),
                        }
                    }
                },
            }
        }),
      },
      //print(((DateTime.now().millisecondsSinceEpoch)~/1000).toString()),
      await saveKey('last_update', ((DateTime.now().millisecondsSinceEpoch)~/1000).toString()),
    });
  }

  Future<int> getLastTimeDisc(String id) async {
    int time = 0;
    var list = await dbHelper.getMessagesFromDisc(id);
    for (var element in list) {
      if((DateTime.parse(element.date_envoi).millisecondsSinceEpoch~/1000).toInt()>time) {
        time = (DateTime.parse(element.date_envoi).millisecondsSinceEpoch~/1000).toInt();
      }
    }
    return time;
  }

}
