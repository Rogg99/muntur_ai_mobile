import 'package:flutter/material.dart';

import '../core/theming/app_style.dart';

/// Selectable MoMo/card chip — originally private to marketplace_checkout.dart,
/// promoted here so the coins-pack and subscription purchase flows (which
/// gained the same MoMo/card choice once a4's payment consolidation shipped)
/// can reuse it instead of duplicating the widget.
class PaymentMethodChip extends StatelessWidget {
  const PaymentMethodChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.white30,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? colorScheme.primary : Colors.grey),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: appStyle.H6(
                    color: selected ? colorScheme.primary : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
