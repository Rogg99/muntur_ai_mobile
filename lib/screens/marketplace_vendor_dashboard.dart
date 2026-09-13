import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_part_form.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

const Map<String, String> _statusLabels = {
  'pending_payment': 'Paiement en attente',
  'escrow_held': 'Payé — en séquestre',
  'delivered_pending_pin': 'Livré — en attente de PIN',
  'completed': 'Terminée',
  'returned': 'Retournée',
  'cancelled': 'Annulée',
  'disputed': 'Litige',
};

/// Vendor's own dashboard: subscription status, catalog management, and
/// orders received against their listings. Subscribing to the marketplace
/// (5,000 XAF/month) isn't wired here — that's phase 3d (payment) — so this
/// screen assumes the account either already has an active subscription or
/// will see the "subscription not active" error when trying to publish.
class MarketplaceVendorDashboard extends ConsumerWidget {
  const MarketplaceVendorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final dashboardAsync = ref.watch(marketplaceVendorDashboardProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Ma boutique'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const MarketplacePartForm()),
          );
          if (created == true) ref.invalidate(marketplaceVendorDashboardProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une pièce'),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Impossible de charger votre boutique. Avez-vous déjà créé un profil vendeur ?",
              textAlign: TextAlign.center,
              style: appStyle.H5(),
            ),
          ),
        ),
        data: (dashboard) {
          if (dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Aucun profil vendeur pour ce compte.",
                  textAlign: TextAlign.center,
                  style: appStyle.H5(),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(marketplaceVendorDashboardProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(dashboard.vendor.shopName,
                          style: appStyle.H3(weight: 'bold')),
                    ),
                    if (dashboard.vendor.verified)
                      Icon(Icons.verified, color: colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (dashboard.vendor.subscriptionActive ? Colors.green : Colors.red)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dashboard.vendor.subscriptionActive
                        ? 'Abonnement actif'
                        : 'Abonnement inactif — catalogue masqué du marketplace',
                    style: TextStyle(
                      color: dashboard.vendor.subscriptionActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Mon catalogue (${dashboard.catalog.length})',
                    style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 12),
                if (dashboard.catalog.isEmpty)
                  Text('Aucune pièce publiée pour le moment.', style: appStyle.H5())
                else
                  ...dashboard.catalog.map((part) => _CatalogTile(part: part)),
                const SizedBox(height: 24),
                Text('Commandes reçues (${dashboard.orders.length})',
                    style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 12),
                if (dashboard.orders.isEmpty)
                  Text('Aucune commande pour le moment.', style: appStyle.H5())
                else
                  ...dashboard.orders.map((order) => _ReceivedOrderTile(order: order)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CatalogTile extends ConsumerWidget {
  const _CatalogTile({required this.part});

  final PartListing part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final photo = part.medias.isNotEmpty ? part.medias.first.file : null;

    return Container(
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
                Text(part.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: appStyle.H5(weight: 'bold')),
                Text('${part.price.toStringAsFixed(0)} ${part.currency} · stock ${part.stockQuantity}',
                    style: appStyle.H6(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => MarketplacePartForm(existing: part)),
              );
              if (updated == true) ref.invalidate(marketplaceVendorDashboardProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Supprimer cette pièce ?'),
                  content: Text(part.title),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Supprimer')),
                  ],
                ),
              );
              if (confirmed != true) return;
              try {
                await ref.read(marketplaceRepositoryProvider).deletePart(part.id);
                ref.invalidate(marketplaceVendorDashboardProvider);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Suppression impossible.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ReceivedOrderTile extends StatelessWidget {
  const _ReceivedOrderTile({required this.order});

  final MarketplaceOrder order;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.listing.title, style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 4),
          Text(
            '${order.buyer.fullName.isNotEmpty ? order.buyer.fullName : "Client"} · Qté ${order.quantity} · ${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
            style: appStyle.H6(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(_statusLabels[order.status] ?? order.status,
              style: appStyle.H6(color: colorScheme.primary)),
        ],
      ),
    );
  }
}
