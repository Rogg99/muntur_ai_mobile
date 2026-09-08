import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../main.dart';
import '../../screens/login.dart';
import '../../services/notifications.dart';
import '../../services/websocket.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chatbot/presentation/providers/chatbot_provider.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/subscriptions/presentation/providers/subscription_provider.dart';

part 'realtime_dispatcher.g.dart';

/// Wires [WebSocketService] events to the Riverpod caches that render them, so
/// discussions/forums/notifications/subscriptions update live instead of
/// waiting for the next pull-to-refresh or app restart. Started from
/// [AuthState.login]/app startup and left running for the whole session — see
/// [WebSocketService] lifecycle wiring in auth_provider.dart.
@Riverpod(keepAlive: true)
class RealtimeDispatcher extends _$RealtimeDispatcher {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void build() {
    _subscription = WebSocketService().events.listen(_handleEvent);
    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  void _handleEvent(Map<String, dynamic> event) {
    final type = event['type'];
    final data = event['data'];

    switch (type) {
      case 'discussion_message':
        ref.invalidate(discussionsProvider);
        final discId = (data is Map ? data['disc_id'] : null)?.toString();
        if (discId != null) {
          ref.invalidate(chatMessagesProvider(discId));
        }
        _notify(_senderLabel(data, fallback: 'MUNTUR AI'), _messageBody(data));
        break;

      case 'forum_message':
        ref.invalidate(forumsProvider);
        final forumId = (data is Map ? data['forum_id'] : null)?.toString();
        if (forumId != null) {
          ref.invalidate(chatMessagesProvider(forumId));
        }
        _notify(_senderLabel(data, fallback: 'Forum'), _messageBody(data));
        break;

      case 'notification':
        ref.read(notificationsListProvider.notifier).refresh();
        _notify('Notification', (data is Map ? data['text'] : null)?.toString() ?? '');
        break;

      case 'profile_updated':
        ref.invalidate(authStateProvider);
        break;

      case 'transaction':
      case 'subscription':
        ref.invalidate(currentSubscriptionProvider);
        ref.invalidate(coinsBalanceProvider);
        break;

      case 'account_status':
        if (data is Map && data['is_active'] == false) {
          _forceLogout();
        }
        break;
    }
  }

  void _notify(String title, String body) {
    if (body.isEmpty) return;
    NotificationService.show(title, body);
  }

  String _senderLabel(dynamic data, {required String fallback}) {
    if (data is! Map) return fallback;
    final sender = data['emetteur'];
    if (sender is Map) {
      final name = '${sender['nom'] ?? ''} ${sender['prenom'] ?? ''}'.trim();
      if (name.isNotEmpty) return name;
    }
    return fallback;
  }

  String _messageBody(dynamic data) {
    if (data is! Map) return '';
    return (data['contenu'] as String?)?.trim() ?? '';
  }

  Future<void> _forceLogout() async {
    await WebSocketService().disconnect();
    await ref.read(authStateProvider.notifier).logout();

    final navigatorState = MyApp.navigatorKey.currentState;
    final context = MyApp.navigatorKey.currentContext;
    if (navigatorState == null || context == null) return;

    navigatorState.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Votre compte a été suspendu.')),
    );
  }
}
