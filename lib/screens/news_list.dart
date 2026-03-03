import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/news/domain/entities/news_entity.dart';
import 'package:munturai/features/news/presentation/providers/news_provider.dart';
import 'package:munturai/screens/news_detail.dart';

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final newsAsync = ref.watch(newsListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        title: Text('Actualités', style: appStyle.H3(weight: 'bold')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(newsListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: newsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (news) {
          if (news.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.newspaper,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('Aucune actualité disponible', style: appStyle.H5()),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    onPressed: () =>
                        ref.read(newsListProvider.notifier).refresh(),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(newsListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: news.length,
              itemBuilder: (ctx, i) => _NewsCard(news: news[i]),
            ),
          );
        },
      ),
    );
  }
}

class _NewsCard extends ConsumerWidget {
  final NewsEntity news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewsDetailScreen(newsId: news.id),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  news.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.newspaper,
                        size: 48, color: colorScheme.onSurface),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news.title,
                      style: appStyle.H4(weight: 'bold'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    news.contenu,
                    style: appStyle.H6(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
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
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${news.likes}', style: appStyle.H6()),
                      const SizedBox(width: 16),
                      Icon(Icons.comment_outlined,
                          size: 18, color: colorScheme.onSurface),
                      const SizedBox(width: 6),
                      Text('${news.comments}', style: appStyle.H6()),
                      const Spacer(),
                      Text(
                        _formatDate(news.time),
                        style: appStyle.H6(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
