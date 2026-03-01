import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/helper.dart';
import '../logging.dart';

class LocalisationApi {
  String apiBaseUrl =   ApiHelper().apiBaseUrl;
  late String authorization = "Bearer ";
  final String GOOGLE_MAPS_APIKEY=  ApiHelper().GOOGLE_MAPS_APIKEY;

  //location
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return (await Geolocator.getCurrentPosition());//?? await Geolocator.getLastKnownPosition();
  }

  Future<http.Response> updateLocation(double lat,double lon) async {
    String id = await AuthApi().getUser().then((value) => value.id);
    var body=json.encode({'latitude':lat,'longitude':lon,});
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var url = Uri.http('$apiBaseUrl', 'api/profils/$id/');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.patch(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> searchLocation(String key, {String type = "city"}) async {
    authorization = await AuthApi().getToken().then((value) =>
    'Bearer ${value!.access}'
    );
    var url=Uri.parse('http://$apiBaseUrl/api/search-places/?search=$key&type=$type');
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(
      url,
      headers: headers,
    ).then((http.Response response) {
      return response;
    });
  }

  // Garages
  Future<http.Response> getGaragesAround(String key) async {
    authorization = await AuthApi().getToken().then((value) =>'Bearer ${value!.access}');
    var currentPosition = await getCurrentPosition();

    var body = json.encode({
      "longitude": currentPosition.longitude,
      "latitude": currentPosition.latitude,
      "key":key,
    });

    var url = Uri.parse('https://$apiBaseUrl/garages/around/');
    print(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

}
