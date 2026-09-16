import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_order_tracking.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations l10n) => {
      'pending_payment': l10n.status_pending_payment,
      'escrow_held': l10n.status_escrow_held,
      'delivered_pending_pin': l10n.status_delivered_pending_pin,
      'completed': l10n.status_completed,
      'returned': l10n.status_returned,
      'cancelled': l10n.status_cancelled,
      'disputed': l10n.status_disputed,
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

/// Buyer's marketplace order history — tap an order for its tracking
/// screen (status, PIN reveal, return action).
class MarketplaceOrders extends ConsumerWidget {
  const MarketplaceOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(marketplaceMyOrdersProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_my_orders_title),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.marketplace_orders_load_error, style: appStyle.H5())),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
                child: Text(l10n.marketplace_no_orders,
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
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColors[order.status] ?? Colors.grey;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MarketplaceOrderTracking(orderId: order.id)),
      ),
      child: Container(
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
                  _statusLabels(l10n)[order.status] ?? order.status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.vendor.shopName} · ${l10n.marketplace_qty_label} ${order.quantity} · ${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
            style: appStyle.H6(color: Colors.grey),
          ),
        ],
      ),
      ),
    );
  }
}
