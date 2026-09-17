import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:munturai/screens/payment_screen.dart';
import 'package:munturai/widgets/widget_coinsPack.dart';

/// Écran d'achat de packs de coins.
/// Packs chargés depuis GET /coins-packs/ (a4's coins-packs consolidation —
/// remplace la liste codée en dur qu'il y avait ici avant, cf.
/// coinsPacksProvider). Le choix du pack seul se fait ici ; le "comment
/// payer" (MoMo/carte, montant, en attente/webview) est le PaymentScreen
/// partagé (voir payment_screen.dart), même écran que le checkout
/// marketplace et les abonnements.
class Coins extends ConsumerStatefulWidget {
  const Coins({super.key});

  @override
  ConsumerState<Coins> createState() => _CoinsState();
}

class _CoinsState extends ConsumerState<Coins> {
  int _selectedIndex = 0;

  Future<void> _buy(CoinsPackEntity pack) async {
    final l10n = AppLocalizations.of(context)!;
    int? previousBalance;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentScreen(
        title: l10n.coins,
        itemTitle: pack.name,
        itemSubtitle: '${pack.coins} ${l10n.coins_unit_label}',
        amount: pack.price,
        currency: pack.currency,
        pendingMessage: l10n.marketplace_payment_pending_notice,
        successUrl: coinsPaymentSuccessUrl,
        failureUrl: coinsPaymentFailureUrl,
        onMomoPay: (phone) async {
          previousBalance ??= await ref.read(coinsBalanceProvider.future);
          return ref
              .read(subscriptionRepositoryProvider)
              .buyCoinsPack(pack.code, phone);
        },
        onCardPay: () => ref
            .read(subscriptionRepositoryProvider)
            .buyCoinsPackByLink(
              pack.code,
              redirectUrl: coinsPaymentSuccessUrl,
              failureRedirectUrl: coinsPaymentFailureUrl,
            ),
        checkDone: () async {
          ref.invalidate(coinsBalanceProvider);
          final balance = await ref.read(coinsBalanceProvider.future);
          return previousBalance == null || balance != previousBalance;
        },
        onSuccess: () {
          ref.invalidate(coinsBalanceProvider);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.coins_credited_message)),
          );
        },
      ),
    ));
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
                child: Text(translator.no_pack_available_label,
                    style: appStyle.H5()));
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
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: GestureDetector(
                    onTap: () => _buy(selectedPack),
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
