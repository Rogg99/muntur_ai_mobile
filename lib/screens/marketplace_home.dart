import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_part_detail.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Marketplace catalogue: search + grid of parts. Read-only — buying is
/// gated behind phase 3b (payment/PIN), not shipped yet.
class MarketplaceHome extends ConsumerWidget {
  const MarketplaceHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final partsAsync = ref.watch(marketplacePartsProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Marketplace'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  ref.read(marketplaceSearchProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Rechercher une pièce...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: partsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Impossible de charger le catalogue pour l'instant.",
                    textAlign: TextAlign.center,
                    style: appStyle.H5(),
                  ),
                ),
              ),
              data: (parts) {
                if (parts.isEmpty) {
                  return Center(
                    child: Text('Aucune pièce trouvée.', style: appStyle.H5()),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(marketplacePartsProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: parts.length,
                    itemBuilder: (context, index) => _PartCard(part: parts[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part});

  final PartListing part;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final photo = part.medias.isNotEmpty ? part.medias.first.file : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MarketplacePartDetail(partId: part.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: photo != null
                  ? Image.network(ApiClient.resolveMediaUrl(photo), fit: BoxFit.cover)
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(Icons.settings_outlined,
                          size: 32, color: colorScheme.onSurfaceVariant),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appStyle.H6(weight: 'bold'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${part.price.toStringAsFixed(0)} ${part.currency}',
                    style: appStyle.H5(weight: 'bold', color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _Badge(
                        text: part.condition == 'brand_new' ? 'Neuf' : 'Occasion',
                        color: part.condition == 'brand_new'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      if (part.vendor.pricePartyAgreed)
                        const _Badge(text: 'Prix boutique garanti', color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (part.vendor.verified)
                        Icon(Icons.verified, size: 14, color: colorScheme.primary),
                      Expanded(
                        child: Text(
                          part.vendor.shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appStyle.H6(color: Colors.grey),
                        ),
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
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
