import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:munturai/screens/pay.dart';
import 'package:munturai/widgets/widget_coinsPack.dart';

/// Écran d'achat de packs de coins.
/// Utilise Riverpod pour charger les plans via subscriptionPlansProvider.
class Coins extends ConsumerStatefulWidget {
  const Coins({super.key});

  @override
  ConsumerState<Coins> createState() => _CoinsState();
}

class _CoinsState extends ConsumerState<Coins> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Plans de coins codés en dur (à terme à charger depuis l'API via provider)
  static const List<SubscriptionPlanEntity> _coinPlans = [
    SubscriptionPlanEntity(
      code: 'COINS-PACK-500',
      description: 'COINS PACK 500',
      price: 400,
      currency: 'XAF',
      days: 0,
    ),
    SubscriptionPlanEntity(
      code: 'COINS-PACK-1000',
      description: 'COINS PACK 1000',
      price: 750,
      currency: 'XAF',
      days: 0,
    ),
    SubscriptionPlanEntity(
      code: 'COINS-PACK-2000',
      description: 'COINS PACK 2000',
      price: 1300,
      currency: 'XAF',
      days: 0,
    ),
    SubscriptionPlanEntity(
      code: 'COINS-PACK-5000',
      description: 'COINS PACK 5000',
      price: 3500,
      currency: 'XAF',
      days: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
      body: Stack(
        children: [
          // ── Grille des packs ────────────────────────────────────
          GridView.count(
            childAspectRatio: 210 / 300,
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 80),
            crossAxisSpacing: 10,
            mainAxisSpacing: 0,
            crossAxisCount: 2,
            children: [
              for (int i = 0; i < _coinPlans.length; i++)
                CoinsPackWidget(
                  plan: _coinPlans[i],
                  isSelected: _selectedIndex == i,
                  isPopular: i == 1,
                  onPressed: () => setState(() => _selectedIndex = i),
                ),
            ],
          ),

          // ── Bouton continuer ─────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Pay(plan: _coinPlans[_selectedIndex]),
                  ));
                },
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
