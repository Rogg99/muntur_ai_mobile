import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/notifications/domain/entities/notification_entity.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/fonctions.dart';

/// Tuile affichant une notification.
/// [notification] – entité NotificationEntity (Riverpod)
/// [onTap]        – callback optionnel (remplace la logique d'URL inline)
class WidgetNotification extends StatefulWidget {
  final NotificationEntity notification;
  const WidgetNotification({super.key, required this.notification});

  @override
  State<WidgetNotification> createState() => _WidgetNotificationState();
}

class _WidgetNotificationState extends State<WidgetNotification> {
  bool showFull = false;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final n = widget.notification;

    final shortText =
        n.text.length > 100 ? '${n.text.substring(0, 100)}...' : n.text;

    return GestureDetector(
      onTap: () async {
        if (n.url.startsWith('http')) {
          await launchUrlString(n.url, mode: LaunchMode.inAppWebView);
        }
      },
      child: Container(
        width: double.infinity,
        padding: getPadding(all: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar / image ───────────────────────────────────────
            if (n.image.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  n.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications,
                    size: 40,
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(ImageConstant.imgEllipse),
                  ),
                ),
              ),

            Padding(padding: getPadding(left: 15)),

            // ── Texte ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: appStyle.H5(weight: 'bold'),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (n.time > 0)
                        Text(
                          _getDuree(n.time),
                          style: appStyle.H6(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(showFull ? n.text : shortText, style: appStyle.H6()),
                  if (n.text.length != shortText.length)
                    GestureDetector(
                      onTap: () => setState(() => showFull = !showFull),
                      child: Text(
                        showFull ? translator.readLess : translator.readMore,
                        style: appStyle.H7(weight: 'bold'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDuree(num time) {
    final double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    final double periode = actual - time;
    if (periode / 3600 < 1) return '${(periode / 60).floor()} min';
    if (periode / 3600 < 24) return '${(periode / 3600).floor()} h';
    return '${(periode / (3600 * 24)).floor()} j';
  }
}
