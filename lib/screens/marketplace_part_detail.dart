import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_checkout.dart';
import 'package:munturai/screens/marketplace_vendor.dart';

/// Part detail with the escrow checkout entry point (phase 3b, Campay).
/// Same collapsing-header structure as GarageDetailView (garage.dart) —
/// SliverAppBar with no title (the part's name lives in the body instead)
/// and a photo area up top, here a swipeable carousel rather than one
/// static image since a listing can have several photos.
class MarketplacePartDetail extends ConsumerWidget {
  const MarketplacePartDetail({super.key, required this.partId});

  final String partId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final partAsync = ref.watch(marketplacePartDetailProvider(partId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: partAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(l10n.marketplace_part_load_error, style: appStyle.H5()),
        ),
        data: (part) {
          if (part == null) {
            return Center(child: Text(l10n.marketplace_part_not_found, style: appStyle.H5()));
          }
          return _PartDetailContent(part: part);
        },
      ),
    );
  }
}

class _PartDetailContent extends ConsumerStatefulWidget {
  const _PartDetailContent({required this.part});

  final PartListing part;

  @override
  ConsumerState<_PartDetailContent> createState() => _PartDetailContentState();
}

class _PartDetailContentState extends ConsumerState<_PartDetailContent> {
  final _pageController = PageController();
  int _page = 0;
  bool _togglingWishlist = false;

  Future<void> _toggleWishlist(bool currentlySaved) async {
    setState(() => _togglingWishlist = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      if (currentlySaved) {
        await repo.removeFromWishlist(widget.part.id);
      } else {
        await repo.addToWishlist(widget.part.id);
      }
      ref.invalidate(marketplaceWishlistProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingWishlist = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final part = widget.part;
    final isSaved = ref.watch(marketplaceIsWishlistedProvider(part.id));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: colorScheme.surface,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: _togglingWishlist
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.redAccent : Colors.white,
                          size: 18,
                        ),
                  onPressed: _togglingWishlist ? null : () => _toggleWishlist(isSaved),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: part.medias.isEmpty
                ? Container(color: colorScheme.surfaceContainerHighest)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _page = i),
                        children: part.medias
                            .map((m) => Image.network(
                                  ApiClient.resolveMediaUrl(m.file),
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      ),
                      if (part.medias.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(part.medias.length, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active ? Colors.white : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.title, style: appStyle.H3(weight: 'bold')),
                const SizedBox(height: 6),
                Text(
                  '${part.price.toStringAsFixed(0)} ${part.currency}',
                  style: appStyle.H3(weight: 'bold', color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(
                        text: part.condition == 'brand_new'
                            ? l10n.condition_new
                            : l10n.condition_used),
                    const SizedBox(width: 8),
                    _Chip(text: '${part.stockQuantity} ${l10n.marketplace_in_stock_suffix}'),
                    if (part.vendor.pricePartyAgreed) ...[
                      const SizedBox(width: 8),
                      _Chip(text: l10n.marketplace_shop_price_guaranteed, color: Colors.blue),
                    ],
                  ],
                ),
                if (part.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(part.description, style: appStyle.H5()),
                ],
                if (part.compatibleVehicles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.marketplace_compatible_vehicles, style: appStyle.H5(weight: 'bold')),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        part.compatibleVehicles.map((v) => _Chip(text: v)).toList(),
                  ),
                ],
                if (part.oemReferences.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.marketplace_oem_references, style: appStyle.H5(weight: 'bold')),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: part.oemReferences.map((r) => _Chip(text: r)).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MarketplaceVendor(vendorId: part.vendor.id)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (part.vendor.verified)
                          Icon(Icons.verified, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(part.vendor.shopName,
                              style: appStyle.H5(weight: 'bold')),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: part.stockQuantity < 1
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MarketplaceCheckout(part: part)),
                            ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(part.stockQuantity < 1
                        ? l10n.marketplace_out_of_stock
                        : l10n.marketplace_buy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
