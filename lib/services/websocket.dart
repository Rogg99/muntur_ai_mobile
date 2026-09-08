import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:munturai/core/services/secure_storage_service.dart';

/// Real-time push channel: one WebSocket per logged-in user, joined server-side
/// to the `user_<profile.id>` Channels group (see api/apps/api/consumers.py).
///
/// Emits decoded envelopes of the shape `{"type": "...", "data": {...}}` on
/// [events]. Reconnects automatically with exponential backoff when the
/// connection drops, as long as [connect] hasn't been followed by [disconnect].
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  static const String _wsUrl = 'wss://195.26.244.215:447/ws/live/';
  static const int _maxBackoffSeconds = 30;

  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _disconnectedByClient = true;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Decoded server events: `{"type": "discussion_message", "data": {...}}`.
  Stream<Map<String, dynamic>> get events => _controller.stream;

  bool get isConnected => _channel != null;

  /// Opens the connection using the currently stored JWT. Safe to call again
  /// while already connected/connecting (e.g. after login) — it just resets.
  Future<void> connect() async {
    _disconnectedByClient = false;
    _reconnectTimer?.cancel();

    final token = await SecureStorageService().getToken();
    if (token == null || token.isEmpty) return;

    await _closeChannel();

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse('$_wsUrl?token=$token'));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );
      _reconnectAttempt = 0;
    } catch (e) {
      if (kDebugMode) print('WebSocketService: connect failed: $e');
      _handleDisconnect();
    }
  }

  /// Closes the connection and stops automatic reconnection (e.g. on logout).
  Future<void> disconnect() async {
    _disconnectedByClient = true;
    _reconnectTimer?.cancel();
    await _closeChannel();
  }

  Future<void> _closeChannel() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _onMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is Map<String, dynamic>) {
        _controller.add(decoded);
      }
    } catch (e) {
      if (kDebugMode) print('WebSocketService: malformed event ignored: $e');
    }
  }

  void _handleDisconnect() {
    _channel = null;
    if (_disconnectedByClient) return;

    _reconnectTimer?.cancel();
    _reconnectAttempt = min(_reconnectAttempt + 1, 6);
    final delay = Duration(
      seconds: min(_maxBackoffSeconds, pow(2, _reconnectAttempt).toInt()),
    );
    _reconnectTimer = Timer(delay, connect);
  }
}
