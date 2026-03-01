import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import 'package:munturai/services/api/helper.dart';
import '../model/user.dart';
import 'loading_image.dart';


class WidgetForum extends StatefulWidget{
  Discussion? disc;
  WidgetForum({
    super.key,
    required this.disc,
  });

  @override
  State<StatefulWidget> createState() => WidgetForumState();

}

class WidgetForumState extends State<WidgetForum>{
  User user=User();
  bool load=true;

  @override
  void initState() {
    //syncDisc();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final AppLocalizations translator = AppLocalizations.of(context)!;
    return GestureDetector(
        onTap: () async {
            // var usr = await API.getUI_user().then((value) => value[0]);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(disc: widget.disc,)));
          },
      child:  Container(
        padding: getPadding(all: 10),
        width: double.infinity,
        child:
        Row(
          children: [
            if (widget.disc!.photo.startsWith('http'))
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: ConstantsProvider.getColorFromLetter(context, widget.disc!.title.substring(0,1)),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.disc!.photo,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: Text(widget.disc!.title.substring(0,1).toUpperCase(),
                      style: appStyle.H3(weight: 'bold',color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Center(
                        child: Text(widget.disc!.title.substring(0,1).toUpperCase(),
                          style: appStyle.H3(weight: 'bold',color: Colors.white),
                        ),
                      ),
                ),
              )
            else
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: ConstantsProvider.getColorFromLetter(context, widget.disc!.title.substring(0,1)),
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Center(
                  child: Text(widget.disc!.title.substring(0,1).toUpperCase(),
                    style: appStyle.H3(weight: 'bold',color: Colors.white),
                  ),
                ),
              ),
            Container(
              padding: getPadding(left: 10,right: 10),
              width: size.width-150,
              child:
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(widget.disc!.title,
                      style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(padding: getPadding(top: 5)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(widget.disc!.last_writer == user.id ? '${translator.you} : ${widget.disc!.last_message}':widget.disc!.last_message,
                      style: appStyle.H6(color: count>0 ?Theme.of(context).colorScheme.onSurface:Colors.grey).copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 50,
              child:
              Column(
                children: [
                  Text(getDate(widget.disc!.last_date),style: appStyle.txtDefault(size: 14,color: Theme.of(context).colorScheme.onSurface),),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  int count=0;
  syncDisc() async {
    Timer.periodic( const Duration(seconds: 5), (timer) async {
      widget.disc = await DatabaseHelper().getDiscussionId(widget.disc!.id).then((value) => value[0]);
      //print(disc!.last_check);
      await DatabaseHelper().getMessagesFromDisc(widget.disc!.id).then((list) => {
        count=0,
        for(var i=0;i<list.length;i++){
          if(list[i].emetteur != user.id && DateTime.parse(list[i].date_envoi).isAfter(DateTime.fromMillisecondsSinceEpoch(widget.disc!.last_check*1000)))
            {
              count++,
              //print(list[i].date_envoi.toString() + ' ---- ' + disc!.last_check.toString())
            }
        }
      });
        setState(() {});
    });
  }
  String getDate(String time){
    String duree='';
    Duration periode = DateTime.now().difference(DateTime.parse(time));
    if(periode.inSeconds/3600<1) {
        duree = '${(periode.inSeconds / 60).floor()} min';
    }
    else if( periode.inSeconds/3600 <24) {
      duree = DateTime.parse(time).format('kk:mm');
    } else {
      duree = DateTime.parse(time).format('dd/MM');
    }
    return duree;
  }
}
