import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
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

const Map<String, Color> _statusColors = {
  'pending_payment': Colors.orange,
  'escrow_held': Colors.blue,
  'delivered_pending_pin': Colors.blue,
  'completed': Colors.green,
  'returned': Colors.grey,
  'cancelled': Colors.grey,
  'disputed': Colors.red,
};

/// Buyer's marketplace order history — read-only. No detail drill-down yet:
/// the PIN/delivery/return actions that would live there depend on phase 3b
/// (payment), not shipped.
class MarketplaceOrders extends ConsumerWidget {
  const MarketplaceOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final ordersAsync = ref.watch(marketplaceMyOrdersProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Mes commandes'),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Impossible de charger vos commandes.', style: appStyle.H5())),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
                child: Text('Aucune commande marketplace pour le moment.',
                    style: appStyle.H5()));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(marketplaceMyOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _OrderTile(order: orders[index]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final MarketplaceOrder order;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColors[order.status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appStyle.H5(weight: 'bold')),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabels[order.status] ?? order.status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.vendor.shopName} · Qté ${order.quantity} · ${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
            style: appStyle.H6(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
