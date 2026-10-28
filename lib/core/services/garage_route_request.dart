import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/garages/domain/entities/garage_entity.dart';
import 'home_navigation.dart';

/// Garage the Search tab's map should draw a route to — set by any
/// "Itinéraire" button, consumed (and cleared) by MapScreen, which shows the
/// route right on the main map instead of a separate page.
final pendingGarageRouteProvider = StateProvider<GarageEntity?>((ref) => null);

/// Index of the Search (map) tab in HomeScreen's bottom nav.
const int _searchTabIndex = 1;

/// Shared entry point for every "Itinéraire" button (garage page, map
/// preview sheet, search results): lands on the Search tab with the route
/// drawn, popping whatever was pushed on top of Home.
void openGarageRoute(BuildContext context, WidgetRef ref, GarageEntity garage) {
  ref.read(pendingGarageRouteProvider.notifier).state = garage;
  ref.read(homeTabIndexProvider.notifier).state = _searchTabIndex;
  Navigator.of(context).popUntil((route) => route.isFirst);
}
