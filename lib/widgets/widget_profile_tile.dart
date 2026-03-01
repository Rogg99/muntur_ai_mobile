import 'package:munturai/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/colors/colors.dart';

class ProfileTile extends StatefulWidget {
  final Widget icon;
  final String text;
  final String desc;
  final double? padding;
  final double? width;
  final double? radius;
  final Function? onPressed;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.text,
    required this.desc,
    required this.onPressed,
    this.padding = 20.0,
    this.width = double.maxFinite,
    this.radius = 15.0,
  });

  @override
  State<ProfileTile> createState() => ProfileTileState();
}

class ProfileTileState extends State<ProfileTile> {
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;
    return GestureDetector(
        onTap: widget.onPressed != null ? () => widget.onPressed!() : null,
        child: Container(
          width:  widget.width!,
          margin: getMargin(top: 20),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark?Colors.white30.withOpacity(0.1):Colors.black38.withOpacity(0.1),
          ),
          child: Row(
            children: [
              widget.icon,
              Container(
                width: (widget.width!>BodyWidth())?BodyWidth()*0.75:widget.width!*0.75,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.text,
                            style: appStyle.H4( weight: 'b',color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.desc,
                            overflow: TextOverflow.ellipsis,
                            style: appStyle.H6(color: ThemeProvider.of(context).themeMode() == ThemeMode.dark? Colors.white54:UIColors.txtInactive),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              Icon(Icons.edit,size: 18,),
            ],
          ),
        ),
      );
  }
}
