import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_order_tracking.dart';
import 'package:munturai/screens/payment_screen.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Custom-URI-scheme redirects the card payment webview intercepts for a
/// marketplace order — see PaymentScreen / payment_webview.dart.
const String marketplacePaymentSuccessUrl = 'autosynx://payment/success';
const String marketplacePaymentFailureUrl = 'autosynx://payment/failure';

/// Product-selection step of the marketplace escrow purchase: quantity,
/// total. The actual "how do you want to pay" step is the shared
/// PaymentScreen (see payment_screen.dart) — this screen's job is just to
/// create the Order once the buyer proceeds, then hand off.
class MarketplaceCheckout extends ConsumerStatefulWidget {
  const MarketplaceCheckout({super.key, required this.part});

  final PartListing part;

  @override
  ConsumerState<MarketplaceCheckout> createState() => _MarketplaceCheckoutState();
}

class _MarketplaceCheckoutState extends ConsumerState<MarketplaceCheckout> {
  int _quantity = 1;
  String? _error;

  // Created once, on the first payment attempt, and reused across method
  // switches/retries rather than creating a fresh Order every time the
  // buyer taps "Payer" (e.g. after a failed MoMo attempt they retry).
  MarketplaceOrder? _order;

  double get _total => widget.part.price * _quantity;

  Future<MarketplaceOrder> _ensureOrder() async {
    final existing = _order;
    if (existing != null) return existing;
    final repo = ref.read(marketplaceRepositoryProvider);
    final order = await repo.createOrder(
      partId: widget.part.id,
      quantity: _quantity,
    );
    _order = order;
    return order;
  }

  Future<void> _proceedToPayment() async {
    setState(() => _error = null);
    final l10n = AppLocalizations.of(context)!;
    try {
      await _ensureOrder();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          title: l10n.marketplace_escrow_payment_title,
          itemTitle: widget.part.title,
          itemSubtitle: widget.part.vendor.shopName,
          amount: _total,
          currency: widget.part.currency,
          pendingMessage:
              'En attente de confirmation du paiement Mobile Money...',
          successUrl: marketplacePaymentSuccessUrl,
          failureUrl: marketplacePaymentFailureUrl,
          onMomoPay: (phone) async {
            final order = await _ensureOrder();
            return ref.read(marketplaceRepositoryProvider).payOrder(order.id, phone);
          },
          onCardPay: () async {
            final order = await _ensureOrder();
            return ref.read(marketplaceRepositoryProvider).payOrderByLink(
                  order.id,
                  redirectUrl: marketplacePaymentSuccessUrl,
                  failureRedirectUrl: marketplacePaymentFailureUrl,
                );
          },
          checkDone: () async {
            final order = _order;
            if (order == null) return false;
            ref.invalidate(marketplaceOrderDetailProvider(order.id));
            final fresh =
                await ref.read(marketplaceOrderDetailProvider(order.id).future);
            return fresh.status != 'pending_payment';
          },
          onSuccess: () {
            final order = _order;
            if (order == null || !mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => MarketplaceOrderTracking(orderId: order.id)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final part = widget.part;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: l10n.marketplace_escrow_payment_title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(part.title, style: appStyle.H4(weight: 'bold')),
          Text(part.vendor.shopName, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.marketplace_quantity_label, style: appStyle.H5()),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() {
                              _quantity--;
                              _order = null; // quantity changed → re-quote
                            })
                        : null,
                  ),
                  Text('$_quantity', style: appStyle.H4(weight: 'bold')),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _quantity < part.stockQuantity
                        ? () => setState(() {
                              _quantity++;
                              _order = null;
                            })
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.marketplace_total_to_pay, style: appStyle.H4(weight: 'bold')),
              Text('${_total.toStringAsFixed(0)} ${part.currency}',
                  style: appStyle.H4(weight: 'bold', color: colorScheme.primary)),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: l10n.marketplace_pay_button,
            onPressed: _proceedToPayment,
          ),
        ],
      ),
    );
  }
}
