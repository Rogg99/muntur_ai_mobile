import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theming/app_style.dart';

class LoadingImage extends StatefulWidget {
  double width;
  double height;
  double radius;
  LoadingImage({
    Key? key,
    required this.height,
    required this.width,
    this.radius=0,
  }) : super(
    key: key,
  );
  @override
  State<LoadingImage> createState() => LoadingImageState(width: width,height: height,radius: radius);
}

class LoadingImageState extends State<LoadingImage> {
  double width;
  double height;
  double radius;
  LoadingImageState({
    Key? key,
    required this.height,
    required this.width,
    this.radius=0,
  });

  Timer timer=Timer(Duration.zero, () { });

  @override
  void initState() {
    StartAnimation();
    super.initState();
  }

  @override
  void dispose() {
    timer=Timer(Duration.zero, () { });
    super.dispose();
  }

  Color _color = Color.fromRGBO(200, 200, 200, 1,);

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return AnimatedContainer(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: _color,
      ),
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  StartAnimation(){
    timer = Timer.periodic(Duration(milliseconds: 500),(timer){
      _color = Color.fromRGBO(255, 255, 255, 1,);
      setState(() {});
      _color = Color.fromRGBO(200, 200, 200, 1,);
      setState(() {});
    });
  }
}