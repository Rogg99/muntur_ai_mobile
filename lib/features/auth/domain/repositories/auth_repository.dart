import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<UserEntity?> register(Map<String, dynamic> data);
  Future<UserEntity?> getUserProfile();
  Future<void> logout();
}
