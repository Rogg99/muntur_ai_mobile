import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/models/payment_models.dart';
import 'package:munturai/screens/momo_payment_pending.dart';
import 'package:munturai/screens/payment_webview.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/payment_method_chip.dart';
import 'package:munturai/widgets/primary_button.dart';

enum _PaymentMethod { momo, card }

/// The one payment interface for the whole app — marketplace checkout,
/// coins-pack purchase, and subscription purchase all push this instead of
/// each re-implementing their own MoMo/card toggle, phone prompt, pending
/// screen, and webview. What differs between them (picking a part +
/// quantity, a coins pack, or a plan) stays in each feature's own screen;
/// this only covers the "how do you want to pay" step that's now identical
/// everywhere thanks to a4's Campay consolidation (every endpoint returns
/// the same `{status, ussd_code}` / `payment_link` shapes).
///
/// [onMomoPay] and [onCardPay] do whatever domain-specific call is needed
/// (creating a marketplace order first, buying a coins pack by code,
/// subscribing to a plan) and return the same result shape either way —
/// this widget only knows how to drive the MoMo/card UI around them.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.title,
    required this.itemTitle,
    this.itemSubtitle,
    required this.amount,
    required this.currency,
    this.extraContent,
    required this.onMomoPay,
    required this.onCardPay,
    required this.successUrl,
    required this.failureUrl,
    required this.pendingMessage,
    required this.checkDone,
    required this.onSuccess,
  });

  final String title;
  final String itemTitle;
  final String? itemSubtitle;
  final double amount;
  final String currency;

  /// Optional extra widget shown between the amount and the payment method
  /// picker — e.g. marketplace's escrow-window note. Kept generic (a plain
  /// Widget) rather than a domain-specific field so this screen stays
  /// agnostic to which of the 3 flows is using it.
  final Widget? extraContent;

  final Future<MomoCollectResult> Function(String phone) onMomoPay;
  final Future<String> Function() onCardPay;

  /// Custom-URI-scheme redirects the card webview intercepts — distinct per
  /// flow so a stray redirect can't be mistaken for a different purchase's
  /// success (see marketplace/coins/subscription *PaymentSuccessUrl consts).
  final String successUrl;
  final String failureUrl;

  final String pendingMessage;

  /// Polled every 5s while waiting for a MoMo collect to confirm — typically
  /// invalidates and re-reads whichever Riverpod provider the real-time WS
  /// push already updates for that domain (order status, coins balance,
  /// subscription). Return true once it's actually confirmed.
  final Future<bool> Function() checkDone;

  /// Called once payment is confirmed (MoMo) or the card webview redirected
  /// (card) — after this screen (and any pending/webview pushed on top of
  /// it) has already been popped, so it runs with whatever screen pushed
  /// this one back on top and its own BuildContext/ref still valid.
  final VoidCallback onSuccess;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _method = _PaymentMethod.momo;
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
      final result = await widget.onMomoPay(phone);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MomoPaymentPending(
          title: widget.title,
          pendingMessage: widget.pendingMessage,
          ussdCode: result.ussdCode,
          checkDone: widget.checkDone,
          onDone: () {
            Navigator.of(context).pop(); // pending screen
            Navigator.of(context).pop(); // this payment screen
            widget.onSuccess();
          },
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
      return;
    }
    if (mounted) setState(() => _submitting = false);
  }

  Future<void> _submitByCard() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final paymentLink = await widget.onCardPay();
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PaymentWebview(
          title: widget.title,
          paymentLink: paymentLink,
          successUrl: widget.successUrl,
          failureUrl: widget.failureUrl,
          onFinished: () {
            Navigator.of(context).pop(); // webview
            Navigator.of(context).pop(); // this payment screen
            widget.onSuccess();
          },
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
      return;
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: widget.title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.itemTitle, style: appStyle.H4(weight: 'bold')),
          if (widget.itemSubtitle != null && widget.itemSubtitle!.isNotEmpty)
            Text(widget.itemSubtitle!, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 12),
          Text(
            '${widget.amount.toStringAsFixed(0)} ${widget.currency}',
            style: appStyle.H3(weight: 'bold', color: colorScheme.primary),
          ),
          if (widget.extraContent != null) ...[
            const SizedBox(height: 12),
            widget.extraContent!,
          ],
          const SizedBox(height: 24),
          Text('Moyen de paiement', style: appStyle.H5()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PaymentMethodChip(
                  label: 'Mobile Money',
                  icon: Icons.phone_android,
                  selected: _method == _PaymentMethod.momo,
                  onTap: () => setState(() => _method = _PaymentMethod.momo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PaymentMethodChip(
                  label: 'Carte bancaire',
                  icon: Icons.credit_card,
                  selected: _method == _PaymentMethod.card,
                  onTap: () => setState(() => _method = _PaymentMethod.card),
                ),
              ),
            ],
          ),
          if (_method == _PaymentMethod.momo) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              style: appStyle.H6(),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro Mobile Money',
                hintText: '2376XXXXXXXX',
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text:
                'Payer ${widget.amount.toStringAsFixed(0)} ${widget.currency}',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
