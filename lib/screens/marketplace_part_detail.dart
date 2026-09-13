import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_vendor.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Read-only part detail — "Acheter" is disabled until checkout/escrow
/// (phase 3b) ships; wiring it now would mean redoing the flow once the
/// real payment contract lands.
class MarketplacePartDetail extends ConsumerWidget {
  const MarketplacePartDetail({super.key, required this.partId});

  final int partId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final partAsync = ref.watch(marketplacePartDetailProvider(partId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Détail de la pièce'),
      body: partAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Impossible de charger cette pièce.', style: appStyle.H5()),
        ),
        data: (part) {
          if (part == null) {
            return Center(child: Text('Pièce introuvable.', style: appStyle.H5()));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (part.medias.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: PageView(
                    children: part.medias
                        .map((m) => ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                ApiClient.resolveMediaUrl(m.file),
                                fit: BoxFit.cover,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Text(part.title, style: appStyle.H3(weight: 'bold')),
              const SizedBox(height: 6),
              Text(
                '${part.price.toStringAsFixed(0)} ${part.currency}',
                style: appStyle.H3(weight: 'bold', color: colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Chip(text: part.condition == 'brand_new' ? 'Neuf' : 'Occasion'),
                  const SizedBox(width: 8),
                  _Chip(text: '${part.stockQuantity} en stock'),
                  if (part.vendor.pricePartyAgreed) ...[
                    const SizedBox(width: 8),
                    const _Chip(text: 'Prix boutique garanti', color: Colors.blue),
                  ],
                ],
              ),
              if (part.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(part.description, style: appStyle.H5()),
              ],
              if (part.compatibleVehicles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Véhicules compatibles', style: appStyle.H5(weight: 'bold')),
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
                Text('Références OEM', style: appStyle.H5(weight: 'bold')),
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Achat avec escrow bientôt disponible sur cette pièce.')),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                  child: const Text('Acheter avec Escrow Protégé — bientôt disponible'),
                ),
              ),
            ],
          );
        },
      ),
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
