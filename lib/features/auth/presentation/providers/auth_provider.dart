import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../../../core/network/api_client.dart';

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
    return ref.read(authRepositoryProvider).getUserProfile();
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user =
          await ref.read(authRepositoryProvider).login(username, password);
      if (user == null) throw Exception('Login failed');
      return user;
    });
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).register(data);
      if (user == null) throw Exception('Registration failed');
      return user;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
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
}
