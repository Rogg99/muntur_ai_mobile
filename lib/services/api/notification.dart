import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/helper.dart';
import 'package:munturai/model/Comment.dart';

class NotificationApi {
  String baseUrl =   ApiHelper().apiBaseUrl;
  late String authorization = "Bearer ";

  // Notifications
  Future<http.Response> getNotifications() async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$baseUrl/notifications/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  // Infos
  Future<http.Response> getInfos() async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$baseUrl/infos/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getInfo(String id) async {
    authorization = await  AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('https://$baseUrl/infos/$id/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  // Comments
  Future<http.Response> commentInfo(String infoId,Comment comment) async {
    var url = Uri.parse('https://$baseUrl/infos/$infoId/comments/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var body = comment.toJson();
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> removeComment(String comment_id) async {
    var url = Uri.parse('https://$baseUrl/comments/$comment_id/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.delete(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  // likes
  Future<http.Response> likeInfo(String infoId) async {
    var url = Uri.parse('https://$baseUrl/infos/$infoId/like/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> unlikeInfo(String infoId) async {
    var url = Uri.parse('https://$baseUrl/infos/$infoId/unlike/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> likeComment(String commentId) async {
    var url = Uri.parse('https://$baseUrl/comments/$commentId/like/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> unlikeComment(String commentId) async {
    var url = Uri.parse('https://$baseUrl/comments/$commentId/unlike/');
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers).then((http.Response response) {
      return response;
    });
  }


}
