// notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> show(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('channelId', 'MunturAi Alerts',
        importance: Importance.max, priority: Priority.high);

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}
