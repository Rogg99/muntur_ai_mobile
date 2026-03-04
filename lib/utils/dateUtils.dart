import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initDateFormattingForLocale(String locale) async {
  await initializeDateFormatting(locale, null);
}

String getDureeWhatsapp(int timestampInSeconds, String locale) {
  final now = DateTime.now();
  final date =
      DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000).toLocal();

  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return locale.startsWith('fr') ? 'à l’instant' : 'just now';
  }

  if (difference.inMinutes < 60) {
    return locale.startsWith('fr')
        ? 'il y a ${difference.inMinutes} min'
        : '${difference.inMinutes} min ago';
  }

  if (difference.inHours < 24) {
    return locale.startsWith('fr')
        ? 'il y a ${difference.inHours} h'
        : '${difference.inHours} h ago';
  }

  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(date.year, date.month, date.day);
  final dayDifference = today.difference(messageDay).inDays;

  if (dayDifference == 1) {
    return locale.startsWith('fr') ? 'Hier' : 'Yesterday';
  }

  if (dayDifference == 2 && locale.startsWith('fr')) {
    return 'Avant-hier';
  }

  if (dayDifference < 7) {
    return DateFormat.EEEE(locale).format(date);
  }

  if (now.year == date.year) {
    return DateFormat('dd MMM', locale).format(date);
  }

  return DateFormat('dd MMM yyyy', locale).format(date);
}

String getLocalizedDate(String time, String locale) {
  final now = DateTime.now();
  final date = DateTime.parse(time).toLocal();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return locale.startsWith('fr') ? 'à l’instant' : 'just now';
  }

  if (difference.inMinutes < 60) {
    return locale.startsWith('fr')
        ? 'il y a ${difference.inMinutes} min'
        : '${difference.inMinutes} min ago';
  }

  if (difference.inHours < 24) {
    return DateFormat.Hm(locale).format(date); // 14:32
  }

  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(date.year, date.month, date.day);
  final dayDifference = today.difference(messageDay).inDays;

  if (dayDifference == 1) {
    return locale.startsWith('fr') ? 'Hier' : 'Yesterday';
  }

  if (dayDifference < 7) {
    return DateFormat.EEEE(locale).format(date); // Monday / Lundi
  }

  if (now.year == date.year) {
    return DateFormat('dd MMM', locale).format(date);
  }

  return DateFormat('dd MMM yyyy', locale).format(date);
}
