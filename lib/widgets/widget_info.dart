import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/infoView.dart';
import 'package:munturai/services/api/notification.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/fonctions.dart';
import '../model/Info.dart';

class  WidgetInfo extends StatefulWidget{
  Info? info;
  bool clickable;
  WidgetInfo({
    super.key,
    required this.info,
    this.clickable=true,
  });
  @override
  State<WidgetInfo> createState() => WidgetInfoState(info: info,clickable: clickable);
}

class WidgetInfoState extends State<WidgetInfo>{
  Info? info;
  bool clickable;
  WidgetInfoState({
    Key? key,
    required this.info,
    this.clickable=true,
  });
  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    return GestureDetector(
      onTap: () async {
        if (clickable) {
          Navigator.of(context).push( MaterialPageRoute(builder: (context) => InfoView(info: info)));
        }
      },
      child: SizedBox(
        width: double.infinity,
        child:
        Column(
          children: [
            Row(
              children: [
                Text(info!.title,style: appStyle.H5(weight: 'bold'),),
              ],
            ),
            Padding(padding: getPadding(top: 15)),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image:info!.image.startsWith('http')? DecorationImage(
                    image: NetworkImage(info!.image),
                    fit: BoxFit.cover
                ):DecorationImage(
                    image: AssetImage(info!.image),
                    fit: BoxFit.cover
                )
              ),
            ),
            Padding(padding: getPadding(top: 5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(info!.contenu!='none'?info!.contenu:'',style: appStyle.H5(),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(padding: getPadding(top: 8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.timelapse),
                  Padding(padding: getPadding(left: 5)),
                  Text(getDuree(info!.time.toDouble()),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Spacer(),
                  !info!.liked?
                  GestureDetector(
                    child: Icon(Icons.favorite,color: Colors.red,),
                    onTap: (){
                      info!.liked=false;
                      info!.likes-=1;
                      setState(() {});
                      unlike();
                    },
                  ):
                  GestureDetector(
                    child: Icon(Icons.favorite_border),
                    onTap: (){
                      info!.liked=true;
                      info!.likes+=1;
                      setState(() {});
                      like();
                    },
                  ),
                  Text(info!.likes.toString(),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Padding(padding: getPadding(left: 20)),
                  Icon(Icons.messenger_outline),
                  GestureDetector(
                      onTap: (){
                        if (clickable)
                        Navigator.of(context).push( MaterialPageRoute(builder: (context) => InfoView(info: info,keyboardFocus: true,)));
                      },
                      child: Text(info!.comments.toString(),style: appStyle.H5(),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                  Padding(padding: getPadding(left: 20)),
                  GestureDetector(
                    child: Icon(Icons.share),
                    onTap: (){
                      print('sharing');
                      Share.share('muntur: Je partage avec vous l\'info '+info!.path);
                    },
                  ),
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
            Divider(),
          ],

        ),
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
      duree = (periode/(3600*24)).floor().toString() + 'j';
    return duree;
  }

  like()async{
    await NotificationApi().likeInfo(info!.id).then((response) => {
      if(response.statusCode==200){
        info!.liked = (json.decode(response.body)['data'] as Map)['id']
      }
      else{
        log(response.body)
      },
      setState((){})
    });
  }

  unlike()async{
    await NotificationApi().unlikeInfo(info!.id).then((response) => {
      if(response.statusCode==200){
        info!.liked = false
      }
      else{
        log(response.body)
      },
      setState((){})
    });
  }


}
