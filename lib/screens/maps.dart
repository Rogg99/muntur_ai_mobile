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
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _locateUser();
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

    // Default center: Yaoundé, Cameroon
    final center = _currentPosition ?? const LatLng(3.848, 11.502);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text('Carte', style: appStyle.H3(weight: 'bold')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Ma position',
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(_currentPosition!, 14.0);
              } else {
                _locateUser();
              }
            },
          ),
        ],
      ),
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

              // ─── Garage markers ───
              garagesAsync.maybeWhen(
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
        ],
      ),
    );
  }

  void _showGarageSheet(BuildContext context, GarageEntity garage) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(garage.nom, style: appStyle.H4(weight: 'bold')),
            const SizedBox(height: 4),
            Text('${garage.ville}, ${garage.pays}', style: appStyle.H6()),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(garage.rating.toStringAsFixed(1), style: appStyle.H6()),
                if (garage.distance > 0) ...[
                  const SizedBox(width: 12),
                  Text('${garage.distance.toStringAsFixed(1)} km',
                      style: appStyle.H6()),
                ],
              ],
            ),
            const SizedBox(height: 16),
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
                child: const Text('Voir la fiche'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
