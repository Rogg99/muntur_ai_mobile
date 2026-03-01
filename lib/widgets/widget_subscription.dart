
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
import '../model/service.dart';
import '../model/user.dart';
import 'package:vector_math/vector_math.dart';

class SubscriptionWidget extends StatefulWidget{
  double width,height;
  bool popular;
  String type;
  int index;
  Product? service;
  SubscriptionState subscriptionState;
  SubscriptionWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.service,
    required this.type,
    required this.index,
    required this.subscriptionState,
    this.popular=false,
  }) : super(
    key: key,
  );

  @override
  State<SubscriptionWidget> createState() => SubscriptionWidget_();
}

class SubscriptionWidget_ extends State<SubscriptionWidget> {


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
      onTap: (){
        setState(() {
          widget.subscriptionState.setState(() {
            widget.subscriptionState.SubIndex = widget.index;
            widget.subscriptionState.abonnement = Abonnement(type: widget.type,time: 30*widget.service!.months,price: widget.service!.price);
          });

        });
      },
      child: Stack(
        children: [
          Container(
            height: widget.height,
            width: widget.width,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration:
            (widget.subscriptionState.SubIndex==widget.index && widget.type=='Gold')?
            BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                    image: AssetImage('assets/images/fond_gold.jpg'),
                    fit: BoxFit.cover,opacity: 0.8),
                border: (widget.subscriptionState.SubIndex==widget.index)?Border.all(color: Col.Colors.transparent,width: 2)
                    :Border.all(color: UIColors.txtInactive)
            ):
            BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: (widget.subscriptionState.SubIndex==widget.index)?colorScheme.primary:Col.Colors.transparent,
              border: (widget.subscriptionState.SubIndex==widget.index)?Border.all(color: colorScheme.primary,width: 2)
                  :Border.all(color: Col.Colors.white30)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.service!.months.toString(),
                  style: appStyle.H4(weight: 'b'),
                ),
                Text(
                  widget.service!.months>1?
                  translator.months:translator.month,
                  style: appStyle.H5(),
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
