import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<UserEntity?> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Fetch full profile and save to local DB
        return await getUserProfile();
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<UserEntity?> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/auth/register/', data: data);
      if (response.statusCode == 201) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return await getUserProfile();
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<UserEntity?> getUserProfile() async {
    try {
      final response = await _apiClient.get('/auth/get-user-profile/');
      if (response.statusCode == 200) {
        // Assume API returns a user object inside `data` or directly.
        final userModel = UserModel.fromJson(response.data);

        // Save to local DB (Isar)
        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.userModels.put(userModel);
        });

        return userModel.toEntity();
      }
    } catch (e) {
      // Fallback to local DB if available
      final isar = IsarDb.instance;
      final localUser = await isar.userModels.where().findFirst();
      if (localUser != null) {
        return localUser.toEntity();
      }
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    // Clear local db user cache
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
  }
}
