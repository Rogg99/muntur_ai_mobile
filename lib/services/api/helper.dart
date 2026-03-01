import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class ApiHelper {
  String apiBaseUrl =  "195.26.244.215:447/m/muntur";
  late String authorization = "Bearer ";
  String GOOGLE_MAPS_APIKEY=  'AIzaSyDAkY72xE7PK2Eq_5X5Vdsor-wI0V4buuA';//'AIzaSyAj4X5IVwHuf9bFG_3ICyIgdUMgUwik3CM';
  //Notifications
  void Notify(String title, String message, {String type='message', bool foreground=true,String payload='payload'}) {
    // this will be used as notification channel id
    const notificationChannelId = 'my_foreground';
    // this will be used for notification id, So you can update your custom notification with this id.
    const notificationId = 888;
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
              notificationChannelId,
              'MunturAi Notification',
              icon: '@mipmap/launcher_icon',
              ongoing: false,
              importance: Importance.defaultImportance,
              actions: [
                AndroidNotificationAction('1', 'Fermer'),
                AndroidNotificationAction('2', 'Voir',titleColor: Colors.green,showsUserInterface: true),
              ]
          ),
        ),
        payload: 'payload'
    );
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return (await Geolocator.getCurrentPosition());//?? await Geolocator.getLastKnownPosition();
  }

  Future<bool> verifyConnexionStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

}
