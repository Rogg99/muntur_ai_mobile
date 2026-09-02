import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/helper.dart';
import 'package:munturai/model/Comment.dart';
import 'api_client.dart';

class NotificationApi {
  String baseUrl = ApiHelper().apiBaseUrl;

  // Notifications
  Future<http.Response> getNotifications() async {
    return ApiClient.get('/notifications/');
  }

  // Infos
  Future<http.Response> getInfos() async {
    return ApiClient.get('/infos/');
  }

  Future<http.Response> getInfo(String id) async {
    return ApiClient.get('/infos/$id/');
  }

  // Comments
  Future<http.Response> commentInfo(String infoId, Comment comment) async {
    return ApiClient.post('/infos/$infoId/comments/', body: comment.toMap());
  }

  Future<http.Response> removeComment(String comment_id) async {
    return ApiClient.delete('/comments/$comment_id/');
  }

  // likes
  Future<http.Response> likeInfo(String infoId) async {
    return ApiClient.post('/infos/$infoId/like/');
  }

  Future<http.Response> unlikeInfo(String infoId) async {
    return ApiClient.post('/infos/$infoId/unlike/');
  }

  Future<http.Response> likeComment(String commentId) async {
    return ApiClient.post('/comments/$commentId/like/');
  }

  Future<http.Response> unlikeComment(String commentId) async {
    return ApiClient.post('/comments/$commentId/unlike/');
  }
}
