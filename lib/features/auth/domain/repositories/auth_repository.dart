import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<UserEntity?> register(Map<String, dynamic> data);
  Future<UserEntity?> getUserProfile();
  Future<void> logout();
  Future<void> resetPassword(String newPassword);
  Future<UserEntity?> updateProfile(Map<String, dynamic> data);
}
