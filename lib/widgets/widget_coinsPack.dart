import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';

const _gold = Color(0xFFF5B301);
const _goldDark = Color(0xFFC98A00);

/// Coin glyph used by the coins screen (balance header + pack cards).
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE07A), _gold, _goldDark],
        ),
        border: Border.all(color: const Color(0xFFFFF1B8), width: size * 0.06),
        boxShadow: [
          BoxShadow(
              color: _goldDark.withValues(alpha: 0.35),
              blurRadius: size * 0.2,
              offset: Offset(0, size * 0.06)),
        ],
      ),
      child: Icon(Icons.bolt_rounded, size: size * 0.6, color: Colors.white),
    );
  }
}

/// Selectable coins pack row. [tier] (0 = smallest pack) sizes the coin
/// stack; [savingPercent] is the discount per coin vs the smallest pack.
class CoinsPackWidget extends StatelessWidget {
  final String name;
  final int coins;
  final double price;
  final String currency;
  final bool isSelected;
  final bool isPopular;
  final int tier;
  final int savingPercent;
  final VoidCallback? onPressed;

  const CoinsPackWidget({
    super.key,
    required this.name,
    required this.coins,
    required this.price,
    required this.currency,
    required this.isSelected,
    this.isPopular = false,
    this.tier = 0,
    this.savingPercent = 0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final stack = (tier + 1).clamp(1, 4);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.10)
              : colorScheme.surfaceContainer,
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ]
              : null,
        ),
        child: Row(
          children: [
            // Coin stack: bigger packs show more coins.
            SizedBox(
              width: 64,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < stack; i++)
                    Positioned(
                      left: 4.0 + i * 8,
                      top: 14.0 - i * 4,
                      child: CoinIcon(size: 30 + tier * 2.0),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(name, style: appStyle.H5(weight: 'bold')),
                      if (isPopular)
                        _Badge(
                            text: translator.popular,
                            color: colorScheme.primary),
                      if (savingPercent > 0)
                        _Badge(
                            text: '-$savingPercent%',
                            color: Colors.green.shade600),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '$coins ',
                        style: appStyle
                            .H3(weight: 'bold')
                            .copyWith(color: _goldDark),
                      ),
                      TextSpan(
                          text: translator.coins_unit_label,
                          style: appStyle.H6(color: Colors.grey)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price.toStringAsFixed(0),
                    style: appStyle.H4(weight: 'bold')),
                Text(currency, style: appStyle.H6(color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                key: ValueKey(isSelected),
                color: isSelected ? colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
