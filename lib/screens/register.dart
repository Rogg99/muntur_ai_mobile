import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Token.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:munturai/widgets/primary_button.dart';
import '../core/app_export.dart';
import 'package:munturai/utils/divisionsFilter.dart';
import 'package:munturai/model/user.dart';

import 'home.dart';

class Signup2 extends StatefulWidget{
  Signup2({Key? key})
      : super(
    key: key,
  );

  @override
  State<Signup2> createState() => _signupState();
}

class _signupState extends State<Signup2> with TickerProviderStateMixin {
  late bool progressbarVisibility = false;
  // Les couleurs dépendant du BuildContext ne doivent pas être initialisées
  // ici. Elles sont assignées dans didChangeDependencies.
  late Color textFieldColor;
  late String textFieldMessage = "";
  late Animation<double> animation;
  late AnimationController controller;
  final emailText = TextEditingController();
  final pwdText = TextEditingController();

  bool sexe=false,privacyPolicy=false,
      show_loading=false;
  bool loading_datas=true;
  String photo='';
  int pageIndex=0;
  String selectedRegion = '';

  List<String> allPays = countries_eng;
  String selectedPays = 'Cameroon';
  String selectedIndicator = '+237';

  String parrain = "none";
  String parti = "none";

  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final pwdCfcontroller = TextEditingController();
  final birthdaycontroller = TextEditingController();
  final birthmonthcontroller = TextEditingController();
  final birthyearcontroller = TextEditingController();
  final villecontroller = TextEditingController();
  final payscontroller = TextEditingController();


