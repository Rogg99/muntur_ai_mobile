import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/infoView.dart';
import 'package:munturai/services/api/notification.dart';
import 'package:munturai/model/Notification.dart' as NotificationModel;
import 'package:munturai/utils/sized_extension.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/fonctions.dart';
import '../model/Info.dart';

class  WidgetNotification extends StatefulWidget{
  NotificationModel.Notification? notification;
  WidgetNotification({
    super.key,
    required this.notification,
  });
  @override
  State<WidgetNotification> createState() => WidgetNotificationState(notification: notification);
}

class WidgetNotificationState extends State<WidgetNotification>{
  NotificationModel.Notification? notification;
  bool showFull=false;
  WidgetNotificationState({
    Key? key,
    required this.notification,
  });
  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    var shortText = notification!.text.length > 100 ? notification!.text.substring(0, 100) + '...' : notification!.text;
    return GestureDetector(
      onTap: () async {
        if (notification!.url.startsWith('http')){
          Uri url = Uri.parse(notification!.url);
          launchUrlString(url.toString(),
              mode:LaunchMode.inAppWebView);
        }
      },
      child: Container(
        width: double.infinity,
        padding: getPadding(all: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification!.image.startsWith('http'))
            Image.network(
              notification!.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            if (!notification!.image.startsWith('http'))
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(ImageConstant.imgEllipse),
                  )
                ),
              ),
            Padding(padding: getPadding(left: 15)),
            Container(
              width: BodyWidth()-100.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(notification!.title,style: appStyle.H5(weight: 'bold'),),
                      Spacer(),
                      Text(getDuree(notification!.time),style: appStyle.H6(),),
                    ],
                  ),
                  Padding(padding: getPadding(top: 5)),
                  Text(showFull?notification!.text:shortText,style: appStyle.H6(),),
                  if(notification!.text.length != shortText.length)
                    GestureDetector(
                        onTap:() {
                          setState(() {
                            showFull = !showFull;
                          });
                        },
                        child: Text(showFull?translator.readLess:translator.readMore ,style: appStyle.H7(weight: 'bold'),)
                    ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  String getDuree(num time){
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

}
