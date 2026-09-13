import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
import 'package:munturai/screens/garage.dart';

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

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
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

  Future<void> _locateUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_currentPosition!, 13.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);
    final garagesAsync = ref.watch(garagesAroundProvider());
    final searchAsync = ref.watch(garageSearchProvider);

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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.munturai.app',
              ),

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
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _showGarageSheet(context, g),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.build,
                                  color: Colors.white, size: 22),
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
                      Text('Chargement des garages…', style: appStyle.H6()),
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
              bottom: 16,
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
                      hintText: 'Rechercher un garage…',
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
                      child: Text('Erreur : $e', style: appStyle.H6()),
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
                                    ? 'Aucun garage trouvé'
                                    : '${sorted.length} garage${sorted.length > 1 ? 's' : ''} trouvé${sorted.length > 1 ? 's' : ''}',
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
                                  onDirections: () => launchExternalUrl(
                                      'https://www.google.com/maps/search/?api=1&query=${g.latitude},${g.longitude}'),
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

  void _showGarageSheet(BuildContext context, GarageEntity garage) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _garagePreviewContent(
                context,
                garage,
                onSeeDetails: () {
                  Navigator.pop(sheetContext);
                  _goToGarageDetails(garage);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
                          isOpen ? 'Ouvert' : 'Fermé',
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
                  label: const Text('Appeler'),
                ),
              ),
            if (garage.telephone1.isNotEmpty &&
                (garage.latitude != 0.0 || garage.longitude != 0.0))
              const SizedBox(width: 10),
            if (garage.latitude != 0.0 || garage.longitude != 0.0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => launchExternalUrl(
                      'https://www.google.com/maps/search/?api=1&query=${garage.latitude},${garage.longitude}'),
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: const Text('Itinéraire'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSeeDetails,
            child: const Text('Voir la fiche complète'),
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
                              isOpen ? 'Ouvert' : 'Fermé',
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
                  label: const Text('Itinéraire'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
