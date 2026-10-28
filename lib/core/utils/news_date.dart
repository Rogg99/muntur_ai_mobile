import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// News `time` is epoch **milliseconds** (NewsModel parses date_creation with
/// millisecondsSinceEpoch). Older cached/legacy `time` values may be in
/// seconds, so anything below 1e12 (≈ year 2001 in ms) is treated as seconds.
/// Formatted in the app locale, e.g. "28 oct. 2026" / "Oct 28, 2026".
String formatNewsDate(BuildContext context, int time) {
  if (time <= 0) return '';
  final ms = time < 1000000000000 ? time * 1000 : time;
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat.yMMMd(locale).format(dt);
  } catch (_) {
    // Locale data not loaded: plain numeric fallback.
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
