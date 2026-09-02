import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/token.dart';
import 'helper.dart';

class ApiClient {
  static final String _baseUrl = ApiHelper().apiBaseUrl;

  static Future<Map<String, String>> _getHeaders(
      {bool requiresAuth = true}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (requiresAuth) {
      final tokenStr = await getKey('token');
      if (tokenStr.isNotEmpty) {
        try {
          final token = Token.fromJson2(jsonDecode(tokenStr));
          if (token.access.isNotEmpty) {
            headers["Authorization"] = "Bearer ${token.access}";
          }
        } catch (e) {
          log('Error parsing token: $e');
        }
      }
    }
    return headers;
  }

  static Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    // If path starts with /, remove it to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // apiBaseUrl is "195.26.244.215:447/m/muntur"
    // We split it into host and base path
    final parts = _baseUrl.split('/');
    final host = parts[0];
    final basePath = parts.sublist(1).join('/');

    final fullPath = basePath.isEmpty ? cleanPath : '$basePath/$cleanPath';

    return Uri.https(host, fullPath, queryParameters);
  }

  static Future<http.Response> get(String path,
      {bool requiresAuth = true, Map<String, dynamic>? query}) async {
    final uri = _buildUri(path, query);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    log('GET: $uri');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String path,
      {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final encodedBody = body != null ? json.encode(body) : null;
    log('POST: $uri');
    return http.post(uri, headers: headers, body: encodedBody);
  }

  static Future<http.Response> put(String path,
      {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final encodedBody = body != null ? json.encode(body) : null;
    log('PUT: $uri');
    return http.put(uri, headers: headers, body: encodedBody);
  }

  static Future<http.Response> patch(String path,
      {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final encodedBody = body != null ? json.encode(body) : null;
    log('PATCH: $uri');
    return http.patch(uri, headers: headers, body: encodedBody);
  }

  static Future<http.Response> delete(String path,
      {bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    log('DELETE: $uri');
    return http.delete(uri, headers: headers);
  }

  // Specialized multipart POST for media uploads
  static Future<http.StreamedResponse> postMultipart(String path,
      {required Map<String, String> fields,
      required List<http.MultipartFile> files,
      bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest("POST", uri);

    final authHeaders = await _getHeaders(requiresAuth: requiresAuth);
    request.headers.addAll(authHeaders);
    request.fields.addAll(fields);
    request.files.addAll(files);

    log('MUTIPART POST: $uri');
    return request.send();
  }
}
