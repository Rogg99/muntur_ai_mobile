import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_part_detail.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Vendor storefront: shop info + their active catalog. Read-only.
class MarketplaceVendor extends ConsumerWidget {
  const MarketplaceVendor({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final vendorAsync = ref.watch(marketplaceVendorProvider(vendorId));
    final listingsAsync = ref.watch(marketplaceVendorListingsProvider(vendorId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_shop_title),
      body: vendorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.marketplace_shop_load_error, style: appStyle.H5())),
        data: (vendor) {
          if (vendor == null) {
            return Center(child: Text(l10n.marketplace_shop_not_found, style: appStyle.H5()));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(vendor.shopName, style: appStyle.H3(weight: 'bold')),
                  ),
                  if (vendor.verified)
                    Icon(Icons.verified, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (vendor.pricePartyAgreed)
                    _Badge(text: l10n.marketplace_shop_price_guaranteed, color: Colors.blue),
                  _Badge(
                    text: vendor.subscriptionActive
                        ? l10n.marketplace_vendor_active
                        : l10n.marketplace_subscription_inactive,
                    color: vendor.subscriptionActive ? Colors.green : Colors.grey,
                  ),
                  _Badge(
                      text:
                          '${vendor.catalogCount} ${l10n.marketplace_parts_in_catalog_suffix}',
                      color: Colors.orange),
                ],
              ),
              const SizedBox(height: 20),
              Text(l10n.marketplace_catalog, style: appStyle.H4(weight: 'bold')),
              const SizedBox(height: 12),
              listingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Text(l10n.marketplace_vendor_catalog_load_error, style: appStyle.H5()),
                data: (listings) {
                  if (listings.isEmpty) {
                    return Text(l10n.marketplace_no_parts_online, style: appStyle.H5());
                  }
                  return Column(
                    children:
                        listings.map((part) => _VendorPartTile(part: part)).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VendorPartTile extends StatelessWidget {
  const _VendorPartTile({required this.part});

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
        margin: const EdgeInsets.only(bottom: 10),
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
                      width: 56, height: 56, fit: BoxFit.cover)
                  : Container(
                      width: 56,
                      height: 56,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.settings_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: appStyle.H5(weight: 'bold')),
                  Text('${part.price.toStringAsFixed(0)} ${part.currency}',
                      style: appStyle.H6(color: colorScheme.primary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
