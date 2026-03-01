import 'package:munturai/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final IconData? icon;
  final String text;
  final double? padding;
  final Function? onPressed;

  const SecondaryButton({
    super.key,
    this.icon,
    required this.text,
    required this.onPressed,
    this.padding = 20.0,
  });

  @override
  State<SecondaryButton> createState() => SecondaryButtonState();
}

class SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding ?? 20.0),
      child: GestureDetector(
        onTap: widget.onPressed != null ? () => widget.onPressed!() : null,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(15)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, color: Theme.of(context).colorScheme.secondary),
              if (widget.icon != null)
                const SizedBox(width: 8),
              Text(
                widget.text,
                style: appStyle.H5(
                  weight: 'bold',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
