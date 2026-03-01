import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/presentation.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/model/token.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import '../core/fonctions.dart';
import 'package:munturai/screens/login.dart';
import '../services/logging.dart';
import 'home.dart';

class SplashscreenScreen extends StatefulWidget {
  const SplashscreenScreen({super.key});
  @override
  State<SplashscreenScreen> createState() => Animated();
}

class Animated extends State<SplashscreenScreen> with TickerProviderStateMixin {
  String uitheme='light';
  late Animation<double> animation;
  late AnimationController controller;
  var results;

  @override
  void initState() {
    loadNext();
    super.initState();
  }

  void loadNext(){
    Timer(const Duration(seconds: 5), () {
      if (true) {
        Token? tokenFromAPI;
        int lastLogin;
        AuthApi().getToken().then((value) async {
          if (value != null) {
            tokenFromAPI = value as Token;
            // lastLogin = tokenFromAPI!.time.toInt();
            lastLogin = await getKey('last_login').then((value) => value!=''?double.parse(value).toInt():0);
            log('Munturai DEBUG: local token time :  $lastLogin');
            log('Munturai DEBUG: actual time :  ${DateTime.now().millisecondsSinceEpoch / 1000}');

            if (lastLogin > DateTime.now().millisecondsSinceEpoch / 1000) {
              log('Munturai DEBUG: local token access not expired :  ${tokenFromAPI!.access}');
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              log('Munturai DEBUG: local token access expired ');
              log('Munturai DEBUG: refreshing token ');
              AuthApi().login(tokenFromAPI!.email, tokenFromAPI!.password).then((response) async {
                if (response.statusCode == 200) {
                  results = json.decode(response.body);
                  log("DEBUG Munturai : new token access ,  : ${results['token']['access']}");
                  tokenFromAPI!.time = DateTime.now().millisecondsSinceEpoch / 1000 + (3600 * 24 * 7);
                  tokenFromAPI!.access = results['token']['access'];
                  tokenFromAPI!.refresh = results['token']['refresh'];
                  lastLogin = tokenFromAPI!.time.toInt();
                  await saveKey('last_login', lastLogin.toString());
                  await saveKey('token', tokenFromAPI!.toJson().toString());
                  if (!mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  log('Munturai DEBUG: auto login failed');
                  if (!mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                }
              }).onError((error, stackTrace) {
                ThrowError(error!, stackTrace);
                return null;
              });
            }
          } else {
            await DatabaseHelper().createTables();
            Timer( const Duration(seconds: 1),
              () {
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PresentationScreen()));
              },
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body:
        SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Center(
            child: Image.asset(
              ImageConstant.logo_white,
              height: 250,
              width: 250,
            ),
          ),
        )
    );

  }
}
