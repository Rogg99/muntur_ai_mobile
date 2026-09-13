import 'dart:async';

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

const List<String> _terminalStatuses = ['completed', 'returned', 'cancelled', 'disputed'];

/// Order tracking for the buyer: status, PIN reveal once escrow is held,
/// and the "Retourner" action while eligible. Polls the order every 5s
/// while its status can still change server-side (Campay webhooks land
/// asynchronously — there's no push notification for this yet), and stops
/// once it reaches a terminal status.
class MarketplaceOrderTracking extends ConsumerStatefulWidget {
  const MarketplaceOrderTracking({super.key, required this.orderId});

  final int orderId;

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retourner cette commande ?'),
        content: const Text(
            'Le montant payé sera remboursé sur votre numéro Mobile Money. Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Retourner')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _returning = true;
      _returnError = null;
    });
    try {
      await ref.read(marketplaceRepositoryProvider).returnOrder(widget.orderId);
      ref.invalidate(marketplaceOrderDetailProvider(widget.orderId));
      if (!mounted) return;
      setState(() => _returning = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _returning = false;
        _returnError = e.toString().replaceFirst('Exception: ', '');
      });
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
    final orderAsync = ref.watch(marketplaceOrderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Suivi de commande'),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Impossible de charger cette commande.', style: appStyle.H5())),
        data: (order) {
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(marketplaceOrderDetailProvider(widget.orderId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(order.listing.title, style: appStyle.H4(weight: 'bold')),
                Text('${order.vendor.shopName} · Qté ${order.quantity}',
                    style: appStyle.H6(color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabels[order.status] ?? order.status,
                    style: TextStyle(
                        color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${order.priceTotal.toStringAsFixed(0)} ${order.currency}',
                    style: appStyle.H4(weight: 'bold')),
                if (order.status == 'pending_payment') ...[
                  const SizedBox(height: 16),
                  Text(
                    "En attente de confirmation du paiement Mobile Money. Cette page se met à jour automatiquement.",
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
                        Text('Code de livraison', style: appStyle.H5(weight: 'bold')),
                        const SizedBox(height: 8),
                        Text(
                          order.deliveryPinReveal!,
                          style: appStyle.H2(weight: 'bold', color: colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ne le communiquez au livreur/vendeur qu'au moment de la remise de la pièce.",
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
                    'Retour possible jusqu\'au ${order.returnWindowExpiresAt}',
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
                        ? 'Retour en cours...'
                        : 'Signaler un problème / Retourner'),
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
