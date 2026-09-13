import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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

  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final absolute = url.startsWith('http') ? url : '$origin$url';
    // Some media (news images confirmed so far) come back as an absolute
    // http:// URL instead of https:// — likely a reverse-proxy not
    // forwarding the original scheme to Django. Android blocks cleartext
    // traffic app-wide (network_security_config.xml), so that request would
    // just silently fail with nothing rendered, no error visible anywhere.
    // Upgrade to the https port we already pin a certificate for, same host.
    if (absolute.startsWith('http://195.26.244.215')) {
      return absolute.replaceFirst('http://195.26.244.215', origin);
    }
    return absolute;
  }

  /// SHA-256 fingerprint (lowercase hex, no colons) of the server's
  /// self-signed leaf certificate — see
  /// android/app/src/main/res/raw/muntur_server_cert.pem, kept in sync with
  /// Muntur-ai-2.0/api/ssl/livekit.crt. Android additionally trusts this
  /// same certificate at the OS level via network_security_config.xml, but
  /// that config has no iOS equivalent — without the pinning below, iOS has
  /// no way to trust this host at all (no public CA, no ATS exception) and
  /// every request would simply fail TLS verification. Pinning here also
  /// means neither platform depends on the OS-level trust store alone.
  static const String _pinnedHost = '195.26.244.215';
  static const String _pinnedSha256Fingerprint =
      '9fb0f2f246a31abca13b592ddfd1dbfcfe665bce7c5b75f2a9f9c030f0255f52';

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

    // Only invoked when the platform's default verification has already
    // rejected the certificate (true on iOS; on Android the OS-level
    // trust-anchor above means this callback never even fires) — so this
    // *adds* an exception for our one pinned cert rather than weakening
    // verification for anything else.
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          if (host != _pinnedHost) return false;
          final fingerprint = sha256.convert(cert.der).toString();
          return fingerprint == _pinnedSha256Fingerprint;
        };
        return client;
      },
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
