import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../network/api_client.dart';
import '../../features/tracking/data/models/tracking_models.dart';
import '../../features/tracking/data/repositories_impl/tracking_repository_impl.dart';

/// Sends the tracked actor's position during ONE active mission
/// (Doc/17-api-tracking.md §4.1): geolocator stream with a ~20 m
/// distanceFilter (nothing emitted while stopped), buffered, flushed as one
/// batch every 15 s. On Android the stream runs inside geolocator's foreground
/// service (persistent notification), on iOS with background location updates
/// — so it keeps going with the app in the background, as long as it was
/// started while in the foreground.
///
/// The mobile never opens or extends a mission: [start] is only called for a
/// mission the server already reports as active with role `actor`, and any
/// 403/404/409/410 stops the service for good (the server refuses and never
/// stores those points anyway, §1).
class TrackingLocationService {
  static final TrackingLocationService _instance =
      TrackingLocationService._internal();
  factory TrackingLocationService() => _instance;
  TrackingLocationService._internal();

  static const Duration _flushInterval = Duration(seconds: 15);
  static const int _distanceFilterM = 20;
  static const int _maxBatch = 20;

  final TrackingRepositoryImpl _repo = TrackingRepositoryImpl(ApiClient());

  /// Mission currently being sent, null when idle — screens listen to show a
  /// "position partagée" banner.
  final ValueNotifier<String?> activeMissionId = ValueNotifier(null);

  StreamSubscription<Position>? _positionSub;
  Timer? _flushTimer;
  final List<TrackingPointPayload> _buffer = [];
  bool _flushing = false;

  bool get isRunning => activeMissionId.value != null;

  /// Returns false if location permission/services are unavailable — the
  /// caller shows a message; the mission itself stays server-side.
  Future<bool> start(
    String missionId, {
    required String notificationTitle,
    required String notificationText,
  }) async {
    if (activeMissionId.value == missionId) return true;
    if (isRunning) await stop();

    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    final LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilterM,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          notificationIcon:
              const AndroidResource(name: 'launcher_icon', defType: 'mipmap'),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilterM,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: _distanceFilterM);
    }

    activeMissionId.value = missionId;
    _buffer.clear();
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: (_) {});
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
    return true;
  }

  /// Doc/17 §4.3: the server is the only source of "which mission is mine to
  /// send" — starts sending for the active mission where this account is the
  /// tracked actor, if any. Returns false when there is none or location is
  /// unavailable.
  Future<bool> resumeActiveMission({
    required String notificationTitle,
    required String notificationText,
  }) async {
    final missions = await _repo.getActiveMissions();
    final mine = missions.where((m) => m.role == 'actor');
    if (mine.isEmpty) return false;
    return start(mine.first.id,
        notificationTitle: notificationTitle,
        notificationText: notificationText);
  }

  Future<void> stop() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await _positionSub?.cancel();
    _positionSub = null;
    _buffer.clear();
    activeMissionId.value = null;
  }

  /// Stops only if [missionId] is the one being sent (tracking_ended for
  /// some other mission must not cut this one).
  Future<void> stopIfMission(String missionId) async {
    if (activeMissionId.value == missionId) await stop();
  }

  void _onPosition(Position p) {
    _buffer.add(TrackingPointPayload(
      lat: p.latitude,
      lng: p.longitude,
      accuracyM: p.accuracy,
      heading: p.heading,
      speedMps: p.speed,
      recordedAt: p.timestamp,
    ));
    // Offline buffer cap: keep the 20 most recent, drop the oldest (§4.1).
    if (_buffer.length > _maxBatch) {
      _buffer.removeRange(0, _buffer.length - _maxBatch);
    }
  }

  Future<void> _flush() async {
    final missionId = activeMissionId.value;
    if (missionId == null || _buffer.isEmpty || _flushing) return;
    _flushing = true;
    final batch = List<TrackingPointPayload>.of(_buffer);
    try {
      final outcome = await _repo.sendPositions(missionId, batch);
      // The mission may have been stopped/switched while the POST was out.
      if (activeMissionId.value != missionId) return;
      switch (outcome) {
        case PositionSendOutcome.accepted:
        case PositionSendOutcome.invalid:
          // Removed by identity: points added during the POST stay for the
          // next batch, even if the cap trimmed the buffer meanwhile.
          final sent = Set<TrackingPointPayload>.identity()..addAll(batch);
          _buffer.removeWhere(sent.contains);
          break;
        case PositionSendOutcome.stop:
          await stop();
          break;
        case PositionSendOutcome.retry:
          break; // keep everything, next tick retries
      }
    } finally {
      _flushing = false;
    }
  }
}
