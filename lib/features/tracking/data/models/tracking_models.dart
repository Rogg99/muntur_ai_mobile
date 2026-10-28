/// Mirrors Doc/17-api-tracking.md (contrat final v1) §4.2/§4.3/§5 —
/// TrackingMissionReadSerializer(staff=False). Coordinates in `route.geometry`
/// and `trail` are GeoJSON order ([lng, lat]); they're flipped into LatLng
/// here so screens never have to think about it.
library;

import 'package:latlong2/latlong.dart';

double? _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

/// GeoJSON [[lng, lat], ...] → [LatLng(lat, lng), ...], skipping malformed pairs.
List<LatLng> _parseLngLatList(dynamic raw) {
  if (raw is! List) return const [];
  final out = <LatLng>[];
  for (final pair in raw) {
    if (pair is List && pair.length >= 2) {
      final lng = _toDouble(pair[0]);
      final lat = _toDouble(pair[1]);
      if (lat != null && lng != null) out.add(LatLng(lat, lng));
    }
  }
  return out;
}

class TrackingPosition {
  final LatLng point;
  final double? accuracyM;
  final double? heading;
  final double? speedMps;
  final String? recordedAt;

  const TrackingPosition({
    required this.point,
    this.accuracyM,
    this.heading,
    this.speedMps,
    this.recordedAt,
  });

  static TrackingPosition? fromJson(dynamic json) {
    if (json is! Map) return null;
    final lat = _toDouble(json['lat']);
    final lng = _toDouble(json['lng']);
    if (lat == null || lng == null) return null;
    return TrackingPosition(
      point: LatLng(lat, lng),
      accuracyM: _toDouble(json['accuracy_m']),
      heading: _toDouble(json['heading']),
      speedMps: _toDouble(json['speed_mps']),
      recordedAt: json['recorded_at']?.toString(),
    );
  }
}

class TrackingRoute {
  final List<LatLng> geometry;
  final double? distanceM;
  final double? durationS;

  const TrackingRoute({required this.geometry, this.distanceM, this.durationS});

  static TrackingRoute? fromJson(dynamic json) {
    if (json is! Map) return null;
    final geometry = json['geometry'];
    return TrackingRoute(
      geometry:
          _parseLngLatList(geometry is Map ? geometry['coordinates'] : null),
      distanceM: _toDouble(json['distance_m']),
      durationS: _toDouble(json['duration_s']),
    );
  }
}

class TrackingEta {
  final double? remainingM;
  final double? remainingS;
  final String? arrivalAt;

  const TrackingEta({this.remainingM, this.remainingS, this.arrivalAt});

  static TrackingEta? fromJson(dynamic json) {
    if (json is! Map) return null;
    return TrackingEta(
      remainingM: _toDouble(json['remaining_m']),
      remainingS: _toDouble(json['remaining_s']),
      arrivalAt: json['arrival_at']?.toString(),
    );
  }
}

class TrackingActor {
  final String id;
  final String nom;
  final String prenom;
  final String? avatar;

  const TrackingActor(
      {required this.id, this.nom = '', this.prenom = '', this.avatar});

  String get displayName => '$prenom $nom'.trim();

  static TrackingActor? fromJson(dynamic json) {
    if (json is! Map) return null;
    return TrackingActor(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }
}

/// Live state of one mission. Ended is set locally when GET answers 410 or a
/// `tracking_ended` push lands — the server sends no coordinates then.
class TrackingMission {
  final String id;
  final String kind; // delivery | repair_visit
  final String refId;
  final String? orderId;
  final String status; // active | ended
  final String leg; // pickup | dropoff | to_client
  final TrackingActor? actor;
  final TrackingPosition? position;
  final LatLng? destination;
  final TrackingRoute? route;
  final TrackingEta? eta;
  final List<LatLng> trail;
  final String? endReason;

  const TrackingMission({
    required this.id,
    this.kind = 'delivery',
    this.refId = '',
    this.orderId,
    this.status = 'active',
    this.leg = 'dropoff',
    this.actor,
    this.position,
    this.destination,
    this.route,
    this.eta,
    this.trail = const [],
    this.endReason,
  });

