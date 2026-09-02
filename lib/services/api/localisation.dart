import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/helper.dart';
import '../logging.dart';
import 'api_client.dart';

class LocalisationApi {
  String apiBaseUrl = ApiHelper().apiBaseUrl;
  final String GOOGLE_MAPS_APIKEY = ApiHelper().GOOGLE_MAPS_APIKEY;

  //location
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return (await Geolocator.getCurrentPosition());
  }

  Future<http.Response> updateLocation(double lat, double lon) async {
    String id = await AuthApi().getUser().then((value) => value.id);
    return ApiClient.patch('/api/profils/$id/',
        body: {'latitude': lat, 'longitude': lon});
  }

  Future<http.Response> searchLocation(String key,
      {String type = "city"}) async {
    return ApiClient.get('/api/search-places/',
        query: {'search': key, 'type': type});
  }

  // Garages
  Future<http.Response> getGaragesAround(String key) async {
    var currentPosition = await getCurrentPosition();
    return ApiClient.post('/garages/around/', body: {
      "longitude": currentPosition.longitude,
      "latitude": currentPosition.latitude,
      "key": key,
    });
  }
}
