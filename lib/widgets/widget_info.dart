import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/news/domain/entities/news_entity.dart';
import 'package:munturai/screens/news_detail.dart';
import 'package:share_plus/share_plus.dart';

import '../core/fonctions.dart';

/// Carte d'actualité affichant un NewsEntity.
/// [news]      – entité NewsEntity (Riverpod)
/// [clickable] – navigation vers NewsDetailScreen au tap
/// [onLike]    – callback like/unlike (géré par le parent via Riverpod)
class WidgetInfo extends StatelessWidget {
  final NewsEntity news;
  final bool clickable;
  final VoidCallback? onLike;

  const WidgetInfo({
    super.key,
    required this.news,
    this.clickable = true,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);

    return GestureDetector(
      onTap: () {
        if (clickable) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => NewsDetailScreen(newsId: news.id)),
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre ─────────────────────────────────────────────
            Text(news.title, style: appStyle.H5(weight: 'bold')),
            Padding(padding: getPadding(top: 15)),

            // ── Image ─────────────────────────────────────────────
            if (news.image.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: news.image.startsWith('http')
                        ? NetworkImage(news.image) as ImageProvider
                        : AssetImage(news.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(padding: getPadding(top: 5)),

            // ── Extrait ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                news.contenu != 'none' ? news.contenu : '',
                style: appStyle.H5(),
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(padding: getPadding(top: 8)),

            // ── Actions ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.timelapse, size: 16),
                  Padding(padding: getPadding(left: 5)),
                  Text(
                    _getDuree(news.time.toDouble()),
                    style: appStyle.H5(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Like button
                  GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      news.liked ? Icons.favorite : Icons.favorite_border,
                      color: news.liked ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(news.likes.toString(), style: appStyle.H5()),
                  const SizedBox(width: 16),

                  // Commentaires
                  const Icon(Icons.messenger_outline, size: 18),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (clickable) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => NewsDetailScreen(newsId: news.id)));
                      }
                    },
                    child: Text(news.comments.toString(), style: appStyle.H5()),
                  ),
                  const SizedBox(width: 16),

                  // Partager
                  GestureDetector(
                    onTap: () => Share.share(
                        'muntur: Je partage avec vous l\'info ${news.path}'),
                    child: const Icon(Icons.share, size: 18),
                  ),
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  String _getDuree(double time) {
    final double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    final double periode = actual - time;
    if (periode / 3600 < 1) return '${(periode / 60).floor()} min';
    if (periode / 3600 < 24) return '${(periode / 3600).floor()} h';
    return '${(periode / (3600 * 24)).floor()} j';
  }
}