  bool get isEnded => status == 'ended';

  static LatLng? parseDestination(dynamic dest) {
    if (dest is! Map) return null;
    final lat = _toDouble(dest['lat']);
    final lng = _toDouble(dest['lng']);
    return (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }

  factory TrackingMission.fromJson(Map<String, dynamic> json) =>
      TrackingMission(
        id: (json['id'] ?? json['tracking_mission_id'] ?? json['mission_id'])
            .toString(),
        kind: json['kind']?.toString() ?? 'delivery',
        refId: json['ref_id']?.toString() ?? '',
        orderId: json['order_id']?.toString(),
        status: json['status']?.toString() ?? 'active',
        leg: json['leg']?.toString() ?? 'dropoff',
        actor: TrackingActor.fromJson(json['actor']),
        position: TrackingPosition.fromJson(json['position']),
        destination: parseDestination(json['destination']),
        route: TrackingRoute.fromJson(json['route']),
        eta: TrackingEta.fromJson(json['eta']),
        trail: _parseLngLatList(json['trail']),
      );

  TrackingMission copyWith({
    String? leg,
    TrackingPosition? position,
    LatLng? destination,
    TrackingRoute? route,
    TrackingEta? eta,
    List<LatLng>? trail,
  }) =>
      TrackingMission(
        id: id,
        kind: kind,
        refId: refId,
        orderId: orderId,
        status: status,
        leg: leg ?? this.leg,
        actor: actor,
        position: position ?? this.position,
        destination: destination ?? this.destination,
        route: route ?? this.route,
        eta: eta ?? this.eta,
        trail: trail ?? this.trail,
        endReason: endReason,
      );

  /// Every coordinate is dropped on end, matching what the server does (§1).
  TrackingMission asEnded(String? reason) => TrackingMission(
        id: id,
        kind: kind,
        refId: refId,
        orderId: orderId,
        status: 'ended',
        leg: leg,
        actor: actor,
        endReason: reason,
      );
}

/// §4.3 short format.
class ActiveMissionRef {
  final String id;
  final String kind;
  final String refId;
  final String leg;
  final String role; // actor | client | vendor

  const ActiveMissionRef({
    required this.id,
    this.kind = 'delivery',
    this.refId = '',
    this.leg = 'dropoff',
    this.role = 'client',
  });

  factory ActiveMissionRef.fromJson(Map<String, dynamic> json) =>
      ActiveMissionRef(
        id: json['id'].toString(),
        kind: json['kind']?.toString() ?? 'delivery',
        refId: json['ref_id']?.toString() ?? '',
        leg: json['leg']?.toString() ?? 'dropoff',
        role: json['role']?.toString() ?? 'client',
      );
}

/// One point of POST /tracking/missions/<id>/position/ (§4.1).
class TrackingPointPayload {
  final double lat;
  final double lng;
  final double? accuracyM;
  final double? heading;
  final double? speedMps;
  final DateTime recordedAt;

  const TrackingPointPayload({
    required this.lat,
    required this.lng,
    required this.recordedAt,
    this.accuracyM,
    this.heading,
    this.speedMps,
  });

  Map<String, dynamic> toJson() => {
        'lat': double.parse(lat.toStringAsFixed(6)),
        'lng': double.parse(lng.toStringAsFixed(6)),
        if (accuracyM != null) 'accuracy_m': accuracyM!.round(),
        // geolocator reports -1 / 0 when heading or speed is unknown.
        if (heading != null && heading! >= 0) 'heading': heading!.round(),
        if (speedMps != null && speedMps! >= 0)
          'speed_mps': double.parse(speedMps!.toStringAsFixed(1)),
        'recorded_at': recordedAt.toUtc().toIso8601String(),
      };
}

/// What the location service must do after a position POST (§4.1 table).
enum PositionSendOutcome {
  accepted, // 200: drop the sent points from the buffer
  invalid, // 400: drop the invalid batch
  stop, // 403/404/409/410: stop the location service
  retry, // 429 or network error: keep the buffer, retry next batch
}
