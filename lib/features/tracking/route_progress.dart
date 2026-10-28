import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Where a position stands along a route polyline — same local ETA rule as
/// the server (Doc/17 §6): the position is projected on the route,
/// `remainingM` is the length left, `remainingS` = duration × fraction left.
class RouteProgress {
  final double remainingM;
  final double? remainingS;

  /// Distance from the position to the polyline — used to detect leaving the
  /// route (> 150 m on 2 consecutive points triggers a recompute).
  final double offRouteM;

  /// The route still ahead: the position's projection on the polyline, then
  /// every following vertex — drawn instead of the full route while
  /// following, so the travelled part disappears.
  final List<LatLng> remainingPath;

  const RouteProgress({
    required this.remainingM,
    this.remainingS,
    required this.offRouteM,
    this.remainingPath = const [],
  });

  static const Distance _distance = Distance();

  static RouteProgress? compute(
      List<LatLng> route, LatLng position, double? totalDurationS) {
    if (route.length < 2) return null;

    // Cumulative length from the start to each vertex.
    final cumulative = <double>[0];
    for (var i = 1; i < route.length; i++) {
      cumulative.add(cumulative[i - 1] + _distance(route[i - 1], route[i]));
    }
    final total = cumulative.last;
    if (total <= 0) return null;

    // Closest point on any segment, in a local equirectangular projection
    // (plenty accurate over a few hundred metres).
    var bestOff = double.infinity;
    var bestAlong = 0.0;
    var bestSegment = 0;
    LatLng? bestProj;
    for (var i = 0; i < route.length - 1; i++) {
      final a = route[i];
      final b = route[i + 1];
      final cosLat = _cosDeg(position.latitude);
      final ax = a.longitude * cosLat, ay = a.latitude;
      final bx = b.longitude * cosLat, by = b.latitude;
      final px = position.longitude * cosLat, py = position.latitude;
      final dx = bx - ax, dy = by - ay;
      final len2 = dx * dx + dy * dy;
      var t = len2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / len2;
      t = t.clamp(0.0, 1.0);
      final proj = LatLng(ay + t * dy, (ax + t * dx) / cosLat);
      final off = _distance(position, proj);
      if (off < bestOff) {
        bestOff = off;
        bestAlong = cumulative[i] + t * (cumulative[i + 1] - cumulative[i]);
        bestSegment = i;
        bestProj = proj;
      }
    }

    final remaining = (total - bestAlong).clamp(0.0, total);
    return RouteProgress(
      remainingM: remaining,
      remainingS:
          totalDurationS == null ? null : totalDurationS * remaining / total,
      offRouteM: bestOff,
      remainingPath: [
        if (bestProj != null) bestProj,
        ...route.sublist(bestSegment + 1),
      ],
    );
  }

  static double _cosDeg(double deg) => math.cos(deg * math.pi / 180);
}
