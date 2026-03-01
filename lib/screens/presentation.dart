import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/login.dart';
import 'package:munturai/widgets/custom_image_view.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/widgets/primary_button.dart';
import 'home.dart';

class PresentationScreen extends StatefulWidget {
  PresentationScreen({Key? key})
      : super(
          key: key,
        );
  @override
  State<PresentationScreen> createState() => Animated();
}

class Animated extends State<PresentationScreen> with TickerProviderStateMixin {
  String uitheme='light';
  late Animation<double> animation;
  late AnimationController controller;
  var results;
  @override
  void initState() {
      getKey('theme').then((value) => (){
        log('AppTheme : $value');
          uitheme=value;
       setState(() {
       });
     });
    super.initState();
    int i = 1;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    animation = Tween<double>(begin: 0, end: 6).animate(controller)
      ..addListener(() {
        setState(() {
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    var themeProvider = ThemeProvider.of(context);
    return Scaffold(
      backgroundColor: UIColors.primaryAccent,
      body: Container(
        width: double.maxFinite,
        padding: getPadding(
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: getPadding(
                top: 25,
                bottom: 30,
              ),
              child: Text(
                "Welcome to MUNTUR AI, your AI Assistant",
                maxLines: null,
                textAlign: TextAlign.center,
                style: appStyle.H3(weight: 'bold'),
              ),
            ),
            Padding(
              padding: getPadding(
                top: 25,
                bottom: 30,
              ),
              child: Text(
                "The AI that help you on everything concerning car repair!Connect and Enjoy it!",
                maxLines: null,
                textAlign: TextAlign.center,
                style: appStyle.H5(),
              ),
            ),
            CustomImageView(
              fit: BoxFit.fitWidth,
              asset: ImageConstant.affiche,
              height: 400,
              width: BodyWidth(),
            ),
            Padding(padding: getPadding(top:25)),
            PrimaryButton(
              text: translator.continue__,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
              }
            )
          ],
        ),
      ),
    );
  }
}
