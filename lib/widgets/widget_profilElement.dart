import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';

class ElementWidget extends StatelessWidget {
  bool iconable;
  Widget icon;
  String text;
  ElementWidget({super.key,
    this.iconable = true,
    this.icon = const Icon(CupertinoIcons.xmark, size: 32,),
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations translator = AppLocalizations.of(context)!;
    final isDark = ThemeProvider.of(context).themeMode() == ThemeMode.dark;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isDark?colorScheme.surfaceContainer:fromHex('#F0F0F0')
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if(iconable)
          icon,
          Padding(padding: getPadding(left: 5)),
          Text(text,style: appStyle.H5(),),
          Padding(padding: getPadding(left: 5)),
        ],
      ),

    );

  }

}

class PreferenceWidget extends StatelessWidget {
  String title;
  String text;
  final void Function()? onTap;
  PreferenceWidget({
    Key? key,
    required this.title,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.secondaryContainer
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.xmark_circle_fill, size: 22,),
            Padding(padding: getPadding(left: 5)),
            Text('$title: ',style: appStyle.H5(),),
            Padding(padding: getPadding(left: 5)),
            Flexible(child: Text(text,style: appStyle.H5(),)),
          ],
        ),

      ),
    );

  }

}
