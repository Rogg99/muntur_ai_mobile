import 'dart:async';
import 'dart:math';

import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  double size;
  Loading({
    Key? key,
    this.size =  15.0,
  }) : super(
    key: key,
  );
  @override
  State<Loading> createState() => LoadingState(size: size);
}

class LoadingState extends State<Loading> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    animation = Tween<double>(begin: 0, end: 4).animate(controller)
      ..addListener(() {
        setState(() {
        });
      });
    controller.forward();
    controller.repeat();
  }
  double size;
  LoadingState({
    Key? key,
    this.size =  15.0,
  });


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for(var i=0;i<3;i++)
          AnimatedContainer(
            duration: Duration(seconds: 1),
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: animation.value >= i ?size:size-5,
            height: animation.value >= i ?size:size-5,
            decoration: BoxDecoration(
              color: animation.value >= i ? Theme.of(context).colorScheme.primary : UIColors.blueGray100,
              borderRadius: BorderRadius.circular(20)
            ),
          ),
      ],
    );
  }

}