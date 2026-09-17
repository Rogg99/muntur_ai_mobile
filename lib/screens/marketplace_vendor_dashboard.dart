import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/courier_vendor_delivery.dart';
import 'package:munturai/screens/marketplace_kyc.dart';
import 'package:munturai/screens/marketplace_part_form.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final dashboardAsync = ref.watch(marketplaceVendorDashboardProvider);
    // Only offer "add a part" once we know for sure this account has a
    // vendor storefront — otherwise a non-vendor reaching this screen
    // (stale UI state, direct nav) would see a working-looking button that
    // just fails at submit with a raw backend error.
    final hasVendorProfile = dashboardAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_my_shop),
      floatingActionButton: !hasVendorProfile
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketplacePartForm()),
                );
                if (created == true) {
                  ref.invalidate(marketplaceVendorDashboardProvider);
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.marketplace_add_part),
            ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.marketplace_dashboard_load_error,
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
                  l10n.marketplace_no_vendor_profile,
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
                        ? l10n.marketplace_subscription_active
                        : l10n.marketplace_subscription_inactive_hidden,
                    style: TextStyle(
                      color: dashboard.vendor.subscriptionActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (dashboard.vendor.kycStatus != 'approved') ...[
                  const SizedBox(height: 12),
                  _KycBanner(vendor: dashboard.vendor),
                ],
                const SizedBox(height: 24),
                Text('${l10n.marketplace_my_catalog} (${dashboard.catalog.length})',
                    style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 12),
                if (dashboard.catalog.isEmpty)
                  Text(l10n.marketplace_no_parts_published, style: appStyle.H5())
                else
                  ...dashboard.catalog.map((part) => _CatalogTile(part: part)),
                const SizedBox(height: 24),
                Text('${l10n.marketplace_orders_received} (${dashboard.orders.length})',
                    style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 12),
                if (dashboard.orders.isEmpty)
                  Text(l10n.marketplace_no_orders_yet, style: appStyle.H5())
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
              final l10n = AppLocalizations.of(context)!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.marketplace_delete_part_confirm_title),
                  content: Text(part.title),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel)),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.delete)),
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
                    SnackBar(content: Text(l10n.marketplace_delete_failed)),
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

class _ReceivedOrderTile extends ConsumerWidget {
  const _ReceivedOrderTile({required this.order});

  final MarketplaceOrder order;

  Future<void> _confirmDeliveryDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.marketplace_confirm_delivery_title),
        content: TextField(
          controller: pinController,
          style: AppStyle.of(ctx).H6(),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(labelText: l10n.marketplace_client_pin_label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, pinController.text.trim()),
            child: Text(l10n.marketplace_validate),
          ),
        ],
      ),
    );
    pinController.dispose();
    if (pin == null || pin.isEmpty) return;
    try {
      await ref.read(marketplaceRepositoryProvider).confirmDelivery(order.id, pin);
      ref.invalidate(marketplaceVendorDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.marketplace_delivery_confirmed_payout)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  /// Idempotent server-side (returns the existing Delivery if already
  /// marked ready) — safe to tap more than once.
  Future<void> _markReady(BuildContext context, WidgetRef ref) async {
    try {
      final delivery =
          await ref.read(courierRepositoryProvider).markOrderReady(order.id);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CourierVendorDelivery(deliveryId: delivery.id)),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
            '${order.buyer.fullName.isNotEmpty ? order.buyer.fullName : l10n.marketplace_customer_fallback} · ${l10n.marketplace_qty_label} ${order.quantity} · ${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
            style: appStyle.H6(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(_statusLabels(l10n)[order.status] ?? order.status,
              style: appStyle.H6(color: colorScheme.primary)),
          if (order.status == 'escrow_held') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmDeliveryDialog(context, ref),
                    child: Text(l10n.marketplace_confirm_delivery_pin_button),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markReady(context, ref),
                    child: Text(l10n.marketplace_delivery),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown on the dashboard whenever kyc_status != 'approved' — selling is
/// blocked server-side until then, so this is the vendor's way in to
/// marketplace_kyc.dart (upload/status/re-submit) without hunting for it.
class _KycBanner extends ConsumerWidget {
  const _KycBanner({required this.vendor});

  final VendorProfile vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final l10n = AppLocalizations.of(context)!;
    final rejected = vendor.kycStatus == 'rejected';
    final color = rejected ? Colors.redAccent : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(rejected ? Icons.error_outline : Icons.hourglass_top, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rejected
                      ? l10n.kyc_dashboard_banner_rejected
                      : l10n.kyc_dashboard_banner_pending,
                  style: appStyle.H6(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () async {
                final done = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => MarketplaceKyc(vendor: vendor)),
                );
                if (done == true) {
                  ref.invalidate(marketplaceVendorDashboardProvider);
                }
              },
              child: Text(l10n.kyc_dashboard_action_button),
            ),
          ),
        ],
      ),
    );
  }
}
