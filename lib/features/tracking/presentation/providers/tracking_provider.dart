import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories_impl/tracking_repository_impl.dart';

final trackingRepositoryProvider = Provider<TrackingRepositoryImpl>(
  (ref) => TrackingRepositoryImpl(ApiClient()),
);

/// `tracking_*` WS events (Doc/17 §5), fanned out by RealtimeDispatcher to
/// whichever [TrackingMissionNotifier]s are mounted — only screens showing a
/// mission keep one alive, so nothing is held in memory otherwise.
class TrackingEvents {
  static final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  static Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// [event] is the raw `{type, data}` envelope.
  static void add(Map<String, dynamic> event) => _controller.add(event);
}

/// Live state of one mission: GET §4.2 once, then merged from WS pushes.
class TrackingMissionNotifier
    extends StateNotifier<AsyncValue<TrackingMission>> {
  final TrackingRepositoryImpl _repo;
  final String missionId;
  StreamSubscription<Map<String, dynamic>>? _sub;

  TrackingMissionNotifier(this._repo, this.missionId)
      : super(const AsyncValue.loading()) {
    _sub = TrackingEvents.stream.listen(_onEvent);
    refresh();
  }

  /// Also the client-side net for a missed `tracking_ended` (§5): screens
  /// call this when the app comes back to the foreground.
  Future<void> refresh() async {
    try {
      final mission = await _repo.getMission(missionId);
      if (mounted) state = AsyncValue.data(mission);
    } catch (e, st) {
      if (mounted && !state.hasValue) state = AsyncValue.error(e, st);
    }
  }

  void _onEvent(Map<String, dynamic> event) {
    final data = event['data'];
    if (data is! Map) return;
    final id =
        (data['mission_id'] ?? data['tracking_mission_id'] ?? data['id'])
            ?.toString();
    if (id != missionId) return;
    final current = state.valueOrNull;

    switch (event['type']) {
      case 'tracking_started':
        state = AsyncValue.data(
            TrackingMission.fromJson(data.cast<String, dynamic>()));
        break;
      case 'tracking_position':
        if (current == null) return;
        final position = TrackingPosition.fromJson(data['position']);
        state = AsyncValue.data(current.copyWith(
          leg: data['leg']?.toString(),
          position: position,
          eta: TrackingEta.fromJson(data['eta']),
          trail: position == null
              ? null
              : _appendCapped(current.trail, position.point),
        ));
        break;
      case 'tracking_route':
        if (current == null) return;
        state = AsyncValue.data(current.copyWith(
          leg: data['leg']?.toString(),
          destination: TrackingMission.parseDestination(data['destination']),
          route: TrackingRoute.fromJson(data['route']),
          eta: TrackingEta.fromJson(data['eta']),
        ));
        break;
      case 'tracking_leg_changed':
        if (current == null) return;
        state = AsyncValue.data(current.copyWith(
          leg: data['leg']?.toString(),
          destination: TrackingMission.parseDestination(data['destination']),
        ));
        break;
      case 'tracking_ended':
        state = AsyncValue.data((current ?? TrackingMission(id: missionId))
            .asEnded(data['end_reason']?.toString()));
        break;
    }
  }

  /// Mobile trail is capped at 200 points (§4.2).
  static List<T> _appendCapped<T>(List<T> trail, T point) {
    final next = [...trail, point];
    return next.length > 200 ? next.sublist(next.length - 200) : next;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final trackingMissionProvider = StateNotifierProvider.autoDispose
    .family<TrackingMissionNotifier, AsyncValue<TrackingMission>, String>(
  (ref, missionId) =>
      TrackingMissionNotifier(ref.read(trackingRepositoryProvider), missionId),
);

final activeTrackingMissionsProvider =
    FutureProvider.autoDispose<List<ActiveMissionRef>>((ref) {
  return ref.read(trackingRepositoryProvider).getActiveMissions();
});
