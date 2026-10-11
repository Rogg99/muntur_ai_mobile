import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  /// Returns (user, created) — `created` is true the first time this
  /// Google account logs in (a fresh account was provisioned server-side).
  Future<(UserEntity?, bool)> loginWithGoogle(String idToken);
  Future<UserEntity?> register(Map<String, dynamic> data);
  Future<UserEntity?> getUserProfile();
  Future<void> logout();
  Future<void> resetPassword(String newPassword);
  Future<UserEntity?> updateProfile(Map<String, dynamic> data);
}
