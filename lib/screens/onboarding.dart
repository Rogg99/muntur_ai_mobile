import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'package:munturai/screens/register.dart';
import '../widgets/primary_button.dart';
import 'login.dart';

import 'package:infinite_carousel/infinite_carousel.dart';

class OnBoarding extends StatefulWidget{
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  late bool progressbarVisibility = false;
  int pageIndex = 0;
  late InfiniteScrollController _controller;
  final images = [ImageConstant.affiche,ImageConstant.imgEllipse,ImageConstant.affiche,];
  Timer? _autoScrollTimer;
  @override
  void initState() {
    _controller = InfiniteScrollController(initialItem: 0);
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (_) {
      final nextItem = _controller.selectedItem + 1;
      _controller.animateToItem(
        nextItem,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      body:
      Container(
        height: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Padding(padding: getPadding(top:30)),
              SizedBox(
                height: 360, // Adjust as needed
                child: InfiniteCarousel.builder(
                  itemCount: images.length,
                  itemExtent: 250, // width of each item
                  center: true,
                  controller: _controller,
                  loop: true,
                  velocityFactor: 0.2,
                  onIndexChanged: (index){
                    setState(() {
                      pageIndex = index;
                    });
                  },
                  itemBuilder: (context, itemIndex, realIndex) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final selected = _controller.selectedItem == itemIndex;
                        final scale = selected ? 1.0 : 0.85;

                        return Transform.scale(
                          scale: scale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                images[itemIndex % images.length],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(padding: getPadding(top:10)),
              Text(pageIndex==0?'AI Matching':pageIndex==1?'Matchs':'Premium',
                style: appStyle.H3(
                    weight: 'bold',
                    color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 10),
                  child: Text(
                    pageIndex == 0
                        ? 'Notre plateforme utilise un algorithme à la pointe de la technologie pour vous assurer les meilleurs matchs possible.'
                        : pageIndex == 1
                        ? 'Consultez vos matchs compatibles et commencez à créer des connexions significatives dès aujourd’hui.'
                        : 'Débloquez des fonctionnalités exclusives avec Premium et maximisez vos chances de trouver la personne idéale.',
                    style: appStyle.H6(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(padding: getPadding(top:10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < images.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pageIndex == i
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(padding: getPadding(top:40)),
              PrimaryButton(
                text: 'Créer un compte',
                // icon: EvaIcons.personAdd,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup2()));
                },
              ),
              Padding(padding: getPadding(top:20)),
              RichText(
                  text: TextSpan(
                    text: translator.already_have_account,
                    style: appStyle.H6(),
                    children: [
                      TextSpan(
                        text: translator.login_here,
                        style: appStyle.H6(
                          color: Theme.of(context).colorScheme.secondary,
                          weight: 'bold'
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                        },
                      ),
                    ]
                  )
              ),
              Padding(padding: getPadding(top:10)),
            ]
          ),
        ),
      ),
    );
  }

}
