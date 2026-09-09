import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/secure_storage_service.dart';
import '../database/isar_db.dart';
import '../../features/auth/data/models/user_model.dart';

/// Some list endpoints wrap their payload as `{"data": [...]}`, others
/// return the bare JSON array directly. `body['data'] ?? body` throws
/// instead of falling back when `body` is already a `List` (`List` has no
/// String-keyed `[]` operator) — the exception then gets silently swallowed
/// by the repository's surrounding try/catch, which falls back to a
/// (possibly empty) local cache even though the request actually succeeded.
/// Use this to normalize either shape without that crash.
List<dynamic> asResponseList(dynamic body) {
  if (body is List) return body;
  if (body is Map) {
    final data = body['data'];
    if (data is List) return data;
  }
  return const [];
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  /// Origin (scheme+host+port) the API is served from, without the
  /// /m/muntur API path prefix. Media file URLs pushed over the WebSocket
  /// come back relative to this (that push fires from a background thread
  /// with no request object to build an absolute URI from) — resolve any
  /// media URL through [resolveMediaUrl] before displaying it.
  static const String origin = 'https://195.26.244.215:447';

  static String resolveMediaUrl(String url) =>
      url.startsWith('http') ? url : '$origin$url';

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://195.26.244.215:447/m/muntur',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject JWT token from SecureStorageService
          final token = await SecureStorageService().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // 401 → clear token and cached profile so authStateProvider
          // redirects to login instead of falling back to stale user data
          if (e.response?.statusCode == 401) {
            await SecureStorageService().deleteToken();
            await IsarDb.instance.writeTxn(() async {
              await IsarDb.instance.userModels.clear();
            });
          }
          return handler.next(e);
        },
      ),
    );

    // Verbose request/response logging — debug builds only, so JWTs and
    // request/response bodies never end up in a release build's device log.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// Dio sets the multipart/form-data content type and boundary itself
  /// whenever [data] is a [FormData] — the same auth interceptor applies.
  Future<Response> postMultipart(
    String path,
    FormData data, {
    ProgressCallback? onSendProgress,
  }) {
    return _dio.post(path, data: data, onSendProgress: onSendProgress);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
