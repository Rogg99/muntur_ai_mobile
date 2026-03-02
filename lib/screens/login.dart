import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Token.dart';
import 'package:munturai/screens/home.dart';
import 'package:munturai/screens/register.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/widgets/primary_button.dart';

import '../core/app_export.dart';
import '../model/User.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key})
      : super(
          key: key,
        );

  @override
  ConsumerState<Login> createState() => _loginState();
}

class _loginState extends ConsumerState<Login> with TickerProviderStateMixin {
  late bool progressbarVisibility = false;
  late Color textFieldColor = UIColors.blueGray100;
  late String textFieldMessage = "";
  late Animation<double> animation;
  late AnimationController controller;
  final emailText = TextEditingController();
  final pwdText = TextEditingController();

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animation = Tween<double>(begin: 0, end: 360).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    emailText.dispose();
    pwdText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    var isDark = themeProvider.themeMode() == ThemeMode.dark;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: true,
        body: ListView(children: [
          Padding(padding: getPadding(top: 100)),
          Container(
            padding: getPadding(all: 10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 170,
            decoration: BoxDecoration(
                color: UIColors.primaryAccent,
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                ImageConstant.logo_dark,
                width: BodyWidth() - 60,
                fit: BoxFit.fitWidth,
                height: 150,
              ),
            ]),
          ),
          Padding(padding: getPadding(top: 10)),
          Container(
            margin: getMargin(left: 20, right: 20),
            padding: getPadding(all: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(
                  translator.login,
                  style: appStyle.H3(weight: 'bold'),
                ),
                Padding(padding: getPadding(top: 25)),
                TextField(
                  controller: emailText,
                  style: appStyle.H5(),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: translator.emailHint,
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(padding: getPadding(top: 15)),
                TextField(
                  controller: pwdText,
                  style: appStyle.H5(),
                  obscureText: true,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: translator.hint_password,
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(padding: getPadding(top: 5)),
                Text(
                  '$textFieldMessage',
                  style: appStyle.txtArimoHebrewSubset(size: 16).copyWith(
                      fontStyle: FontStyle.italic, color: textFieldColor),
                ),
                Padding(padding: getPadding(top: 15)),
                PrimaryButton(
                  text: translator.login_button,
                  onPressed: () {
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) =>  HomeScreen()));
                    connect();
                  },
                  loading: progressbarVisibility,
                ),
                Padding(padding: getPadding(top: 20)),
              ],
            ),
          ),
          Padding(padding: getPadding(top: 10)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.onBackground,
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
                Text(
                  translator.or_separator,
                  style: appStyle.H6(),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.onBackground,
                    thickness: 1,
                    indent: 10,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: getPadding(top: 20)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Signup2()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translator.create_account,
                  style:
                      appStyle.H5(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ]));
  }

  void connect() async {
    setState(() {
      progressbarVisibility = true;
      textFieldMessage = "";
    });

    bool emailValid = RegExp(r'\S+@\S+\.\S+').hasMatch(emailText.text.trim());
    if (emailValid && pwdText.text.isNotEmpty) {
      try {
        await ref
            .read(authStateProvider.notifier)
            .login(emailText.text.trim(), pwdText.text);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        setState(() {
          textFieldColor = Colors.redAccent;
          progressbarVisibility = false;
          textFieldMessage =
              "Echec de connexion, Veuillez verifier vos informations de connexion!";
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("connexion failed"),
        ));
      }
    } else {
      setState(() {
        textFieldColor = Colors.redAccent;
        progressbarVisibility = false;
        textFieldMessage = "Veuillez verifier vos informations de connexion!";
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("connexion failed"),
      ));
    }
  }
}
