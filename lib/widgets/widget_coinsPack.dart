
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:munturai/model/abonnement.dart';
import 'package:munturai/model/service.dart';
import 'package:munturai/screens/abonnement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:flutter/src/material/colors.dart' as Col;
import '../core/theming/app_style.dart';
import '../model/user.dart';
import 'package:vector_math/vector_math.dart';

class CoinsPackWidget extends StatefulWidget{
  double width,height;
  bool popular;
  bool selected;
  Function? onPressed;
  Product? service;
  CoinsPackWidget({
    super.key,
    required this.width,
    required this.height,
    required this.service,
    required this.selected,
    required this.onPressed,
    this.popular=false,
  });

  @override
  State<CoinsPackWidget> createState() => CoinsPackWidget_();
}

class CoinsPackWidget_ extends State<CoinsPackWidget> {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onPressed != null ? () => widget.onPressed!() : null,
      child: Stack(
        children: [
          Container(
            height: widget.height,
            width: widget.width,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration:
            BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Col.Colors.transparent,
              border: (widget.selected)?Border.all(color: colorScheme.primary,width: 2)
                  :Border.all(color: Col.Colors.white30)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.service!.shortName.toString(),
                  style: appStyle.H4(weight: 'b'),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${widget.service!.realPrice} ${widget.service!.currency}',
                  style: appStyle.txtRoboto(size: 18,color: const Color(0xFFAFAFAF)).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                    decorationColor: const Color(0xFFAFAFAF),
                  ),
                ),
                Text(
                    '${widget.service!.price} ${widget.service!.currency}',
                  style: appStyle.H4(weight: 'b')
                ),
                // Text(
                //   (widget.price/widget.service!.months).toStringAsFixed(2)+widget.currency+'/mois',
                //   style: appStyle.txtRoboto(size: 16,color: UIColors.txtInactive)
                // ),
              ],
            ),

          ),
          if(widget.popular)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colorScheme.secondary
              ),
              child: Text(translator.popular,style: appStyle.txtRoboto(color: UIColors.primaryAccent),),
            ),
          )
        ],
      ),
    );
  }
}
