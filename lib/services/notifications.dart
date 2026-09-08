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

    // Android 13+ (API 33) requires this permission at runtime, or show()
    // silently does nothing — declared in AndroidManifest.xml, requested here.
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show(String title, String body, {int? id}) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('channelId', 'Autosynx Alerts',
        importance: Importance.max, priority: Priority.high);

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      // A fixed id (the previous default) makes every call replace the last
      // notification before it's seen — use a distinct id per call instead
      // so several live events (message, forum, notification...) can stack.
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      platformDetails,
    );
  }
}
