import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/realtime_dispatcher.dart';
import '../../../../services/websocket.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ApiClient());
}

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<UserEntity?> build() async {
    // Load profile from local Isar or API on startup
    final user = await ref.read(authRepositoryProvider).getUserProfile();
    if (user != null) {
      _connectRealtime();
    }
    return user;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user =
          await ref.read(authRepositoryProvider).login(username, password);
      if (user == null) throw Exception('Login failed');
      return user;
    });
    if (state.hasError) {
      final error = state.asError!;
      Error.throwWithStackTrace(error.error, error.stackTrace);
    }
    _connectRealtime();
  }

  /// Starts the WebSocket + its Riverpod event dispatcher for the session.
  /// Safe to call repeatedly (e.g. every time [build] reruns) — a no-op if
  /// already connected.
  void _connectRealtime() {
    ref.read(realtimeDispatcherProvider);
    if (!WebSocketService().isConnected) {
      unawaited(WebSocketService().connect());
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).register(data);
      if (user == null) throw Exception('Registration failed');
      return user;
    });
    if (state.hasError) {
      final error = state.asError!;
      Error.throwWithStackTrace(error.error, error.stackTrace);
    }
    // Registration saves a token just like login, so the session is live immediately.
    _connectRealtime();
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await WebSocketService().disconnect();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String newPassword) async {
    await ref.read(authRepositoryProvider).resetPassword(newPassword);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).updateProfile(data);
    });
  }

  /// Applies a `profile_updated` WS push directly — see
  /// [RealtimeDispatcher]. No REST round-trip.
  Future<void> applyRemotePush(Map<String, dynamic> json) async {
    final entity = await ref.read(authRepositoryProvider).applyProfilePush(json);
    state = AsyncValue.data(entity);
  }
}
