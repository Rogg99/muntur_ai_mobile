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
  final bool? buttonPressed;
  const MapScreen({super.key, this.buttonPressed});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentPosition;
  bool _searching = false;
  // Set once the user confirms a search (Enter) — the map then shows every
  // match instead of just the nearby list, until the search is cleared.
  List<GarageEntity>? _searchMatches;

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToGarage(GarageEntity garage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searching = false);
    if (garage.latitude != 0.0 || garage.longitude != 0.0) {
      _mapController.move(LatLng(garage.latitude, garage.longitude), 15.0);
    }
    _showGarageSheet(context, garage);
  }

  /// Enter/submit on the search bar — shows every match on the map at once
  /// (fitting the camera to them), rather than just the live-typing dropdown.
  Future<void> _confirmSearch(String query) async {
    if (query.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searching = false);
    await ref.read(garageSearchProvider.notifier).search(query);
    if (!mounted) return;
    final results = ref.read(garageSearchProvider).valueOrNull ?? [];
    setState(() => _searchMatches = results);
    _fitToResults(results);
    if (results.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun garage ne correspond à cette recherche')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _searchMatches = null;
    });
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
    final buttonPressed = widget.buttonPressed ?? false;
    if (buttonPressed) {
      _centerUser();
    }

    // Default center: Yaoundé, Cameroon
    final center = _currentPosition ?? const LatLng(3.848, 11.502);

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

              // ─── Garage markers — search matches once confirmed, nearby
              // garages otherwise ───
              (_searchMatches != null
                  ? AsyncValue.data(_searchMatches!)
                  : garagesAsync)
                  .maybeWhen(
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

          // ─── Search bar + results ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
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
                        onChanged: (value) {
                          setState(() {
                            _searching = value.isNotEmpty;
                            // Typing again after a confirmed search means the
                            // old match set on the map is stale.
                            if (value.isEmpty) _searchMatches = null;
                          });
                          if (value.isNotEmpty) {
                            ref.read(garageSearchProvider.notifier).search(value);
                          }
                        },
                        onSubmitted: _confirmSearch,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un garage…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: (_searching || _searchMatches != null)
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searching)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: ref.watch(garageSearchProvider).when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              error: (e, _) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('Erreur : $e', style: appStyle.H6()),
                              ),
                              data: (results) => results.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text('Aucun garage trouvé',
                                          style: appStyle.H6()),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      itemCount: results.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final g = results[index];
                                        return ListTile(
                                          dense: true,
                                          leading: const Icon(Icons.build_outlined),
                                          title: Text(g.nom, style: appStyle.H6(weight: 'bold')),
                                          subtitle: Text('${g.ville}, ${g.pays}',
                                              style: appStyle.H6()),
                                          onTap: () => _goToGarage(g),
                                        );
                                      },
                                    ),
                            ),
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

  void _showGarageSheet(BuildContext context, GarageEntity garage) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isOpen = isGarageOpenNow(garage);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
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
                                Icon(Icons.star_rounded, size: 16, color: colorScheme.primary),
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
                        onPressed: () => launchExternalUrl('tel:${garage.telephone1}'),
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
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GarageDetails(garage: garage)),
                    );
                  },
                  child: const Text('Voir la fiche complète'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
