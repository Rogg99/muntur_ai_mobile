import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_order_tracking.dart';
import 'package:munturai/screens/marketplace_payment_webview.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

enum _PaymentMethod { momo, card }

/// Escrow checkout: creates the Order, then either triggers the Campay
/// mobile money prompt on a given phone, or opens Campay's hosted
/// payment-link widget for card payment. The order stays 'pending_payment'
/// until Campay's webhook confirms it either way — this screen only starts
/// that, then hands off to the tracking screen to show the eventual result.
class MarketplaceCheckout extends ConsumerStatefulWidget {
  const MarketplaceCheckout({super.key, required this.part});

  final PartListing part;

  @override
  ConsumerState<MarketplaceCheckout> createState() => _MarketplaceCheckoutState();
}

class _MarketplaceCheckoutState extends ConsumerState<MarketplaceCheckout> {
  int _quantity = 1;
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _error;
  _PaymentMethod _method = _PaymentMethod.momo;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  double get _total => widget.part.price * _quantity;

  Future<void> _submit() async {
    if (_method == _PaymentMethod.momo) {
      await _submitByMomo();
    } else {
      await _submitByCard();
    }
  }

  Future<void> _submitByMomo() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Entrez le numéro Mobile Money à débiter.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final order = await repo.createOrder(
        partId: widget.part.id,
        quantity: _quantity,
      );
      await repo.payOrder(order.id, phone);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MarketplaceOrderTracking(orderId: order.id)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submitByCard() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final order = await repo.createOrder(
        partId: widget.part.id,
        quantity: _quantity,
      );
      final paymentLink = await repo.payOrderByLink(
        order.id,
        redirectUrl: marketplacePaymentSuccessUrl,
        failureRedirectUrl: marketplacePaymentFailureUrl,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MarketplacePaymentWebview(
            orderId: order.id,
            paymentLink: paymentLink,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final part = widget.part;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(titleTxt: 'Paiement escrow'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(part.title, style: appStyle.H4(weight: 'bold')),
          Text(part.vendor.shopName, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantité', style: appStyle.H5()),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text('$_quantity', style: appStyle.H4(weight: 'bold')),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _quantity < part.stockQuantity
                        ? () => setState(() => _quantity++)
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
              Text('Total à payer', style: appStyle.H4(weight: 'bold')),
              Text('${_total.toStringAsFixed(0)} ${part.currency}',
                  style: appStyle.H4(weight: 'bold', color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Moyen de paiement', style: appStyle.H5()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PaymentMethodChip(
                  label: 'Mobile Money',
                  icon: Icons.phone_android,
                  selected: _method == _PaymentMethod.momo,
                  onTap: () => setState(() => _method = _PaymentMethod.momo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PaymentMethodChip(
                  label: 'Carte bancaire',
                  icon: Icons.credit_card,
                  selected: _method == _PaymentMethod.card,
                  onTap: () => setState(() => _method = _PaymentMethod.card),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_method == _PaymentMethod.momo)
            TextField(
              controller: _phoneController,
              style: appStyle.H6(),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro Mobile Money',
                hintText: '2376XXXXXXXX',
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Vous serez redirigé vers une page de paiement sécurisée Campay pour saisir votre carte.',
                style: appStyle.H6(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Le montant reste bloqué en séquestre (escrow) jusqu'à ce que vous confirmiez la livraison avec le code PIN qui vous sera transmis. Fenêtre de retour : 48h.",
              style: appStyle.H6(color: Colors.grey),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Payer ${_total.toStringAsFixed(0)} ${part.currency}',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.white30,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? colorScheme.primary : Colors.grey),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: appStyle.H6(
                    color: selected ? colorScheme.primary : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