  // Couleurs initialisées plus tard via didChangeDependencies
  late Color emailFieldColor;
  late Color pwdFieldColor;
  late Color pwdCfFieldColor;
  late Color nomFieldColor;
  late Color prenomFieldColor;
  late Color dayFieldColor;
  late Color monthFieldColor;
  late Color yearFieldColor;
  late Color phoneFieldColor;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ici on peut utiliser Theme.of(context)
    final cs = Theme.of(context).colorScheme;
    // surfaceVariant est déprécié -> utiliser surfaceContainerHighest
    textFieldColor = cs.surfaceContainerHighest;
    emailFieldColor = cs.primary;
    pwdFieldColor = cs.primary;
    pwdCfFieldColor = cs.primary;
    nomFieldColor = cs.primary;
    prenomFieldColor = cs.primary;
    dayFieldColor = cs.primary;
    monthFieldColor = cs.primary;
    yearFieldColor = cs.primary;
    phoneFieldColor = cs.primary;
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.all(16.h),
        children: [
          Padding(padding: getPadding(top:50)),
          Center(
            child: Text(translator.register,
              style: appStyle.H3(weight: 'bold'),
            ),
          ),
          Padding(padding: getPadding(top:25)),
          TextField(
            controller: namecontroller,
            style: appStyle.H6(),
            keyboardType: TextInputType.text,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.firstNameHint,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                gapPadding: 1,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),

            ),
          ),
          Padding(padding: getPadding(top:15)),
          TextField(
            controller: prenomcontroller,
            style: appStyle.H6(),
            keyboardType: TextInputType.text,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.secondNameHint,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                gapPadding: 1,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),

            ),
          ),
          Padding(padding: getPadding(top:15)),
          TextField(
            controller: emailcontroller,
            style: appStyle.H6(),
            keyboardType: TextInputType.emailAddress,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.emailHint,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                gapPadding: 1,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),

            ),
          ),
          Padding(padding: getPadding(top:15)),
          TextField(
            controller: pwdcontroller,
            style: appStyle.H6(),
            obscureText: true,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.password_hint,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(padding: getPadding(top:15)),
          TextField(
            controller: pwdCfcontroller,
            style: appStyle.H6(),
            obscureText: true,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.hint_password_confirm,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(padding: getPadding(top:15)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                width: 100,
                child:
                DropdownButton(
                    value:selectedIndicator,
                    isExpanded:true,
                    items: ['+237','+242','+227'].map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item,style: appStyle.H5(),),
                      );
                    }).toList(),
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    onChanged: (String? value){
                      selectedIndicator=value!;
                      setState(() {
                      });
                    }),
              ),
              // Faire en sorte que le TextField prenne l'espace restant pour éviter
              // les erreurs de layout dans un Row à largeur non contrainte.
              Expanded(
                child: TextField(
                 controller: phonecontroller,
                 style: appStyle.H6(),
                 keyboardType: TextInputType.phone,
                 cursorColor: UIColors.cursorColor,
                 decoration: InputDecoration(
                   hintText: translator.phoneHint,
                   fillColor: UIColors.edittextFillColor,
                   border: OutlineInputBorder(
                     gapPadding: 1,
                     borderRadius: BorderRadius.circular(10),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                     borderRadius: BorderRadius.circular(10),
                   ),

                 ),
                ),
              ),
            ],
          ),
          Padding(padding: getPadding(top:15)),
          TextField(
            controller: villecontroller,
            style: appStyle.H6(),
            keyboardType: TextInputType.text,
            cursorColor: UIColors.cursorColor,
            decoration: InputDecoration(
              hintText: translator.enter_city_hint,
              fillColor: UIColors.edittextFillColor,
              border: OutlineInputBorder(
                gapPadding: 1,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),

            ),
          ),
          Padding(padding: getPadding(top:15)),
          Container(
            padding: getPadding(all: 5),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.place),
                Padding(padding: getPadding(left: 8)),
                Text(translator.countryHint,
                  style: appStyle.H5(),),
                Spacer(),
                Container(
                  height: 40,
                  width: 150,
                  child:
                  DropdownButton(
                      value:selectedPays,
                      isExpanded:true,
                      items: allPays.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item,style: appStyle.H5(),),
                        );
                      }).toList(),
                      icon: Icon(Icons.arrow_drop_down_rounded),
                      onChanged: (String? value){
                        selectedPays=value!;
                        setState(() {
                        });
                      }),
                ),
              ],
            ),
          ),//pays
          Padding(padding: getPadding(top: 15)),
          Row(
            children: [
              const Icon(Icons.man),
              Padding(padding: getPadding(left: 8)),
              Text(translator.genderLabel,
                style: appStyle.H5(),),
              Spacer(),
              Text(translator.genderMale,
                style: appStyle.H5(color: sexe==false?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
              Switch(
                value: sexe,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(context).colorScheme.background,
                inactiveThumbColor: Theme.of(context).colorScheme.onBackground,
                onChanged: (bool value) {
                  sexe=!sexe;
                  setState(() {
                  });
                },
              ),
              Text(translator.genderFemale,
                style: appStyle.H5(color: sexe?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ],
          ),
          Padding(padding: getPadding(top: 15)),
          Row(
            children: [
              const Icon(Icons.cake_outlined),
              Padding(padding: getPadding(left: 2)),
              Text(translator.birthDateLabel,
                style: appStyle.H5(),),
              const Spacer(),
              Container(
                height: 40,
                width: 50,
                margin: getMargin(right: 10),
                child:
                TextField(
                  controller: birthdaycontroller,
                  style: appStyle.H5(),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Day',
                    fillColor: UIColors.edittextFillColor,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: dayFieldColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
              ),
              Container(
                height: 40,
                width: 50,
                margin: getMargin(right: 10),
                child:
                TextField(
                  controller: birthmonthcontroller,
                  keyboardType: TextInputType.number,
                  style: appStyle.H5(),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Month',
                    fillColor: UIColors.edittextFillColor,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: monthFieldColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
              ),
              Container(
                height: 40,
                width: 50,
                child:
                TextField(
                  controller: birthyearcontroller,
                  style: appStyle.H5(),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Year',
                    fillColor: UIColors.edittextFillColor,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: yearFieldColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
              ),
            ],
          ),
          Padding(padding: getPadding(top: 15)),
          Text('$textFieldMessage',
            style: appStyle.H6().copyWith(
                fontStyle: FontStyle.italic,
                color: textFieldColor
            ),
          ),
          Padding(padding: getPadding(top:15)),
          PrimaryButton(
            text: translator.register,
            onPressed: () { register(); },
            loading: show_loading,
          ),
          Padding(padding: getPadding(top:30)),
        ],
      )
    );
  }

  Future<void> register() async {
    // Commencer l'inscription
    log('muntur DEBUG: -- Signup-- starting register');
    setState(() {
      show_loading = true;
      textFieldMessage = '';
    });

    bool emailValid = RegExp(r'\S+@\S+\.\S+').hasMatch(emailcontroller.text.trim());

    // Validation côté client
    if (namecontroller.text.isEmpty) {
      setState(() {
        nomFieldColor = Colors.redAccent;
        textFieldMessage = "Please fill correctly the case First Name*";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }
    if (prenomcontroller.text.isEmpty) {
      setState(() {
        prenomFieldColor = Colors.redAccent;
        textFieldMessage = "Please fill correctly the case Second Name*";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }
    if (pwdcontroller.text.isEmpty) {
      setState(() {
        pwdFieldColor = Colors.redAccent;
        textFieldMessage = "Please fill correctly the case password*";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }
    if (pwdcontroller.text != pwdCfcontroller.text) {
      setState(() {
        pwdCfFieldColor = Colors.redAccent;
        textFieldMessage = "Password not matching, Please fill correctly the cases";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }
    if (!emailValid) {
      setState(() {
        emailFieldColor = Colors.redAccent;
        textFieldMessage = "Email is incorrect";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }
    try {
      if (birthdaycontroller.text.isEmpty || int.parse(birthdaycontroller.text) > 31 || int.parse(birthdaycontroller.text) < 0) {
        setState(() {
          dayFieldColor = Colors.redAccent;
          textFieldMessage = "Please fill correctly the case Day of birth date*";
          textFieldColor = Colors.redAccent;
          show_loading = false;
        });
        return;
      }
      if (birthmonthcontroller.text.isEmpty || int.parse(birthmonthcontroller.text) > 12 || int.parse(birthmonthcontroller.text) < 0) {
        setState(() {
          monthFieldColor = Colors.redAccent;
          textFieldMessage = "Please fill correctly the case Month of birth date*";
          textFieldColor = Colors.redAccent;
          show_loading = false;
        });
        return;
      }
      if (birthyearcontroller.text.isEmpty || int.parse(birthyearcontroller.text) < 1950 || int.parse(birthyearcontroller.text) > DateTime.now().year-14) {
        setState(() {
          yearFieldColor = Colors.redAccent;
          textFieldMessage = "Please fill correctly the case year of birth date*";
          textFieldColor = Colors.redAccent;
          show_loading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        textFieldColor = Colors.redAccent;
        textFieldMessage = 'Invalid numeric input in date fields';
        show_loading = false;
      });
      return;
    }

    if (!validDate("${birthdaycontroller.text}/${birthmonthcontroller.text}/${birthyearcontroller.text}")) {
      setState(() {
        dayFieldColor = Colors.redAccent;
        textFieldMessage = "Please fill correctly the cases of birth date* format jj/mm/aaaa ex 12/10/1995";
        textFieldColor = Colors.redAccent;
        show_loading = false;
      });
      return;
    }

    // Construire l'objet utilisateur
    User inscription = User();
    inscription.nom = namecontroller.text;
    inscription.prenom = prenomcontroller.text;
    inscription.email = emailcontroller.text.trim();
    inscription.password = pwdcontroller.text;
    inscription.telephone = phonecontroller.text;
    inscription.ville = villecontroller.text;
    inscription.photo = "none";
    inscription.sexe = sexe ? 'FEMALE' : 'MALE';
    inscription.date_naissance = "${birthyearcontroller.text}-${birthmonthcontroller.text}-${birthdaycontroller.text}";
    inscription.pays = selectedPays;

    Token tokenFromAPI = Token(refresh: '', access: '', time: 0, email: '', password: '');
    try {
      final response = await AuthApi().signup(inscription);
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        // setState(() {
        //   textFieldMessage = 'Sign up successfully done';
        //   textFieldColor = Theme.of(context).colorScheme.primary;
        // });
        toast('Sign up successfully done');

        final respProfile = await AuthApi().getProfile(token: jsonDecode(response.body)['token']['access']);
        log(jsonDecode(respProfile.body).toString());
        if (!mounted) return;
        if (respProfile.statusCode == 200 || respProfile.statusCode == 201) {
          log('Muntur DEBUG: signup and profile fetch successful');
          tokenFromAPI.time = DateTime.now().millisecondsSinceEpoch / 1000 + (3600 * 24 * 7);
          tokenFromAPI.password = inscription.password;
          tokenFromAPI.email = inscription.email;
          tokenFromAPI.access = jsonDecode(response.body)['token']['access'];
          tokenFromAPI.refresh = jsonDecode(response.body)['token']['refresh'];

          log('Muntur DEBUG: saving token and user to local storage');
          await saveKey('last_login', tokenFromAPI.time.toString());
          await saveKey('token', tokenFromAPI.toJson().toString());
          await saveKey('user', User.fromJson(json.decode(respProfile.body)).toJson().toString());
          log('Muntur DEBUG: token and user saved');
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) =>  HomeScreen()));

        } else {
          setState(() {
            textFieldColor = Colors.redAccent;
            show_loading = false;
            textFieldMessage = "Sign in failed. Please try again!";
          });
          log('Muntur DEBUG: connexion error');
          log('connexion failed with : ${respProfile.body}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("connexion failed"),
            ));
          }
          return;
        }
      } else {
        final body = json.decode(response.body);
        setState(() {
          textFieldMessage = 'Sign up failed with :  ${body['description']}';
          textFieldColor = UIColors.errorColor;
          show_loading = false;
        });
        toast('Sign up failed with : ${body['description']}', color: Colors.grey);
        log('Muntur DEBUG: ${response.body}');
        return;
      }
    } catch (e) {
      setState(() {
        textFieldColor = Colors.redAccent;
        textFieldMessage = 'An error occurred: $e';
        show_loading = false;
      });
      log('Muntur DEBUG exception: $e');
      return;
    } finally {
      if (mounted) {
        setState(() {
          show_loading = false;
        });
      }
    }
  }

  bool validDate(String date) {
    log('validating date');
    DateFormat format = DateFormat("dd/MM/yyyy");
    log('$date');
    try {
      DateTime dayOfBirthDate = format.parseStrict(date);
      log('birthdate ' + dayOfBirthDate.toString());
      return true;
    } catch (e) {
      log('$e');
      return false;
    }
  }

  int getTime(String date){
    int time=0;
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime dayOfBirthDate = format.parseStrict(date);
    time = (dayOfBirthDate.millisecondsSinceEpoch/1000).floor();
    return time;
  }

}
