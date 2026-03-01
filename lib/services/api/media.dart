import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/helper.dart';

class MediaApi {
  String baseUrl =  ApiHelper().apiBaseUrl;  //"195.26.244.215:22080/api/v1";
  late String authorization = "Bearer ";

  Future<http.StreamedResponse> createMedia(String media_path) async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var urlUp = Uri.http('$baseUrl', 'm/muntur/medias/');
    log('uploading file to $urlUp');
    var requestUpload = new http.MultipartRequest("PUT", urlUp);
    requestUpload.headers["Authorization"] = authorization;
    // File media = File(media_path);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('document',media_path);
    requestUpload.files.add(multipartFile);
    return requestUpload.send().then((response){
        return response;
    });
  }

  Future<http.Response> addMediaToMessage(String messageId,String mediaId) async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.http(baseUrl, 'm/muntur/messages/$messageId/media/add/$mediaId/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> addMediaToGarage(String garageId,String mediaId) async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.http(baseUrl, 'm/muntur/garages/$garageId/media/add/$mediaId/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateProfilePhoto(String profileId,String mediaId) async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.parse('http://$baseUrl/api/profiles/$profileId/setphoto/$mediaId/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.patch(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

}
