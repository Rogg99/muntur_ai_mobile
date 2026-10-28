import 'package:intl/intl.dart';

/// "14:32 (9 min · 3.1 km)" — estimated arrival as a 24 h HH:mm clock time,
/// with the remaining time/distance after it. [arrivalAt] (server ISO
/// timestamp, Doc/17 eta.arrival_at) wins over now + [remainingS] when given.
String? formatEta({double? remainingS, double? remainingM, String? arrivalAt}) {
  DateTime? arrival = arrivalAt != null ? DateTime.tryParse(arrivalAt)?.toLocal() : null;
  if (arrival == null && remainingS != null) {
    arrival = DateTime.now().add(Duration(seconds: remainingS.round()));
  }

  final details = <String>[];
  if (remainingS != null) {
    details.add('${(remainingS / 60).ceil().clamp(1, 24 * 60)} min');
  }
  if (remainingM != null) {
    details.add(remainingM >= 1000
        ? '${(remainingM / 1000).toStringAsFixed(1)} km'
        : '${remainingM.round()} m');
  }

  if (arrival == null) return details.isEmpty ? null : details.join(' · ');
  final clock = DateFormat('HH:mm').format(arrival);
  return details.isEmpty ? clock : '$clock (${details.join(' · ')})';
}
