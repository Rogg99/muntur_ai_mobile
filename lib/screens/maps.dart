import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/garage_route_request.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
import 'package:munturai/screens/garage.dart';
import 'package:munturai/features/tracking/data/models/tracking_models.dart';
import 'package:munturai/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:munturai/features/tracking/route_progress.dart';
import 'package:munturai/widgets/osm_tile_layer.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  LatLng? _currentPosition;
  bool _searching = false;
  String? _fittedForQuery;
  // Set when a search-result row is tapped — replaces the results drawer
  // with a half-open details preview for that one garage, until a new
  // search starts or it's dismissed.
  GarageEntity? _detailsGarage;

  // Garage shown in the marker-tap preview sheet — its marker is drawn
  // larger so the swipe target is obvious on the map behind the sheet.
  String? _previewGarageId;

  // ─── Inline route ("Itinéraire") — drawn on this same map, no separate
  // page. Route computed server-side (route-preview, Doc/17 §4.4). Following
  // it ("Démarrer") is purely local: the position never leaves the device,
  // only the occasional recompute sends it to route-preview (not stored).
  GarageEntity? _routeGarage;
  TrackingRoute? _route;
  bool _routeLoading = false;
  String? _routeError;
  bool _navigating = false;
  bool _arrived = false;
  RouteProgress? _progress;
  StreamSubscription<Position>? _navSub;
  int _offRouteStreak = 0;
  DateTime? _lastRouteFetch;
  // Set when a recompute was skipped (local quota) or refused (429): the
  // current route stays on screen with a discreet notice.
  bool _recomputeUnavailable = false;

  static const double _offRouteThresholdM = 150;
  static const double _arrivalRadiusM = 40;
  static const Duration _minRecomputeInterval = Duration(seconds: 90);

  // route-preview is throttled at 20/h per user server-side (Doc/17 §4.4).
  // Every call counts — the first route of each "Itinéraire" included — so
  // they're all recorded here, app-wide (static: survives closing a route),
  // and capped a bit under the server limit over a sliding hour.
  static const int _routeQuotaPerHour = 18;
  static final List<DateTime> _routeFetchLog = [];

  static bool _routeQuotaAvailable() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _routeFetchLog.removeWhere((t) => t.isBefore(cutoff));
    return _routeFetchLog.length < _routeQuotaPerHour;
  }

  @override
  void initState() {
    super.initState();
    _locateUser();
    // A route may have been requested before this tab was first built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingRoute());
  }

  @override
  void dispose() {
    _navSub?.cancel();
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _consumePendingRoute() {
    if (!mounted) return;
    final garage = ref.read(pendingGarageRouteProvider);
    if (garage == null) return;
    ref.read(pendingGarageRouteProvider.notifier).state = null;
    _startRoute(garage);
  }

  Future<void> _startRoute(GarageEntity garage) async {
    await _stopNavigation();
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searching = false;
      _fittedForQuery = null;
      _detailsGarage = null;
      _routeGarage = garage;
      _route = null;
      _progress = null;
      _routeError = null;
      _arrived = false;
      _recomputeUnavailable = false;
      _routeLoading = true;
    });
    final from = await _locateUser(moveCamera: false);
    if (!mounted || _routeGarage?.id != garage.id) return;
    if (from == null) {
      setState(() {
        _routeLoading = false;
        _routeError = AppLocalizations.of(context)!.tracking_location_unavailable;
      });
      return;
    }
    await _fetchRoute(from, fit: true);
  }

  Future<void> _fetchRoute(LatLng from, {bool fit = false}) async {
    final garage = _routeGarage;
    if (garage == null) return;
    if (!_routeQuotaAvailable()) {
      _onRouteQuotaHit();
      return;
    }
    _lastRouteFetch = DateTime.now();
    _routeFetchLog.add(_lastRouteFetch!);
    try {
      final route = await ref.read(trackingRepositoryProvider).routePreview(
            lat: from.latitude,
            lng: from.longitude,
            garageId: garage.id,
          );
      if (!mounted || _routeGarage?.id != garage.id) return;
      setState(() {
        _route = route;
        _routeLoading = false;
        _routeError = null;
        _recomputeUnavailable = false;
        _offRouteStreak = 0;
        _progress = route == null
            ? null
            : RouteProgress.compute(route.geometry, from, route.durationS);
      });
      if (fit) _fitRoute(from);
    } on DioException catch (e) {
      if (!mounted || _routeGarage?.id != garage.id) return;
      if (e.response?.statusCode == 429) {
        _onRouteQuotaHit();
        return;
      }
      setState(() {
        _routeLoading = false;
        if (_route == null) {
          _routeError = AppLocalizations.of(context)!.route_load_error;
        }
      });
    } catch (_) {
      if (!mounted || _routeGarage?.id != garage.id) return;
      setState(() {
        _routeLoading = false;
        // Keep showing the previous route if a recompute fails.
        if (_route == null) {
          _routeError = AppLocalizations.of(context)!.route_load_error;
        }
      });
    }
  }

  /// Local quota reached or server 429: keep the current route (ETA keeps
  /// updating locally); with no route yet, it's an error with retry.
  void _onRouteQuotaHit() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _routeLoading = false;
      if (_route == null) {
        _routeError = l10n.route_quota_reached;
      } else {
        _recomputeUnavailable = true;
      }
    });
  }

  void _fitRoute(LatLng from) {
    final garage = _routeGarage;
    if (garage == null) return;
    final points = [
      from,
      LatLng(garage.latitude, garage.longitude),
      ...?_route?.geometry,
    ];
    _mapController.fitCamera(CameraFit.coordinates(
      coordinates: points,
      padding: const EdgeInsets.fromLTRB(40, 110, 40, 230),
    ));
  }

  Future<void> _toggleNavigation() async {
    if (_navigating) {
      await _stopNavigation();
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _navigating = true;
      _arrived = false;
    });
    _navSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen(_onNavPosition, onError: (_) {});
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 17);
    }
  }

  Future<void> _stopNavigation() async {
    await _navSub?.cancel();
    _navSub = null;
    _navigating = false;
    _offRouteStreak = 0;
  }

  void _onNavPosition(Position p) {
    final garage = _routeGarage;
    if (!mounted || garage == null) return;
    final pos = LatLng(p.latitude, p.longitude);
    final route = _route;
    final progress = route == null
        ? null
        : RouteProgress.compute(route.geometry, pos, route.durationS);

    final toGarage = Geolocator.distanceBetween(
        p.latitude, p.longitude, garage.latitude, garage.longitude);
    if (toGarage <= _arrivalRadiusM) {
      _stopNavigation();
      setState(() {
        _currentPosition = pos;
        _progress = progress;
        _arrived = true;
      });
      return;
    }

    setState(() {
      _currentPosition = pos;
      _progress = progress;
    });
    _mapController.move(pos, _mapController.camera.zoom < 16 ? 17 : _mapController.camera.zoom);

    // Off route on 2 consecutive accurate points -> recompute (same rule as
    // the server's tracking missions, Doc/17 §6), within the throttle.
    if (progress != null && p.accuracy <= 100 && progress.offRouteM > _offRouteThresholdM) {
      _offRouteStreak++;
    } else {
      _offRouteStreak = 0;
    }
    final last = _lastRouteFetch;
    if (_offRouteStreak >= 2 &&
        (last == null || DateTime.now().difference(last) >= _minRecomputeInterval)) {
      _offRouteStreak = 0;
      _fetchRoute(pos);
    }
  }

  Future<void> _closeRoute() async {
    await _stopNavigation();
    if (!mounted) return;
    setState(() {
      _routeGarage = null;
      _route = null;
      _progress = null;
      _routeError = null;
      _routeLoading = false;
      _arrived = false;
      _recomputeUnavailable = false;
    });
  }

  Future<void> _openRouteExternally() async {
    final g = _routeGarage;
    if (g == null) return;
    await launchExternalUrl(
        'https://www.google.com/maps/dir/?api=1&destination=${g.latitude},${g.longitude}');
  }

  String? _routeSummary() {
    final remainingM = _progress?.remainingM ?? _route?.distanceM;
    final remainingS = _progress?.remainingS ?? _route?.durationS;
    final parts = <String>[];
    if (remainingS != null) {
      parts.add('≈ ${(remainingS / 60).ceil().clamp(1, 24 * 60)} min');
    }
    if (remainingM != null) {
      parts.add(remainingM >= 1000
          ? '${(remainingM / 1000).toStringAsFixed(1)} km'
          : '${remainingM.round()} m');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty && _routeGarage != null) _closeRoute();
    setState(() {
      _searching = value.isNotEmpty;
      // A new search replaces whatever single-garage preview was open and
      // brings the full results drawer back.
      if (value.isNotEmpty) _detailsGarage = null;
    });
    if (value.isEmpty) {
      _fittedForQuery = null;
      return;
    }
    ref.read(garageSearchProvider.notifier).search(value);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searching = false;
      _fittedForQuery = null;
      _detailsGarage = null;
    });
  }

  /// Search-result row tap: swap the results drawer for a half-open details
  /// preview of that one garage, and center the map on it.
  void _selectGarage(GarageEntity garage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searching = false;
      _detailsGarage = garage;
    });
    if (garage.latitude != 0.0 || garage.longitude != 0.0) {
      _mapController.move(LatLng(garage.latitude, garage.longitude), 16.0);
    }
  }

  /// Straight-line distance from the user's current position — the search
  /// endpoint is a plain name/city text match, it doesn't compute this the
  /// way /garages/around/ does, so it's derived client-side to sort and
  /// display it in the results drawer.
  double? _distanceKm(GarageEntity g) {
    if (_currentPosition == null) return null;
    if (g.latitude == 0.0 && g.longitude == 0.0) return null;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          g.latitude,
          g.longitude,
        ) /
        1000;
  }

  List<GarageEntity> _sortedByDistance(List<GarageEntity> results) {
    final withDistance = results.map((g) => (g, _distanceKm(g))).toList()
      ..sort((a, b) {
        if (a.$2 == null && b.$2 == null) return 0;
        if (a.$2 == null) return 1;
        if (b.$2 == null) return -1;
        return a.$2!.compareTo(b.$2!);
      });
    return withDistance.map((pair) => pair.$1).toList();
  }

  void _goToGarageDetails(GarageEntity garage) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GarageDetails(garage: garage)),
    );
  }

  void _fitToResults(List<GarageEntity> results) {
    final points = results
        .where((g) => g.latitude != 0.0 || g.longitude != 0.0)
        .map((g) => LatLng(g.latitude, g.longitude))
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 15.0);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  void _centerUser() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    } else {
      _locateUser();
    }
  }

  Future<LatLng?> _locateUser({bool moveCamera = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return null;
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
      if (moveCamera) _mapController.move(_currentPosition!, 13.0);
      return _currentPosition;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final garagesAsync = ref.watch(garagesAroundProvider());
    final searchAsync = ref.watch(garageSearchProvider);

    // An "Itinéraire" button anywhere in the app lands here (Search tab).
    ref.listen<GarageEntity?>(pendingGarageRouteProvider, (_, next) {
      if (next != null) _consumePendingRoute();
    });

    // Fits the camera to the results once per new result set — not on every
    // rebuild the same data causes, which would fight any panning/zooming
    // the user just did to look at them.
    final searchText = _searchController.text;
    if (_searching && searchAsync.hasValue && _fittedForQuery != searchText) {
      _fittedForQuery = searchText;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _fitToResults(searchAsync.value!));
    }

    // Default center: Yaoundé, Cameroon
    final center = _currentPosition ?? const LatLng(3.848, 11.502);

    // The drawer should open tall — stopping right under the search bar, not
    // partway down the map — so its max (and default) size is computed as a
    // fraction of the screen instead of a fixed guess like 0.85.
    final screenHeight = MediaQuery.of(context).size.height;
    final searchBarBlockHeight = MediaQuery.of(context).padding.top + 80;
    final maxSheetSize =
        (1 - (searchBarBlockHeight / screenHeight)).clamp(0.5, 0.95);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12.0,
            ),
            children: [
              // ─── OpenStreetMap tiles ───
              osmTileLayer(),

              // ─── Inline route to the selected garage ───
              if (_route != null && _route!.geometry.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _route!.geometry,
                    strokeWidth: 6,
                    color: colorScheme.primary,
                  ),
                ]),
              if (_routeGarage != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(_routeGarage!.latitude, _routeGarage!.longitude),
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: Icon(Icons.location_on,
                        size: 44, color: colorScheme.primary),
                  ),
                ]),

              // ─── User position marker ───
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.my_location,
                        color: colorScheme.primary,
                        size: 36,
                      ),
                    ),
                  ],
                ),

              // ─── Garage markers — search matches while searching, nearby
              // garages otherwise ───
              (_searching ? searchAsync : garagesAsync).maybeWhen(
                data: (garages) => MarkerLayer(
                  markers: [
                    for (final g in garages)
                      if (g.latitude != 0.0 || g.longitude != 0.0)
                        Marker(
                          point: LatLng(g.latitude, g.longitude),
                          width: g.id == _previewGarageId ? 58 : 44,
                          height: g.id == _previewGarageId ? 58 : 44,
                          child: GestureDetector(
                            onTap: () => _showGarageSheet(context, g, garages),
                            child: Container(
                              decoration: BoxDecoration(
                                color: g.id == _previewGarageId
                                    ? colorScheme.secondary
                                    : colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white,
                                    width: g.id == _previewGarageId ? 3 : 2),
                              ),
                              child: Icon(Icons.build,
                                  color: Colors.white,
                                  size: g.id == _previewGarageId ? 28 : 22),
                            ),
                          ),
                        ),
                  ],
                ),
                orElse: () => const MarkerLayer(markers: []),
              ),
            ],
          ),

          // ─── Loading garage indicator ───
          if (garagesAsync.isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: colorScheme.primary)),
                      const SizedBox(width: 8),
                      Text(translator.garage_loading, style: appStyle.H6()),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Recenter-on-me button — was a HomeScreen appBar action
          // ("Ma position") before that appBar got trimmed down to just
          // title/settings/notifications; this is where the action
          // actually applies, so it moved into this screen's own body ───
          if (!_searching && _detailsGarage == null)
            Positioned(
              right: 16,
              // Sits above the route card while a route is shown.
              bottom: _routeGarage != null ? 190 : 16,
              child: SafeArea(
                child: FloatingActionButton.small(
                  heroTag: 'recenter',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  onPressed: _centerUser,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ),

          // ─── Route card: ETA + start/stop following + external nav ───
          if (_routeGarage != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: _buildRouteCard(context, appStyle, colorScheme, translator),
              ),
            ),

          // ─── Search bar ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: appStyle.H6(),
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: translator.garage_search_hint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Search results drawer — scrollable, sorted nearest-first,
          // tapping a result goes straight to its details page ───
          if (_searching)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: maxSheetSize,
              minChildSize: 0.15,
              maxChildSize: maxSheetSize,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: searchAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text('${translator.error_prefix}: $e',
                          style: appStyle.H6()),
                    ),
                    data: (results) {
                      final sorted = _sortedByDistance(results);
                      return Column(
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                sorted.isEmpty
                                    ? translator.garage_none_found
                                    : translator.garage_results_count(
                                        sorted.length,
                                        sorted.length > 1 ? 's' : ''),
                                style: appStyle.H5(weight: 'bold'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: sorted.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, indent: 16, endIndent: 16),
                              itemBuilder: (context, index) {
                                final g = sorted[index];
                                return _SearchResultTile(
                                  garage: g,
                                  distanceKm: _distanceKm(g),
                                  onTap: () => _selectGarage(g),
                                  onDirections: () => openGarageRoute(context, ref, g),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),

          // ─── Single-garage details preview — replaces the results drawer
          // once a row's tapped, half-open, until a new search or dismissed —
          // the same full GarageDetailView the pushed-page details screen
          // uses, not just a compact summary ───
          if (_detailsGarage != null)
            DraggableScrollableSheet(
              initialChildSize: maxSheetSize / 2,
              minChildSize: 0.15,
              maxChildSize: maxSheetSize,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10)
                      ],
                    ),
                    child: GarageDetailView(
                      garage: _detailsGarage!,
                      scrollController: scrollController,
                      leadingIcon: Icons.keyboard_arrow_down,
                      onLeadingPressed: () =>
                          setState(() => _detailsGarage = null),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, AppStyle appStyle,
      ColorScheme colorScheme, AppLocalizations translator) {
    final summary = _routeSummary();
    final String status;
    if (_arrived) {
      status = translator.route_arrived;
    } else if (_routeLoading) {
      status = translator.garage_loading;
    } else if (_routeError != null) {
      status = _routeError!;
    } else {
      status = summary != null
          ? '${translator.tracking_eta_label} : $summary'
          : translator.tracking_no_eta;
    }

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_routeGarage!.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appStyle.H5(weight: 'bold')),
                ),
                IconButton(
                  tooltip: translator.route_close,
                  icon: const Icon(Icons.close),
                  onPressed: _closeRoute,
                ),
              ],
            ),
            if (_routeLoading) const LinearProgressIndicator(),
            Text(
              status,
              style: appStyle.H6(
                  color: _routeError != null && !_arrived ? Colors.redAccent : null),
            ),
            if (_recomputeUnavailable && !_arrived)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(translator.route_recompute_unavailable,
                    style: appStyle.H6(color: Colors.grey)),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _routeError != null && _route == null
                      ? OutlinedButton.icon(
                          onPressed: () => _startRoute(_routeGarage!),
                          icon: const Icon(Icons.refresh),
                          label: Text(translator.retry),
                        )
                      : ElevatedButton.icon(
                          onPressed: _route == null || _arrived
                              ? null
                              : _toggleNavigation,
                          icon: Icon(_navigating ? Icons.stop : Icons.navigation),
                          label: Text(_navigating
                              ? translator.route_stop
                              : translator.route_start),
                        ),
                ),
                IconButton(
                  tooltip: translator.route_open_external,
                  icon: const Icon(Icons.open_in_new),
                  onPressed: _openRouteExternally,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Marker-tap preview. Swiping left/right switches to the neighbouring
  /// garage among those currently on the map — ordered west→east, so the
  /// swipe direction matches where the next garage actually is — and each
  /// switch recentres the map on it.
  void _showGarageSheet(
      BuildContext context, GarageEntity garage, List<GarageEntity> onMap) {
    final colorScheme = Theme.of(context).colorScheme;
    final garages = onMap
        .where((g) => g.latitude != 0.0 || g.longitude != 0.0)
        .toList()
      ..sort((a, b) => a.longitude.compareTo(b.longitude));
    var index = garages.indexWhere((g) => g.id == garage.id);
    if (index < 0) {
      garages.insert(0, garage);
      index = 0;
    }

    void focus(GarageEntity g) {
      setState(() => _previewGarageId = g.id);
      _mapController.move(LatLng(g.latitude, g.longitude),
          _mapController.camera.zoom < 14 ? 15 : _mapController.camera.zoom);
    }

    focus(garages[index]);
    // Kept outside the sheet builder so it survives the rebuild it triggers.
    var slideFromRight = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      // Light barrier: the map (and the recentring) stays visible behind.
      barrierColor: Colors.black12,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final current = garages[index];

          void go(int delta) {
            final next = index + delta;
            if (next < 0 || next >= garages.length) return;
            slideFromRight = delta > 0;
            setSheetState(() => index = next);
            focus(garages[next]);
          }

          return SafeArea(
            top: false,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -200) go(1); // swipe left → next (east)
                if (v > 200) go(-1); // swipe right → previous (west)
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle + position among the map's garages
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.chevron_left),
                          onPressed: index > 0 ? () => go(-1) : null,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              if (garages.length > 1)
                                Text('${index + 1} / ${garages.length}',
                                    style: AppStyle.of(context)
                                        .H6(color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              index < garages.length - 1 ? () => go(1) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(slideFromRight ? 0.25 : -0.25, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(current.id),
                        child: _garagePreviewContent(
                          context,
                          current,
                          onSeeDetails: () {
                            Navigator.pop(sheetContext);
                            _goToGarageDetails(current);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _previewGarageId = null);
    });
  }

  /// Photo/name/rating/status + call/directions + "voir la fiche complète" —
  /// shared by the marker-tap modal and the search-result details drawer so
  /// the two previews stay identical instead of drifting apart.
  Widget _garagePreviewContent(
    BuildContext context,
    GarageEntity garage, {
    required VoidCallback onSeeDetails,
  }) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;
    final isOpen = isGarageOpenNow(garage);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: garage.photo.isNotEmpty
                  ? Image.network(
                      garage.photo,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.garage_outlined),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.garage_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(garage.nom, style: appStyle.H4(weight: 'bold')),
                  const SizedBox(height: 2),
                  Text('${garage.ville}, ${garage.pays}',
                      style: appStyle.H6(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 2),
                          Text(
                            garage.rating > 0
                                ? garage.rating.toStringAsFixed(1)
                                : '—',
                            style: appStyle.H6(weight: 'bold'),
                          ),
                        ],
                      ),
                      if (garage.distance > 0)
                        Text('${garage.distance.toStringAsFixed(1)} km',
                            style: appStyle.H6()),
                      if (isOpen != null)
                        Text(
                          isOpen ? translator.garage_open : translator.garage_closed,
                          style: appStyle.H6(
                            weight: 'bold',
                            color: isOpen ? Colors.green : colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (garage.telephone1.isNotEmpty)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      launchExternalUrl('tel:${garage.telephone1}'),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: Text(translator.action_call),
                ),
              ),
            if (garage.telephone1.isNotEmpty &&
                (garage.latitude != 0.0 || garage.longitude != 0.0))
              const SizedBox(width: 10),
            if (garage.latitude != 0.0 || garage.longitude != 0.0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openGarageRoute(context, ref, garage),
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: Text(translator.action_directions),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSeeDetails,
            child: Text(translator.garage_see_full_details),
          ),
        ),
      ],
    );
  }
}

