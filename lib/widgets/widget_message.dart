
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_player/video_player.dart';

import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/discussion.dart';
import '../model/user.dart';
import '../services/api/chat.dart';

class MessageWidget extends StatefulWidget{
  GlobalKey _containerKey = GlobalKey();
  GlobalKey? idKey;
  UIMessage? message;
  UIMessage? answerTo;
  int answerIndex;
  Discussion? disc;
  Chat_ chatView;
  User? usr;
  bool show_time;
  MessageWidget({
    Key? key,
    required this.idKey,
    required this.message,
    required this.answerTo,
    this.answerIndex = 0,
    required this.disc,
    required this.usr,
    required this.chatView,
    this.show_time=false,
  }) : super(
    key: key,
  );

  @override
  State<MessageWidget> createState() => MessageWidget_(key:idKey,disc: disc,usr: usr,message: message,answerTo: answerTo,answerIndex: answerIndex,chatView: chatView);
}

class MessageWidget_ extends State<MessageWidget> {
  GlobalKey _containerKey = GlobalKey();
  Key? key;
  UIMessage? message;
  UIMessage? answerTo;
  int answerIndex;
  Discussion? disc;
  Chat_ chatView;
  User? usr;
  bool showTime;
  bool loadPhoto = false;
  bool mediaIsDownloaded = false;
  String sizeType='12,5 MB APK';
  late VideoPlayerController _controller;

  MessageWidget_({
    required this.message,
    required this.disc,
    required this.chatView,
    required this.usr,
    this.showTime = false,
    this.answerIndex = 0,
    required this.key ,
    required this.answerTo,
  });

