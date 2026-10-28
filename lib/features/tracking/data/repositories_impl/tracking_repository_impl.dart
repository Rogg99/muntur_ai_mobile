import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/tracking_models.dart';

/// Doc/17-api-tracking.md §4 — the `/m/muntur/` base is already ApiClient's.
class TrackingRepositoryImpl {
  final ApiClient _apiClient;

  TrackingRepositoryImpl(this._apiClient);

  Map<String, dynamic> _unwrap(dynamic data) {
    final raw = data is Map && data['data'] is Map ? data['data'] : data;
    return (raw as Map).cast<String, dynamic>();
  }

  /// §4.2. A 410 (mission ended) comes back as an ended mission with no
  /// coordinates rather than an error, so screens can show "terminé".
  Future<TrackingMission> getMission(String missionId) async {
    try {
      final response = await _apiClient.get('/tracking/missions/$missionId/');
      return TrackingMission.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 410) {
        final body = e.response?.data;
        return TrackingMission(id: missionId)
            .asEnded(body is Map ? body['end_reason']?.toString() : null);
      }
      rethrow;
    }
  }

  /// §4.3 — called at session start and on `tracking_started` to resume
  /// sending (actor) or re-show the map (client, vendor).
  Future<List<ActiveMissionRef>> getActiveMissions() async {
    final response = await _apiClient.get('/tracking/missions/active/');
    return asResponseList(response.data)
        .whereType<Map>()
        .map((j) => ActiveMissionRef.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  /// §4.1 — maps each status code to what the caller does with its buffer.
  Future<PositionSendOutcome> sendPositions(
      String missionId, List<TrackingPointPayload> points) async {
    try {
      await _apiClient.post('/tracking/missions/$missionId/position/',
          data: {'points': points.map((p) => p.toJson()).toList()});
      return PositionSendOutcome.accepted;
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 400:
          return PositionSendOutcome.invalid;
        case 403:
        case 404:
        case 409:
        case 410:
          return PositionSendOutcome.stop;
        default:
          return PositionSendOutcome.retry; // 429, 5xx, no network
      }
    }
  }

  /// §4.4 — one-off route to a garage; `from` is never stored server-side.
  Future<TrackingRoute?> routePreview(
      {required double lat,
      required double lng,
      required String garageId}) async {
    final response = await _apiClient.post('/tracking/route-preview/', data: {
      'from': {'lat': lat, 'lng': lng},
      'garage_id': garageId,
    });
    return TrackingRoute.fromJson(_unwrap(response.data));
  }
}
