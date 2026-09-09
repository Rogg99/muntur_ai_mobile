import '../../../../core/network/api_client.dart';
import '../../../../core/database/isar_db.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'package:isar/isar.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final _secureStorage = SecureStorageService();

  AuthRepositoryImpl(this._apiClient);

  // ───────────────────────── LOGIN ─────────────────────────

  @override
  Future<UserEntity?> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = _extractAccessToken(response.data);
        if (token != null) {
          await _secureStorage.saveToken(token);
          await _clearCachedProfile();
        }
        return await getUserProfile();
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  // login_view/register in apps/authentication/views.py both return the
  // token pair nested as {"token": {"access": ..., "refresh": ..., "user": ...}}
  // — never a bare string. Extracting the outer "token" value as-is and
  // saving its toString() (the previous bug here) stored the Dart Map's
  // debug representation instead of the actual JWT, so every request made
  // with it after login/register was sending a bearer header the backend
  // could never validate.
  String? _extractAccessToken(dynamic responseData) {
    final tokenField = responseData['data']?['token'] ?? responseData['token'];
    if (tokenField == null) return null;
    if (tokenField is Map) return tokenField['access']?.toString();
    return tokenField.toString();
  }

  // ─────────────────────── REGISTER ────────────────────────

  @override
  Future<UserEntity?> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/auth/register/', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = _extractAccessToken(response.data);
        if (token != null) {
          await _secureStorage.saveToken(token);
          await _clearCachedProfile();
        }
        return await getUserProfile();
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  // ──────────────────── GET USER PROFILE ───────────────────

  @override
  Future<UserEntity?> getUserProfile() async {
    // Try online first
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) {
        return _loadFromIsar();
      }
      final response = await _apiClient.get('/auth/get-user-profile/');
      if (response.statusCode == 200) {
        final raw = response.data;
        // Backend may wrap in 'data'
        final json = raw['data'] ?? raw;
        final userModel = UserModel.fromJson(json as Map<String, dynamic>);
        final isar = IsarDb.instance;
        await isar.writeTxn(() async {
          await isar.userModels.put(userModel);
        });
        return userModel.toEntity();
      }
    } catch (_) {}
    // Fallback to local Isar
    return _loadFromIsar();
  }

  Future<UserEntity?> _loadFromIsar() async {
    final isar = IsarDb.instance;
    final localUser = await isar.userModels.where().findFirst();
    return localUser?.toEntity();
  }

  // Wipes any cached profile from a previous session so a failed profile
  // fetch right after a fresh login/register can't leak a stale user.
  Future<void> _clearCachedProfile() async {
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
  }

  // ──────────────────── UPDATE PROFILE ─────────────────────

  @override
  Future<UserEntity?> updateProfile(Map<String, dynamic> data) async {
    try {
      // PATCH /profiles/my-profile/
      final response =
          await _apiClient.patch('/profiles/my-profile/', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return await getUserProfile();
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
    return null;
  }

  // ─────────────────── RESET PASSWORD ──────────────────────

  @override
  Future<void> resetPassword(String newPassword) async {
    try {
      final response = await _apiClient.post('/auth/reset_password/', data: {
        'new_password': newPassword,
        'confirm_new_password': newPassword,
      });
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Reset password failed: ${response.data}');
      }
    } catch (e) {
      throw Exception('Reset password failed: ${e.toString()}');
    }
  }

  // ─────────────────────── LOGOUT ──────────────────────────

  @override
  Future<void> logout() async {
    // Remove token securely
    await _secureStorage.deleteToken();

    // Clear local Isar user cache
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });

    // Best-effort server-side logout
    try {
      await _apiClient.post('/auth/logout/');
    } catch (_) {}
  }
}
