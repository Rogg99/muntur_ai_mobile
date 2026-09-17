import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:munturai/screens/momo_payment_pending.dart';
import 'package:munturai/screens/payment_webview.dart';
import 'package:munturai/widgets/payment_method_chip.dart';
import 'package:munturai/widgets/widget_coinsPack.dart';

enum _PaymentMethod { momo, card }

/// Écran d'achat de packs de coins.
/// Packs chargés depuis GET /coins-packs/ (a4's coins-packs consolidation —
/// remplace la liste codée en dur qu'il y avait ici avant, cf.
/// coinsPacksProvider) ; achat MoMo ou carte, même pattern payment_pending +
/// webhook Campay que le checkout marketplace.
class Coins extends ConsumerStatefulWidget {
  const Coins({super.key});

  @override
  ConsumerState<Coins> createState() => _CoinsState();
}

class _CoinsState extends ConsumerState<Coins> {
  int _selectedIndex = 0;
  _PaymentMethod _method = _PaymentMethod.momo;
  bool _submitting = false;

  Future<void> _buy(CoinsPackEntity pack) async {
    if (_method == _PaymentMethod.momo) {
      await _buyByMomo(pack);
    } else {
      await _buyByCard(pack);
    }
  }

  Future<void> _buyByMomo(CoinsPackEntity pack) async {
    final phone = await _promptPhone();
    if (phone == null || phone.isEmpty || !mounted) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.buyCoinsPack(pack.code, phone);
      if (!mounted) return;
      final previousBalance = await ref.read(coinsBalanceProvider.future);
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MomoPaymentPending(
          title: 'Achat de coins',
          pendingMessage:
              'En attente de confirmation du paiement Mobile Money...',
          ussdCode: result.ussdCode,
          checkDone: () async {
            ref.invalidate(coinsBalanceProvider);
            final balance = await ref.read(coinsBalanceProvider.future);
            return balance != previousBalance;
          },
          onDone: () {
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coins crédités avec succès !')),
            );
          },
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _buyByCard(CoinsPackEntity pack) async {
    setState(() => _submitting = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final paymentLink = await repo.buyCoinsPackByLink(
        pack.code,
        redirectUrl: coinsPaymentSuccessUrl,
        failureRedirectUrl: coinsPaymentFailureUrl,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PaymentWebview(
          title: 'Achat de coins',
          paymentLink: paymentLink,
          successUrl: coinsPaymentSuccessUrl,
          failureUrl: coinsPaymentFailureUrl,
          onFinished: () {
            ref.invalidate(coinsBalanceProvider);
            Navigator.of(context).pop();
          },
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _promptPhone() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Numéro Mobile Money'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '2376XXXXXXXX'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Confirmer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final packsAsync = ref.watch(coinsPacksProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          translator.coins,
          overflow: TextOverflow.ellipsis,
          style: appStyle.H3(weight: 'bold'),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: packsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: appStyle.H5(),
            textAlign: TextAlign.center,
          ),
        ),
        data: (packs) {
          if (packs.isEmpty) {
            return Center(
                child: Text('Aucun pack disponible', style: appStyle.H5()));
          }
          if (_selectedIndex >= packs.length) _selectedIndex = 0;
          final selectedPack = packs[_selectedIndex];

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 180),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 280 / 300,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: [
                      for (int i = 0; i < packs.length; i++)
                        CoinsPackWidget(
                          name: packs[i].name,
                          coins: packs[i].coins,
                          price: packs[i].price,
                          currency: packs[i].currency,
                          isSelected: _selectedIndex == i,
                          isPopular: i == 1,
                          onPressed: () =>
                              setState(() => _selectedIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Moyen de paiement', style: appStyle.H5()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: PaymentMethodChip(
                          label: 'Mobile Money',
                          icon: Icons.phone_android,
                          selected: _method == _PaymentMethod.momo,
                          onTap: () =>
                              setState(() => _method = _PaymentMethod.momo),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentMethodChip(
                          label: 'Carte bancaire',
                          icon: Icons.credit_card,
                          selected: _method == _PaymentMethod.card,
                          onTap: () =>
                              setState(() => _method = _PaymentMethod.card),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: GestureDetector(
                    onTap: _submitting ? null : () => _buy(selectedPack),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      width: BodyWidth() - 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_submitting)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          else
                            Text(translator.continue__, style: appStyle.H4()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget utilitaire pour afficher les features d'un plan (réutilisé dans abonnement.dart)
Widget PlanFeatures(
  List<String> features,
  AppStyle appStyle,
  ColorScheme colorScheme, {
  bool golden = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: features
        .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(feature, style: appStyle.H4())),
                  const Spacer(),
                  if (!golden)
                    Icon(Icons.check_circle_outline, color: colorScheme.primary)
                  else
                    Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage('assets/images/fond_gold.jpg'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                          Icon(Icons.check_circle, color: colorScheme.surface),
                    ),
                ],
              ),
            ))
        .toList(),
  );
}
