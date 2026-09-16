import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_part_detail.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// "Mes favoris" — saved parts. No price/stock notifications for now
/// (matches the backend contract), just a plain saved list.
class MarketplaceWishlist extends ConsumerWidget {
  const MarketplaceWishlist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final wishlistAsync = ref.watch(marketplaceWishlistProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_my_favorites_title),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.marketplace_favorites_load_error, style: appStyle.H5())),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(l10n.marketplace_no_saved_parts, style: appStyle.H5()),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(marketplaceWishlistProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _WishlistTile(item: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _WishlistTile extends ConsumerWidget {
  const _WishlistTile({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final part = item.partListing;
    final photo = part.medias.isNotEmpty ? part.medias.first.file : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MarketplacePartDetail(partId: part.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: photo != null
                  ? Image.network(ApiClient.resolveMediaUrl(photo),
                      width: 64, height: 64, fit: BoxFit.cover)
                  : Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.settings_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: appStyle.H5(weight: 'bold')),
                  const SizedBox(height: 2),
                  Text('${part.price.toStringAsFixed(0)} ${part.currency}',
                      style: appStyle.H6(color: colorScheme.primary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () async {
                try {
                  await ref
                      .read(marketplaceRepositoryProvider)
                      .removeFromWishlist(part.id);
                  ref.invalidate(marketplaceWishlistProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
