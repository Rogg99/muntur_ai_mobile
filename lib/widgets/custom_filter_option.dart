import 'package:munturai/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomFilterOption extends StatefulWidget {
  final IconData? icon;
  final String text;
  final double? padding;
  final Function? onPressed;
  final bool isSelected;

  const CustomFilterOption({
    super.key,
    this.icon,
    this.isSelected=false,
    required this.text,
    required this.onPressed,
    this.padding = 20.0,
  });

  @override
  State<CustomFilterOption> createState() => CustomFilterOptionState();
}

class CustomFilterOptionState extends State<CustomFilterOption> {

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onPressed != null ? () => widget.onPressed!() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: getPadding(top: 10),
        decoration: BoxDecoration(
            color: widget.isSelected ? colorScheme.primary : colorScheme.surface,
            border: Border.all(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.text,
                style: appStyle.H5().copyWith(
                  color: widget.isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // if (widget.isSelected)
            Icon(widget.isSelected?Icons.check_circle:Icons.circle_outlined, color: widget.isSelected?Colors.white:colorScheme.primary)
          ],
        ),
      ),
    );
  }
}