  Color _color = Colors.transparent;
  Timer timer=Timer(Duration.zero, () { });

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(''))..initialize();

    if(isVideo(message!.media.split('.').last)){
      if(message!.media.startsWith('/data/')) {
        _controller = VideoPlayerController.file(File(message!.media))
        ..initialize().then((_) {
          setState(() {});
        });
      } else{
        _controller = VideoPlayerController.networkUrl(Uri(
            scheme: 'http',
            host: 'omc.steps4u.net',
            path: 'api/omc/media/${message!.media}'))
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
    if(message!.emetteur == usr!.id)
      syncMessage();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer = Timer(Duration.zero, () { });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    bool sending = (usr!.id==message!.emetteur);
    bool show_name = (disc!.type=='forum');
    int messagelength = message!.contenu.length >= 36 ? 36 : message!.contenu.length;
    int answerlength = answerTo!.contenu.length >= 36 ? 36 : answerTo!.contenu.length;
    double proportion=(((MediaQuery.of(context).size.width) * 0.8))/(36);
    if(message!.answerTo!='none'){
      messagelength = max(messagelength, answerlength);
    }
    double messageSize = (messagelength*proportion)+50;

    return
      SwipeTo(
        key: key,
        onRightSwipe: (details) {
          chatView.answerTo = answerTo!;
          chatView.showAnswer = true;
          chatView.setState(() {});
        },
        onLeftSwipe: (details) {
          chatView.answerTo = answerTo!;
          chatView.showAnswer = true;
          chatView.setState(() {});
        },
        child:
        AnimatedContainer(
          // Provide an optional curve to make the animation feel smoother.
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 1000),
          decoration: BoxDecoration(
            color: _color,
          ),
            child: Padding(
              padding: getPadding(
                top: 14,
              ),
              child:
                  Row(
                    mainAxisAlignment: sending ? MainAxisAlignment.end:MainAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: (MediaQuery.of(context).size.width) * 0.8, minWidth: 60),
                        child:
                        Container(
                          padding: getPadding(left: 5, top: 5, right: 5, bottom: 5,),
                          margin: getMargin(right: 5, left: 5,),
                          width: (message!.mediaName!='none' || message!.media!='none')?(MediaQuery.of(context).size.width) * 0.6:messageSize,
                          decoration: sending
                              ? BoxDecoration(borderRadius: BorderRadius.circular(10),color: Theme.of(context).colorScheme.primaryContainer)
                              : BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.boxFillColor),
                          child:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              (show_name && !sending)?
                              Text(
                                message!.emetteur,
                                maxLines: null,
                                style: appStyle.txtArimoHebrewSubset(weight: 'bold').copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.26,
                                  ),
                                ),
                              ):SizedBox(),
                              message!.answerTo!='none'?
                              GestureDetector(
                                onTap: (){
                                  chatView.scrollcontroller.scrollToIndex(answerIndex, preferPosition: AutoScrollPosition.begin,duration: Duration(seconds: 1));
                                  //(chatView.allMessageWidgets[answer_index]._containerKey.currentState as MessageWidget_).highlight();

                                },
                                child: Container(
                                  height: 36,
                                  padding: getPadding(top: 5,left: 10,right: 10,bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    border: Border(top: BorderSide(color: Theme.of(context).colorScheme.background,width: 4,)),
                                  ),
                                  child:
                                  ListView(
                                    children: [
                                      Text(answerTo!.emetteur == usr!.id? 'Vous': answerTo!.emetteurName,
                                        overflow: TextOverflow.ellipsis,
                                        style: appStyle.txtAclonica(size: 16,color: UIColors.warningColor,weight: 'bold'),),
                                      Padding(padding: getPadding(left: 10)),
                                      Text(answerTo!.contenu,
                                        overflow: TextOverflow.ellipsis,
                                        style: appStyle.H6(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ):SizedBox(),
                              GestureDetector(
                                onLongPress: (){
                                  Clipboard.setData(ClipboardData(text: message!.contenu))
                                      .then((value) { //only if ->
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('message copié dans le presse papier'),
                                    ));}); // -> show a notification
                                },
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                    child: Text(
                                        message!.contenu,
                                        maxLines: null,
                                        textAlign: TextAlign.left,
                                        style: appStyle.H6(color: Theme.of(context).colorScheme.onSurface)
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child:
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getDate(message!.date_envoi,context ,hh_mm: true),
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: appStyle.txtArimoHebrewSubset(color: Colors.blueGrey).copyWith(
                                        letterSpacing: getHorizontalSize(
                                          0.28,
                                        ),
                                      ),
                                    ),
                                    sending ?
                                    Padding(padding: getPadding(left: 10)):
                                    SizedBox(),
                                    sending ?
                                    (message!.state=='sent' || message!.state=='received' || message!.state=='read')? Icon(Icons.check,size: 12):
                                    message!.state=='failed'? Icon(Icons.warning,color: Colors.red,size: 12):
                                    Icon(Icons.access_time,size: 12,):SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
        ),
      );

  }

  bool isImage(String extension){
    var image_extensions=['JPG', 'PNG', 'GIF', 'WebP', 'BMP','WBMP'];
    //print(extension);
    for(var i=0;i<image_extensions.length;i++) {
      if(extension.toLowerCase() == image_extensions[i].toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  bool isVideo(String extension){
    var image_extensions=['MP4','mp4', 'avi', 'ogg'];
    for(var i=0;i<image_extensions.length;i++) {
      if(extension == image_extensions[i].toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  String getDate(String time,BuildContext context,{bool hh_mm=false,bool yy_mm=false}){
    DateTime dateTime = DateTime.parse(time);
    if(hh_mm) {
      return dateTime.format('kk:mm');
    }
    if(yy_mm){
      var days = ConstantsProvider.getWeekDaysLocalized(context);
      var months = ConstantsProvider.getMonthsLocalized(context);
      String day = dateTime.day.toString();
      String dayCalendar = days[dateTime.weekday-1];
      String month = months[dateTime.month-1];
      String year = dateTime.year.toString();
      String date= '$dayCalendar, $day $month $year';
      return date;
    }

    String duree='';
    Duration periode = DateTime.now().difference(dateTime);
    if(periode.inSeconds/3600<1) {
      duree = '${(periode.inSeconds / 60).floor()} min';
    }
    else if( periode.inSeconds/3600 <24) {
      duree = dateTime.format('kk:mm');
    } else {
      duree = dateTime.format('dd/MM');
    }
    return duree;
  }

  double getWidth() {
    final RenderBox renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size.width;
  }

  Future<bool> mediaIsinLocal(String file) async {
    final directory = await getApplicationDocumentsDirectory();
    return await File(directory.path + '/' +file.split('/').last).exists();
  }

  syncMessage() async{
    if(message!.emetteur==usr!.id && message!.state!='read' && message!.state!='delete') {
      timer = Timer.periodic(Duration(seconds: 5), (t) async{
        var prev=message!.state;
        if(message!.state =='pending'){
            await ChatApi().createMessage(message!,disc!.id).then((response) async => {
              if(response.statusCode==200){
                message!.state = 'sent',
                DatabaseHelper().updateMessage(message!),
              }
              else{
                print(await response.body.toString()),
              },
              setState(() {})
            });
        }
      });
    } else{
      timer = Timer(Duration.zero, () { });
    }
  }

}
