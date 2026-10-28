import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/tracking/data/models/tracking_models.dart';
import 'package:munturai/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/osm_tile_layer.dart';

/// Live map of one tracking mission (Doc/17), for whoever is allowed to watch
/// it: the buyer, the vendor during `pickup`, the repair client. Initial GET
/// then WS pushes (tracking_position / tracking_route / tracking_ended),
/// re-fetched when the app comes back to the foreground in case
/// tracking_ended was missed while the socket was down (§5).
class TrackingLiveScreen extends ConsumerStatefulWidget {
  const TrackingLiveScreen({
    super.key,
    required this.missionId,
    this.viewerIsVendor = false,
  });

  final String missionId;

  /// The vendor sees the courier coming to the shop, so the pickup wording
  /// differs from the buyer's.
  final bool viewerIsVendor;

  @override
  ConsumerState<TrackingLiveScreen> createState() => _TrackingLiveScreenState();
}

class _TrackingLiveScreenState extends ConsumerState<TrackingLiveScreen>
    with WidgetsBindingObserver {
  static const LatLng _fallbackCenter = LatLng(3.848, 11.502); // Yaoundé

  final MapController _mapController = MapController();
  bool _mapReady = false;
  // Follows the actor until the user pans the map themselves.
  bool _follow = true;
  LatLng? _lastCentered;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(trackingMissionProvider(widget.missionId).notifier).refresh();
    }
  }

  void _maybeFollow(TrackingMission mission) {
    final point = mission.position?.point ?? mission.destination;
    if (!_follow || !_mapReady || point == null || point == _lastCentered) {
      return;
    }
    _lastCentered = point;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(point, _mapController.camera.zoom);
    });
  }

  String _legLabel(AppLocalizations l10n, TrackingMission mission) {
    switch (mission.leg) {
      case 'pickup':
        return widget.viewerIsVendor
            ? l10n.tracking_leg_pickup_vendor
            : l10n.tracking_leg_pickup;
      case 'to_client':
        return l10n.tracking_leg_to_client;
      default:
        return l10n.tracking_leg_dropoff;
    }
  }

  String? _etaLabel(TrackingEta? eta) {
    if (eta == null) return null;
    final parts = <String>[];
    if (eta.remainingS != null) {
      final minutes = (eta.remainingS! / 60).ceil().clamp(1, 24 * 60);
      parts.add('≈ $minutes min');
    }
    if (eta.remainingM != null) {
      parts.add(eta.remainingM! >= 1000
          ? '${(eta.remainingM! / 1000).toStringAsFixed(1)} km'
          : '${eta.remainingM!.round()} m');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final missionAsync = ref.watch(trackingMissionProvider(widget.missionId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.tracking_title),
      body: missionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.tracking_load_error, style: appStyle.H6()),
              TextButton(
                onPressed: () => ref
                    .read(trackingMissionProvider(widget.missionId).notifier)
                    .refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (mission) {
          if (mission.isEnded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 56, color: colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(l10n.tracking_ended,
                        style: appStyle.H5(weight: 'bold'),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          _maybeFollow(mission);
          return _buildMap(context, mission, appStyle, colorScheme, l10n);
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, TrackingMission mission,
      AppStyle appStyle, ColorScheme colorScheme, AppLocalizations l10n) {
    final position = mission.position?.point;
    final eta = _etaLabel(mission.eta);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: position ?? mission.destination ?? _fallbackCenter,
            initialZoom: 15,
            onMapReady: () {
              _mapReady = true;
              _maybeFollow(mission);
            },
            onPositionChanged: (_, hasGesture) {
              if (hasGesture && _follow) setState(() => _follow = false);
            },
          ),
          children: [
            osmTileLayer(),
            if (mission.trail.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                    points: mission.trail,
                    strokeWidth: 4,
                    color: Colors.grey.withValues(alpha: 0.7)),
              ]),
            if (mission.route != null && mission.route!.geometry.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                    points: mission.route!.geometry,
                    strokeWidth: 5,
                    color: colorScheme.primary),
              ]),
            MarkerLayer(markers: [
              if (mission.destination != null)
                Marker(
                  point: mission.destination!,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.flag, size: 36, color: Colors.redAccent),
                ),
              if (position != null)
                Marker(
                  point: position,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      mission.kind == 'repair_visit'
                          ? Icons.build
                          : Icons.two_wheeler,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ]),
          ],
        ),
        if (!_follow && (position != null || mission.destination != null))
          Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton.small(
              heroTag: 'tracking_recenter',
              onPressed: () => setState(() {
                _follow = true;
                _lastCentered = null;
                _maybeFollow(mission);
              }),
              child: const Icon(Icons.center_focus_strong),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_legLabel(l10n, mission),
                      style: appStyle.H5(weight: 'bold')),
                  if (mission.actor != null &&
                      mission.actor!.displayName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(mission.actor!.displayName,
                        style: appStyle.H6(color: Colors.grey)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    position == null
                        ? l10n.tracking_waiting_position
                        : eta != null
                            ? '${l10n.tracking_eta_label} : $eta'
                            : l10n.tracking_no_eta,
                    style: appStyle.H6(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
