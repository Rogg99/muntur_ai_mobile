import 'package:flutter_map/flutter_map.dart';

/// OpenStreetMap base layer shared by every map in the app (fond de carte v1
/// confirmed by the user, no tile provider). The user agent must identify the
/// real app, per the OSM tile usage policy.
TileLayer osmTileLayer() => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.munturai.stepsindustries.com.munturai',
    );
