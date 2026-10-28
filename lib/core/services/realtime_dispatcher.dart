import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../screens/login.dart';
import '../../services/notifications.dart';
import '../../services/websocket.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chatbot/data/models/message_model.dart';
import '../../features/chatbot/presentation/providers/chatbot_provider.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/subscriptions/presentation/providers/subscription_provider.dart';
import '../../features/support/presentation/providers/support_provider.dart';
import '../../features/tracking/presentation/providers/tracking_provider.dart'
    show TrackingEvents;
import 'tracking_location_service.dart';

part 'realtime_dispatcher.g.dart';

/// The chat discussion id currently open on screen, if any — ChatView sets
/// this on mount/re-key and clears it on dispose, so a `discussion_message`
/// push for that same discussion doesn't also pop a system notification
/// while the user is already looking right at the message landing live.
final activeDiscussionIdProvider = StateProvider<String?>((ref) => null);

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
    // Session start: resume sending if a mission where this account is the
    // tracked actor is still active (app killed/restarted mid-delivery).
    _resumeActorMission();
  }

  /// The mobile never starts a mission on its own — it only resumes the one
  /// the server reports as active with role `actor` (Doc/17 §4.3).
  Future<void> _resumeActorMission() async {
    try {
      final context = MyApp.navigatorKey.currentContext;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      await TrackingLocationService().resumeActiveMission(
        notificationTitle: l10n?.tracking_notification_title ?? 'Autosynx',
        notificationText: l10n?.tracking_notification_text ??
            'Position shared with your customer',
      );
    } catch (_) {
      // Best effort: retried on the next tracking_started / app start.
    }
  }

  void _handleEvent(Map<String, dynamic> event) {
    final type = event['type'];
    final data = event['data'];

    switch (type) {
      case 'discussion_message':
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          final discId = message.discId != 'none' ? message.discId : null;
          if (discId != null) {
            ref.read(chatMessagesProvider(discId).notifier).applyIncoming(message);
            ref.read(discussionsProvider.notifier).applyIncomingMessage(
                  discId: discId,
                  contenu: message.contenu,
                  lastWriter: message.senderId,
                  dateEnvoi: message.dateEnvoi,
                );
          }
          if (discId != null && discId == ref.read(activeDiscussionIdProvider)) {
            break; // user is already looking at this discussion
          }
        }
        _notify(_senderLabel(data, fallback: 'Autosynx'), _messageBody(data));
        break;

      // Sent once a voice-note/video message sent with no typed text gets
      // its transcript filled in server-side (same MessageReadSerializer
      // shape as discussion_message). applyIncoming replaces-by-id rather
      // than appending, so this updates the existing bubble in place
      // instead of showing the transcript as a second message — no push
      // notification here, the user already saw this message land.
      case 'discussion_message_updated':
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          final discId = message.discId != 'none' ? message.discId : null;
          if (discId != null) {
            ref.read(chatMessagesProvider(discId).notifier).applyIncoming(message);
            // Only ever non-empty here for the voice-only-first-message
            // backfill (title couldn't be derived at send time, no text
            // yet) — the normal text-message case already gets its title
            // from askQuestion's own response, see ChatView._handleSend.
            ref.read(discussionsProvider.notifier).applyIncomingMessage(
                  discId: discId,
                  contenu: message.contenu,
                  lastWriter: message.senderId,
                  dateEnvoi: message.dateEnvoi,
                  title: data['title']?.toString(),
                );
          }
        }
        break;

      case 'forum_message':
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          final forumId = message.discId != 'none' ? message.discId : null;
          if (forumId != null) {
            ref
                .read(chatMessagesProvider(forumId, isForum: true).notifier)
                .applyIncoming(message);
            ref.read(forumsProvider.notifier).applyIncomingMessage(
                  forumId: forumId,
                  contenu: message.contenu,
                  lastWriter: message.senderId,
                  dateEnvoi: message.dateEnvoi,
                );
          }
        }
        _notify(_senderLabel(data, fallback: 'Forum'), _messageBody(data));
        break;

      // Minimal payload ({ticket_id, message_id, contenu, emetteur} —
      // not the full MessageReadSerializer shape discussion_message uses),
      // so this just invalidates rather than trying to merge a partial
      // message in. Fires whether the reply came via the API or the Django
      // admin (staff has no dedicated agent UI yet, see signals.py).
      case 'support_ticket_message':
        final ticketId = data is Map ? data['ticket_id']?.toString() : null;
        if (ticketId != null) {
          ref.invalidate(supportTicketDetailProvider(ticketId));
        }
        ref.invalidate(supportTicketsProvider);
        _notify('Assistance', _messageBody(data));
        break;

      case 'notification':
        ref.read(notificationsListProvider.notifier).refresh();
        _notify('Notification', (data is Map ? data['text'] : null)?.toString() ?? '');
        break;

      case 'profile_updated':
        // Sent by ProfileViewSet, so data is the full Profile — but never
        // username/email (those live on the Django User model, only
        // injected by GET /auth/get-user-profile/ itself). AuthState
        // preserves those two from whatever's already cached.
        if (data is Map<String, dynamic>) {
          ref.read(authStateProvider.notifier).applyRemotePush(data);
        } else {
          ref.invalidate(authStateProvider);
        }
        break;

      case 'transaction':
      case 'subscription':
        ref.invalidate(currentSubscriptionProvider);
        ref.invalidate(coinsBalanceProvider);
        break;

      // Pushed once a coins-pack purchase's Campay webhook confirms —
      // {"coins_balance": <int>}. Just invalidates rather than setting the
      // value directly since coinsBalanceProvider is a plain FutureProvider
      // (no build_runner here to give it a settable Notifier), same
      // approach as the transaction/subscription case above.
      case 'coins_balance_updated':
        ref.invalidate(coinsBalanceProvider);
        break;

      // Live GPS tracking (Doc/17 §5). Mounted mission screens merge these;
      // the actor side starts/stops its location service on them. A missed
      // tracking_ended is covered by the next position POST's 409/410.
      case 'tracking_started':
        TrackingEvents.add(event);
        _resumeActorMission();
        break;
      case 'tracking_position':
      case 'tracking_route':
      case 'tracking_leg_changed':
        TrackingEvents.add(event);
        break;
      case 'tracking_ended':
        TrackingEvents.add(event);
        final missionId = data is Map ? data['mission_id']?.toString() : null;
        if (missionId != null) {
          TrackingLocationService().stopIfMission(missionId);
        }
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
      SnackBar(
          content: Text(
              AppLocalizations.of(context)!.account_suspended_message)),
    );
  }
}
