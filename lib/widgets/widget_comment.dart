import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/widget_reply.dart';

import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Comment.dart';
import 'package:munturai/screens/infoView.dart';
import 'package:munturai/services/api/notification.dart';

class  WidgetComment extends StatefulWidget{
  Comment? info;
  InfoView_? parent;
  WidgetComment({
    super.key,
    required this.info,
    required this.parent,
  });
  @override
  State<WidgetComment> createState() => WidgetCommentState(comment: info,parent: parent);
}

class WidgetCommentState extends State<WidgetComment>{
  Comment? comment;
  InfoView_? parent;
  WidgetCommentState({
    Key? key,
    required this.comment,
    required this.parent,
  });
  List<Comment> replies=[];

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
                    width: (MediaQuery.of(context).size.width) * 0.8 ,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.blueGray100),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment!.userName ,
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
              padding: getPadding(left: 45),
              child: Row(
                children: [
                  //Icon(Icons.timelapse,size: 18,),
                  Text(getDuree(comment!.time.toDouble()),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Padding(padding: getPadding(left: 30)),
                  GestureDetector(child: Text('Répondre',style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    onTap: (){
                      parent!.linealComment = this;
                      parent!.replyTo.lineal = parent!.info!.id;
                      parent!.replyTo.replyTo = comment!.id;
                      parent!.replyTo.userName = comment!.userName;
                      parent!.replyTo.userId = comment!.userId;
                      parent!.show_answer = true;
                      parent!.showkeyboard();
                      parent!.setState(() {});
                    },),
                  Spacer(),
                  Text(comment!.likes.toString(),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  comment!.liked!='no'?
                  GestureDetector(
                    child: Icon(Icons.favorite,color: Colors.red,),
                    onTap: (){
                      comment!.liked=false;
                      comment!.likes-=1;
                      setState(() {});
                      //unlike();
                    },
                  ):
                  GestureDetector(
                    child: Icon(Icons.favorite_border),
                    onTap: (){
                      comment!.liked=true;
                      comment!.likes+=1;
                      setState(() {});
                      //like();
                    },
                  ),
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
            Padding(padding: getPadding(top: 10)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for(var i=0;i<replies.length;i++)
                  WidgetReply(info: replies[i], parent: this),
              ],
            ),
            Padding(padding: getPadding(top: 5)),
            comment!.comments > replies.length?
            Padding(
              padding: getPadding(left: 32),
              child: Row(
                children: [
                  //Icon(Icons.timelapse,size: 18,),
                  Padding(padding: getPadding(left: 21)),
                  Spacer(),
                  Text('Afficher '+(comment!.comments - replies.length).toString() + ' reponses',style: appStyle.H5().copyWith(
                    decoration: TextDecoration.underline,
                  )),
                  Spacer(),
                ],
              ),
            ):SizedBox(),
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
