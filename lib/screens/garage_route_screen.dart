import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/tracking/data/models/tracking_models.dart';
import 'package:munturai/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/osm_tile_layer.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Itinéraire" from a garage card: route + ETA from the user's current
/// position, computed server-side (Doc/17 §4.4 route-preview — the position
/// is only used for the Geoapify call, never stored). Turn-by-turn
/// navigation stays with Google Maps, one tap away in the app bar.
class GarageRouteScreen extends ConsumerStatefulWidget {
  const GarageRouteScreen({super.key, required this.garage});

  final GarageEntity garage;

  @override
  ConsumerState<GarageRouteScreen> createState() => _GarageRouteScreenState();
}

class _GarageRouteScreenState extends ConsumerState<GarageRouteScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _loading = true;
  String? _error;
  LatLng? _from;
  TrackingRoute? _route;

  LatLng get _garagePoint =>
      LatLng(widget.garage.latitude, widget.garage.longitude);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !await Geolocator.isLocationServiceEnabled()) {
        throw _RouteError(l10n.tracking_location_unavailable);
      }
      final pos = await Geolocator.getCurrentPosition();
      final from = LatLng(pos.latitude, pos.longitude);
      final route = await ref.read(trackingRepositoryProvider).routePreview(
            lat: from.latitude,
            lng: from.longitude,
            garageId: widget.garage.id,
          );
      if (!mounted) return;
      setState(() {
        _from = from;
        _route = route;
        _loading = false;
      });
      _fit();
    } on _RouteError catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = l10n.route_load_error;
        });
      }
    }
  }

  void _fit() {
    if (!_mapReady) return;
    final points = [
      _garagePoint,
      if (_from != null) _from!,
      ...?_route?.geometry,
    ];
    if (points.length < 2) return;
    _mapController.fitCamera(CameraFit.coordinates(
      coordinates: points,
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 180),
    ));
  }

  String? _summary() {
    final route = _route;
    if (route == null) return null;
    final parts = <String>[];
    if (route.durationS != null) {
      parts.add('≈ ${(route.durationS! / 60).ceil().clamp(1, 24 * 60)} min');
    }
    if (route.distanceM != null) {
      parts.add(route.distanceM! >= 1000
          ? '${(route.distanceM! / 1000).toStringAsFixed(1)} km'
          : '${route.distanceM!.round()} m');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.garage.latitude},${widget.garage.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final summary = _summary();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        titleTxt: l10n.action_directions,
        actions: [
          IconButton(
            tooltip: l10n.route_open_external,
            icon: const Icon(Icons.navigation_outlined),
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _garagePoint,
              initialZoom: 14,
              onMapReady: () {
                _mapReady = true;
                _fit();
              },
            ),
            children: [
              osmTileLayer(),
              if (_route != null && _route!.geometry.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                      points: _route!.geometry,
                      strokeWidth: 5,
                      color: colorScheme.primary),
                ]),
              MarkerLayer(markers: [
                Marker(
                  point: _garagePoint,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.location_on,
                      size: 40, color: colorScheme.primary),
                ),
                if (_from != null)
                  Marker(
                    point: _from!,
                    width: 36,
                    height: 36,
                    child: Icon(Icons.my_location,
                        size: 30, color: colorScheme.primary),
                  ),
              ]),
            ],
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
                    Text(widget.garage.nom,
                        style: appStyle.H5(weight: 'bold')),
                    const SizedBox(height: 8),
                    if (_loading)
                      const LinearProgressIndicator()
                    else if (_error != null)
                      Row(
                        children: [
                          Expanded(
                              child: Text(_error!,
                                  style: appStyle.H6(color: Colors.redAccent))),
                          TextButton(onPressed: _load, child: Text(l10n.retry)),
                        ],
                      )
                    else
                      Text(
                        summary != null
                            ? '${l10n.tracking_eta_label} : $summary'
                            : l10n.tracking_no_eta,
                        style: appStyle.H6(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared entry point for every "Itinéraire" button (garage page, map
/// preview sheet, search results).
void openGarageRoute(BuildContext context, GarageEntity garage) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => GarageRouteScreen(garage: garage)),
  );
}

class _RouteError implements Exception {
  final String message;
  const _RouteError(this.message);
}