/// A search-drawer row — richer than a plain ListTile since this is the
/// user's main way of judging matches before committing to open one:
/// photo, rating, open/closed, and the distance computed client-side.
class _SearchResultTile extends StatelessWidget {
  final GarageEntity garage;
  final double? distanceKm;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  const _SearchResultTile({
    required this.garage,
    required this.distanceKm,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;
    final isOpen = isGarageOpenNow(garage);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: garage.photo.isNotEmpty
                      ? Image.network(
                          garage.photo,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.garage_outlined),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.garage_outlined),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(garage.nom,
                          style: appStyle.H5(weight: 'bold'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${garage.ville}, ${garage.pays}',
                          style:
                              appStyle.H6(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 15, color: colorScheme.primary),
                          const SizedBox(width: 2),
                          Text(
                            garage.rating > 0
                                ? garage.rating.toStringAsFixed(1)
                                : '—',
                            style: appStyle.H6(weight: 'bold'),
                          ),
                          if (isOpen != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              isOpen
                                  ? translator.garage_open
                                  : translator.garage_closed,
                              style: appStyle.H6(
                                weight: 'bold',
                                color:
                                    isOpen ? Colors.green : colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (distanceKm != null)
                      Text('${distanceKm!.toStringAsFixed(1)} km',
                          style: appStyle.H6(weight: 'bold')),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: Text(translator.action_directions),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
