import 'package:munturai/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/colors/colors.dart';

class CustomFilterCard extends StatefulWidget {
  final String title;
  final String desc;
  final Widget body;
  final Function? onClose;

  const CustomFilterCard({
    super.key,
    required this.desc,
    required this.body,
    required this.title,
    required this.onClose,
  });

  @override
  State<CustomFilterCard> createState() => CustomFilterCardState();
}

class CustomFilterCardState extends State<CustomFilterCard> {

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isDark = ThemeProvider.of(context).themeMode() == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
          children: [
            GestureDetector(
              onTap: widget.onClose != null ? () => widget.onClose!() : null,
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, isDark?0.8:0.2)
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child:
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: colorScheme.background,
                ),
                child:
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Spacer(),
                          GestureDetector(
                              onTap: widget.onClose != null ? () => widget.onClose!() : null,
                              child: Icon(CupertinoIcons.xmark,size: 28,weight: 2,)
                          )
                        ],
                      ),
                      Padding(padding: getPadding(top: 30)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.title,style: appStyle.H4(weight: 'b',color: colorScheme.onSurface).copyWith(decoration: TextDecoration.none),),
                        ],
                      ),
                      Padding(padding: getPadding(top: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text(widget.desc,
                            textAlign: TextAlign.center,
                            style: appStyle.H5(color: colorScheme.onSurface).copyWith(decoration: TextDecoration.none),)),
                        ],
                      ),
                      Padding(padding: getPadding(top: 20)),
                      widget.body,
                      Padding(padding: getPadding(top: 20)),
                  
                    ],
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }
}
