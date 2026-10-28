import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/osm_tile_layer.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Lets the user choose a point on the OSM map (delivery address, on-site
/// repair location). Doc/17 §2.1: the destination is always this chosen
/// point, never the raw GPS fix — GPS only pre-centres the map. The pin is
/// fixed at the centre and the map moves under it; pops the chosen [LatLng],
/// or null if dismissed.
class MapPointPicker extends StatefulWidget {
  const MapPointPicker({super.key, required this.title, this.initialPoint});

  final String title;
  final LatLng? initialPoint;

  @override
  State<MapPointPicker> createState() => _MapPointPickerState();
}

class _MapPointPickerState extends State<MapPointPicker> {
  static const LatLng _fallbackCenter = LatLng(3.848, 11.502); // Yaoundé

  final MapController _mapController = MapController();
  bool _mapReady = false;

  Future<void> _centerOnUser() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      if (!mounted || !_mapReady) return;
      _mapController.move(LatLng(pos.latitude, pos.longitude), 16);
    } catch (_) {
      // Best effort: the user can still pan to the right place.
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: widget.title),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialPoint ?? _fallbackCenter,
              initialZoom: widget.initialPoint != null ? 16 : 13,
              onMapReady: () {
                _mapReady = true;
                if (widget.initialPoint == null) _centerOnUser();
              },
            ),
            children: [osmTileLayer()],
          ),
          // Fixed centre pin — its tip sits on the map centre.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child:
                    Icon(Icons.location_on, size: 48, color: colorScheme.primary),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.map_picker_hint,
                    style: appStyle.H6(), textAlign: TextAlign.center),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: FloatingActionButton.small(
              heroTag: 'map_point_picker_locate',
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: PrimaryButton(
              text: l10n.map_picker_confirm,
              onPressed: () =>
                  Navigator.pop(context, _mapController.camera.center),
            ),
          ),
        ],
      ),
    );
  }
}
