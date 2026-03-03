import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/news/presentation/providers/news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  final String newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final newsAsync = ref.watch(newsDetailProvider(newsId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: newsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (news) {
          if (news == null) {
            return Center(
                child: Text('Article introuvable', style: appStyle.H5()));
          }
          return CustomScrollView(
            slivers: [
              // ─── AppBar avec image en hero ───
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: news.image.isNotEmpty
                      ? Image.network(news.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest))
                      : Container(color: colorScheme.surfaceContainerHighest),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ─── Titre ───
                    Text(news.title, style: appStyle.H3(weight: 'bold')),
                    const SizedBox(height: 12),

                    // ─── Likes + Commentaires ───
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref
                              .read(newsListProvider.notifier)
                              .toggleLike(news.id),
                          child: Icon(
                            news.liked ? Icons.favorite : Icons.favorite_border,
                            color: news.liked
                                ? Colors.redAccent
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${news.likes} likes', style: appStyle.H6()),
                        const SizedBox(width: 16),
                        Icon(Icons.comment_outlined,
                            color: colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text('${news.comments} commentaires',
                            style: appStyle.H6()),
                        const Spacer(),
                        if (news.time > 0)
                          Text(
                            _formatDate(news.time),
                            style: appStyle.H6(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // ─── Contenu ───
                    Text(news.contenu, style: appStyle.H5()),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
