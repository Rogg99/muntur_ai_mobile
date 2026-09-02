import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/helper.dart';
import 'api_client.dart';

class MediaApi {
  String baseUrl = ApiHelper().apiBaseUrl;

  Future<http.StreamedResponse> createMedia(String media_path) async {
    return ApiClient.postMultipart('/medias/',
        fields: {},
        files: [await http.MultipartFile.fromPath('document', media_path)]);
  }

  Future<http.Response> addMediaToMessage(
      String messageId, String mediaId) async {
    return ApiClient.put('/messages/$messageId/media/add/$mediaId/');
  }

  Future<http.Response> addMediaToGarage(
      String garageId, String mediaId) async {
    return ApiClient.put('/garages/$garageId/media/add/$mediaId/');
  }

  Future<http.Response> updateProfilePhoto(
      String profileId, String mediaId) async {
    return ApiClient.patch('/api/profiles/$profileId/setphoto/$mediaId/');
  }
}
