import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theming/app_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? showBack;
  final String titleTxt;
  final Color? bgColor;

  const CustomAppBar({
    super.key,
    required this.titleTxt,
    this.showBack = true,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final effectiveBgColor = bgColor ?? Theme.of(context).colorScheme.background;

    return AppBar(
      leading: showBack == true
          ? Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      centerTitle: true,
      title: Text(
        titleTxt,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: appStyle.H3(weight: 'bold'),
      ),
      backgroundColor: effectiveBgColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}