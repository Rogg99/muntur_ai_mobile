import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:munturai/screens/payment_screen.dart';
import 'package:munturai/widgets/primary_button.dart';
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
        onCardPay: () =>
            ref.read(subscriptionRepositoryProvider).buyCoinsPackByLink(
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

          // Saving per coin vs the smallest pack's rate, shown as a badge.
          final base = packs.first.coins > 0
              ? packs.first.price / packs.first.coins
              : 0.0;
          int saving(CoinsPackEntity p) => base <= 0 || p.coins <= 0
              ? 0
              : ((1 - (p.price / p.coins) / base) * 100).round().clamp(0, 99);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const _BalanceCard(),
                    const SizedBox(height: 20),
                    for (int i = 0; i < packs.length; i++) ...[
                      CoinsPackWidget(
                        name: packs[i].name,
                        coins: packs[i].coins,
                        price: packs[i].price,
                        currency: packs[i].currency,
                        isSelected: _selectedIndex == i,
                        isPopular: packs.length > 2 && i == 1,
                        tier: (i * 4 / packs.length).floor(),
                        savingPercent: saving(packs[i]),
                        onPressed: () => setState(() => _selectedIndex = i),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              // Sticky checkout bar: what's selected + the single CTA.
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4)),
                  ],
                ),
                child: Row(
                  children: [
                    const CoinIcon(size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '${selectedPack.coins} ${translator.coins_unit_label}',
                              style: appStyle.H5(weight: 'bold')),
                          Text(
                              '${selectedPack.price.toStringAsFixed(0)} ${selectedPack.currency}',
                              style: appStyle.H6(color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: PrimaryButton(
                        text: translator.continue__,
                        padding: 14,
                        onPressed: () => _buy(selectedPack),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final balance = ref.watch(coinsBalanceProvider).valueOrNull;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, Colors.black, 0.45)!
          ],
        ),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translator.coins_balance_label,
                    style: appStyle.H6(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(balance?.toString() ?? '—',
                    style: appStyle
                        .H1(weight: 'bold')
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
          const CoinIcon(size: 56),
        ],
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
