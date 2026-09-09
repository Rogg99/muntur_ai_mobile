import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/home_refresh.dart';
import 'package:munturai/features/news/domain/entities/news_entity.dart';
import 'package:munturai/features/news/presentation/providers/news_provider.dart';
import 'package:munturai/screens/news_detail.dart';

class Infos extends ConsumerWidget {
  const Infos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final newsAsync = ref.watch(newsListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: newsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (news) {
          if (news.isEmpty) {
            // Still wrapped in RefreshIndicator + AlwaysScrollableScrollPhysics
            // + a full-height child — without those, there's nothing to
            // overflow-scroll and the pull gesture never registers.
            return RefreshIndicator(
              onRefresh: () => refreshAllHomeData(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text('Aucune actualité', style: appStyle.H5()),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            // Refreshes every home tab, not just news — there's no
            // pull-to-refresh possible on the Search/map tab, so this is
            // what keeps its data current too.
            onRefresh: () => refreshAllHomeData(ref),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: news.length,
              itemBuilder: (ctx, i) {
                final item = news[i];
                return _InfoCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends ConsumerWidget {
  final NewsEntity item;
  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NewsDetailScreen(newsId: item.id)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  item.image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 160),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: appStyle.H4(weight: 'bold'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.favorite_border,
                          size: 16, color: colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text('${item.likes}', style: appStyle.H6()),
                      const SizedBox(width: 12),
                      Icon(Icons.comment_outlined,
                          size: 16, color: colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text('${item.comments}', style: appStyle.H6()),
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
}
