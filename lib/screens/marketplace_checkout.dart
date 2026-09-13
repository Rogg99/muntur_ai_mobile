import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_order_tracking.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Escrow checkout: creates the Order, then triggers the Campay mobile
/// money prompt on the given phone. The order stays 'pending_payment'
/// until Campay's webhook confirms it — this screen only starts that,
/// then hands off to the tracking screen to show the eventual result.
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  double get _total => widget.part.price * _quantity;

  Future<void> _submit() async {
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
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro Mobile Money',
              hintText: '2376XXXXXXXX',
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
