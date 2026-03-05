import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';

/// Carte de pack de coins sélectionnable.
/// [plan]       – plan d'abonnement à afficher (coins = nombre de coins inclus)
/// [isSelected] – true si ce pack est actuellement sélectionné
/// [isPopular]  – affiche un badge "Populaire"
/// [onPressed]  – callback lors de la sélection
class CoinsPackWidget extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback? onPressed;

  const CoinsPackWidget({
    super.key,
    required this.plan,
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
                  plan.description.isNotEmpty ? plan.description : plan.code,
                  style: appStyle.H4(weight: 'b'),
                  textAlign: TextAlign.center,
                ),
                // Prix barré fictif (10% de plus)
                Text(
                  '${(plan.price * 1.1).toStringAsFixed(0)} ${plan.currency}',
                  style: appStyle
                      .txtRoboto(size: 16, color: const Color(0xFFAFAFAF))
                      .copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                ),
                Text(
                  '${plan.price.toStringAsFixed(0)} ${plan.currency}',
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
