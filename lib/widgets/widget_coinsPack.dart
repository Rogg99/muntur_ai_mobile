import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';

/// Carte de pack de coins sélectionnable.
/// Prend des champs explicites plutôt qu'une [SubscriptionPlanEntity] —
/// depuis que les packs viennent de GET /coins-packs/ (CoinsPackEntity),
/// ils portent un nombre de coins et un nom distincts d'un plan
/// d'abonnement, ce widget n'a plus besoin d'être couplé à ce type-là.
class CoinsPackWidget extends StatelessWidget {
  final String name;
  final int coins;
  final double price;
  final String currency;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback? onPressed;

  const CoinsPackWidget({
    super.key,
    required this.name,
    required this.coins,
    required this.price,
    required this.currency,
    required this.isSelected,
    this.isPopular = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : Border.all(color: Colors.white30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  name,
                  style: appStyle.H4(weight: 'b'),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$coins coins',
                  style: appStyle.txtRoboto(size: 13, color: Colors.grey),
                ),
                Text(
                  '${price.toStringAsFixed(0)} $currency',
                  style: appStyle.H4(weight: 'b'),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    translator.popular,
                    style: appStyle.txtRoboto(
                        size: 11, color: UIColors.primaryAccent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
