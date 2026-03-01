// ws_service.dart
import 'package:munturai/services/api/helper.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'notifications.dart';

class WebSocketService {
  late IOWebSocketChannel channel;

  void connect(String profile_id) {
    final url = 'ws://${ApiHelper().apiBaseUrl}/ws/sync/$profile_id/'; // Use auth token if needed
    channel = IOWebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen((message) {
      final data = jsonDecode(message);

      final List likes = data['likes'] ?? [];
      final List messages = data['messages'] ?? [];
      final List notifs = data['notifications'] ?? [];

      if (likes.isNotEmpty) {
        NotificationService.show("❤️ New Like", "Someone liked your profile.");
      }

      if (messages.isNotEmpty) {
        NotificationService.show("💬 New Message", "You received a new message.");
      }

      if (notifs.isNotEmpty) {
        NotificationService.show("🔔 Notification", "You have a new notification.");
      }

      // Example payload: { "verb": "sent you a message", "actor": { "username": "Alice" } }
      final title = "New Notification";
      final body = "${data['actor']['username']} ${data['verb']}";

      NotificationService.show(title, body);
    });
  }

  void disconnect() {
    channel.sink.close();
  }
}
