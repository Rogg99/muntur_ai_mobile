import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api/notification.dart';
import 'package:munturai/widgets/widget_comment.dart';

import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Comment.dart';

class  WidgetReply extends StatefulWidget{
  Comment? info;
  WidgetCommentState? parent;
  WidgetReply({
    Key? key,
    required this.info,
    required this.parent,
  }):super(key: key);
  @override
  State<WidgetReply> createState() => WidgetReplyState(comment: info,parent: parent);
}

class WidgetReplyState extends State<WidgetReply>{
  Comment? comment;
  WidgetCommentState? parent;
  WidgetReplyState({
    Key? key,
    required this.comment,
    required this.parent,
  });
  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    return  Container(
      padding: getPadding(top: 15),
        width: double.infinity,
        child:
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Padding(padding: getPadding(left: 25)),
                  Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: Center(
                          child:
                          comment!.userPhoto!='none'?
                          Container(
                            margin: getMargin(all:8),
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                                color: UIColors.boxFillColor,
                                image:
                                DecorationImage(
                                  image: NetworkImage('http://muntur.steps4u.net/api/muntur'+comment!.userPhoto),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ):
                          Icon(Icons.account_circle_rounded,size: 32,color: Colors.grey,)
                      ),
                  ),
                  Container(
                    padding: getPadding(left: 5, top: 5, right: 5, bottom: 5,),
                    margin: getMargin(right: 5, left: 5,),
                    width: ((MediaQuery.of(context).size.width) * 0.8) - 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.blueGray100),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment!.userName + ' > '+comment!.replyUserName,
                              maxLines: 1,
                              style: appStyle.txtStream(size: 18,weight: 'bold'),
                            ),
                          ],
                        ),
                        (comment!.image!='' && comment!.image.toLowerCase()!='none')?
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image:DecorationImage(
                                  image: NetworkImage(comment!.image),
                                  fit: BoxFit.cover
                              )
                          ),
                        ):SizedBox(),
                        GestureDetector(
                          onLongPress: (){
                            Clipboard.setData(ClipboardData(text: comment!.contenu))
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
                                  comment!.contenu,
                                  maxLines: null,
                                  textAlign: TextAlign.left,
                                  style: appStyle.txtStream(size: 18)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Padding(padding: getPadding(top: 5)),
            Padding(
              padding: getPadding(left: 32),
              child: Row(
                children: [
                  //Icon(Icons.timelapse,size: 18,),
                  Padding(padding: getPadding(left: 21 + 20)),
                  Text(getDuree(comment!.time.toDouble()),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Padding(padding: getPadding(left: 30)),
                  GestureDetector(child: Text('Répondre',style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  onTap: (){
                    parent!.parent!.linealComment = parent!;
                    parent!.parent!.replyTo.lineal = parent!.comment!.id;
                    parent!.parent!.replyTo.replyTo = comment!.id;
                    parent!.parent!.replyTo.userName = comment!.userName;
                    parent!.parent!.replyTo.userId = comment!.userId;
                    parent!.parent!.show_answer = true;
                    parent!.parent!.showkeyboard();
                    parent!.parent!.linealComment = parent!;
                    parent!.parent!.setState(() {});
                  },),
                  Spacer(),
                  Text(comment!.likes.toString(),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  !comment!.liked?
                  GestureDetector(
                    child: Icon(Icons.favorite,color: Colors.red,),
                    onTap: (){
                      comment!.liked=false;
                      comment!.likes-=1;
                      setState(() {});
                      unlike();
                    },
                  ):
                  GestureDetector(
                    child: Icon(Icons.favorite_border),
                    onTap: (){
                      comment!.liked=true;
                      comment!.likes+=1;
                      setState(() {});
                      like();
                    },
                  ),
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
            Padding(padding: getPadding(top: 10)),
          ],

        ),
      );
  }

  String getDuree(double time){
    String duree='';
    double actual=DateTime.now().millisecondsSinceEpoch/1000;
    double periode = actual-time;
    if(periode/3600<1)
      duree = (periode/60).floor().toString() + 'min';
    else if(periode/3600<24)
      duree = (periode/3600).floor().toString() + 'h';
    else
    duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('dd-MM-yy');
      //duree = (periode/(3600*24)).floor().toString() + 'j';
    return duree;
  }

  like()async{
    await NotificationApi().likeComment(comment!.id).then((response) => {
      if(response.statusCode==200){
        log('liked'),
      }
      else{
        log(response.body)
      },
      setState((){})
    });
  }

  unlike()async{
    await NotificationApi().unlikeComment(comment!.id).then((response) => {
      if(response.statusCode==200){
        log('liked'),
      }
      else{
        log(response.body)
      },
      setState((){})
    });
  }


}
