import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/data/models/courier_models.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/courier_qr_scan.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _deliveryStatusLabels(AppLocalizations l10n) => {
      'pending': l10n.delivery_status_pending,
      'assigned': l10n.delivery_status_assigned,
      'picked_up': l10n.delivery_status_picked_up,
      'in_transit': l10n.delivery_status_in_transit,
      'delivered': l10n.delivery_status_delivered,
      'failed': l10n.delivery_status_failed,
    };

Map<String, String> _statusLabels(AppLocalizations l10n) => {
      'pending_payment': l10n.status_pending_payment,
      'escrow_held': l10n.status_escrow_held,
      'delivered_pending_pin': l10n.status_delivered_pending_pin,
      'completed': l10n.status_completed,
      'returned': l10n.status_returned,
      'cancelled': l10n.status_cancelled,
      'disputed': l10n.status_disputed,
    };

const List<String> _terminalStatuses = ['completed', 'returned', 'cancelled', 'disputed'];

/// Order tracking for the buyer: status, PIN reveal once escrow is held,
/// and the "Retourner" action while eligible. Polls the order every 5s
/// while its status can still change server-side (Campay webhooks land
/// asynchronously — there's no push notification for this yet), and stops
/// once it reaches a terminal status.
class MarketplaceOrderTracking extends ConsumerStatefulWidget {
  const MarketplaceOrderTracking({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<MarketplaceOrderTracking> createState() =>
      _MarketplaceOrderTrackingState();
}

class _MarketplaceOrderTrackingState extends ConsumerState<MarketplaceOrderTracking> {
  Timer? _poller;
  bool _returning = false;
  String? _returnError;

  @override
  void initState() {
    super.initState();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) {
      final current = ref.read(marketplaceOrderDetailProvider(widget.orderId)).valueOrNull;
      if (current != null && _terminalStatuses.contains(current.status)) {
        _poller?.cancel();
        return;
      }
      ref.invalidate(marketplaceOrderDetailProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _returnOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.marketplace_return_confirm_title),
        content: Text(l10n.marketplace_return_confirm_body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.marketplace_return_action)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _returning = true;
      _returnError = null;
    });
    final repo = ref.read(marketplaceRepositoryProvider);
    try {
      await repo.returnOrder(widget.orderId);
      ref.invalidate(marketplaceOrderDetailProvider(widget.orderId));
      if (!mounted) return;
      setState(() => _returning = false);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      // Orders paid by card have no MoMo number on file for the refund, so
      // the backend rejects the plain return/ call and asks for one
      // explicitly — detected loosely (no dedicated error code from the
      // API), rather than trying to know the payment method up front.
      final needsPhone = message.toLowerCase().contains('phone') ||
          message.toLowerCase().contains('numéro') ||
          message.toLowerCase().contains('momo');
      if (needsPhone && mounted) {
        final phone = await _promptRefundPhone();
        if (phone != null && phone.isNotEmpty) {
          try {
            await repo.returnOrder(widget.orderId, phone: phone);
            ref.invalidate(marketplaceOrderDetailProvider(widget.orderId));
            if (!mounted) return;
            setState(() => _returning = false);
            return;
          } catch (e2) {
            if (!mounted) return;
            setState(() {
              _returning = false;
              _returnError = e2.toString().replaceFirst('Exception: ', '');
            });
            return;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _returning = false;
        _returnError = message;
      });
    }
  }

  /// Asked only when the backend rejects a return/ call for lack of a MoMo
  /// number to refund to — cards paid through Campay's hosted widget never
  /// give us one up front.
  Future<String?> _promptRefundPhone() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.marketplace_refund_phone_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.marketplace_refund_phone_body),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '2376XXXXXXXX'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.marketplace_confirm_button)),
        ],
      ),
    );
  }

  Future<void> _scanDropoff(Delivery delivery) async {
    final l10n = AppLocalizations.of(context)!;
    final token = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CourierQrScan(
          title: l10n.marketplace_confirm_reception_title,
          instructions: l10n.marketplace_confirm_reception_instructions,
        ),
      ),
    );
    if (token == null || !mounted) return;
    try {
      await ref.read(courierRepositoryProvider).confirmDropoff(delivery.id, token);
      ref.invalidate(myDeliveriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.marketplace_reception_confirmed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  bool _canReturn(MarketplaceOrder order) {
    if (order.status != 'escrow_held') return false;
    final expiresAt = order.returnWindowExpiresAt;
    if (expiresAt == null) return true;
    final parsed = DateTime.tryParse(expiresAt);
    return parsed == null || DateTime.now().isBefore(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(marketplaceOrderDetailProvider(widget.orderId));
    final deliveries = ref.watch(myDeliveriesProvider).valueOrNull ?? const <Delivery>[];
    Delivery? delivery;
    for (final d in deliveries) {
      if (d.orderId == widget.orderId) {
        delivery = d;
        break;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_order_tracking_title),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.marketplace_order_load_error, style: appStyle.H5())),
        data: (order) {
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(marketplaceOrderDetailProvider(widget.orderId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(order.listing.title, style: appStyle.H4(weight: 'bold')),
                Text('${order.vendor.shopName} · ${l10n.marketplace_qty_label} ${order.quantity}',
                    style: appStyle.H6(color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabels(l10n)[order.status] ?? order.status,
                    style: TextStyle(
                        color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
                    style: appStyle.H4(weight: 'bold')),
                if (delivery != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _deliveryStatusLabels(l10n)[delivery.status] ?? delivery.status,
                            style: appStyle.H6(weight: 'bold'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (delivery.status == 'picked_up' || delivery.status == 'in_transit') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _scanDropoff(delivery!),
                        child: Text(l10n.marketplace_scan_courier_qr),
                      ),
                    ),
                  ],
                ],
                if (order.status == 'pending_payment') ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.marketplace_payment_pending_notice,
                    style: appStyle.H6(color: Colors.grey),
                  ),
                ],
                if (order.deliveryPinReveal != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: Column(
                      children: [
                        Text(l10n.marketplace_delivery_code_title, style: appStyle.H5(weight: 'bold')),
                        const SizedBox(height: 8),
                        Text(
                          order.deliveryPinReveal!,
                          style: appStyle.H2(weight: 'bold', color: colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.marketplace_delivery_code_warning,
                          textAlign: TextAlign.center,
                          style: appStyle.H6(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
                if (order.returnWindowExpiresAt != null && order.status == 'escrow_held') ...[
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.marketplace_return_possible_until} ${order.returnWindowExpiresAt}',
                    style: appStyle.H6(color: Colors.grey),
                  ),
                ],
                if (_returnError != null) ...[
                  const SizedBox(height: 12),
                  Text(_returnError!, style: appStyle.H6(color: Colors.redAccent)),
                ],
                if (_canReturn(order)) ...[
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _returning ? null : _returnOrder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(_returning
                        ? l10n.marketplace_returning_in_progress
                        : l10n.marketplace_report_problem_return),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
