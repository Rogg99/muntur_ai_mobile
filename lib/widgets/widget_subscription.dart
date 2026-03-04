import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/features/subscriptions/domain/entities/subscription_entity.dart';

/// Carte de plan d'abonnement sélectionnable.
///
/// [plan]        – plan à afficher (SubscriptionPlanEntity)
/// [isSelected]  – true si c'est le plan actuellement sélectionné
/// [isPopular]   – affiche un badge "Populaire" en haut de la carte
/// [onSelected]  – callback quand l'utilisateur tape la carte
class SubscriptionWidget extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback? onSelected;

  const SubscriptionWidget({
    super.key,
    required this.plan,
    this.isSelected = false,
    this.isPopular = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;

    final int months = (plan.days / 30).round();
    final isGoldSelected = isSelected && plan.type == 'Gold';

    return GestureDetector(
      onTap: onSelected,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Carte principale ──────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: isGoldSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/fond_gold.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.85,
                    ),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : UIColors.txtInactive,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nombre de mois
                Text(
                  months.toString(),
                  style: appStyle.H4(
                    weight: 'bold',
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                Text(
                  months > 1 ? translator.months : translator.month,
                  style: appStyle.H6(
                    color: isSelected
                        ? Colors.white70
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                // Prix barré (optionnel – ici on ne l'a pas dans l'entity)
                Text(
                  '${plan.price.toStringAsFixed(0)} ${plan.currency}',
                  style: appStyle.H4(
                    weight: 'bold',
                    color: isSelected ? Colors.white : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Badge "Populaire" ─────────────────────────────────────
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
                      size: 11,
                      color: colorScheme.onSecondary,
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
