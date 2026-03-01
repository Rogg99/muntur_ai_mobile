import 'package:munturai/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final IconData? icon;
  final String text;
  final double? padding;
  final double? radius;
  final Function? onPressed;
  final bool? loading;
  final Color? color;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    this.icon,
    required this.text,
    required this.onPressed,
    this.padding = 20.0,
    this.radius = 25.0,
    this.loading = false,
    this.color,
    this.textColor,
  });

  @override
  State<PrimaryButton> createState() => PrimaryButtonState();
}

class PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding!),
      child: CupertinoButton(
        color: widget.color ?? Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: widget.padding!),
        borderRadius: BorderRadius.circular(widget.radius!),
        onPressed: widget.onPressed != null ? () => widget.onPressed!() : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, color: Theme.of(context).colorScheme.background),
            if (widget.icon != null)
              const SizedBox(width: 8),
            Text(
              widget.text,
              style: appStyle.H5(
                weight: 'bold',
                color: widget.textColor ?? Theme.of(context).colorScheme.background,
              ),
            ),
            if(widget.loading!)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color:Theme.of(context).colorScheme.background,strokeWidth: 2,)),
              )
          ],
        ),
      ),
    );
  }
}
