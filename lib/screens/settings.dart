import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:munturai/screens/abonnement.dart';
import 'package:munturai/screens/deconnection.dart';
import 'package:munturai/screens/profile.dart';
import 'package:munturai/screens/switchlanguage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';
import 'package:munturai/main.dart';
import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../core/theming/app_style.dart';
import '../core/theming/theme.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import 'package:munturai/screens/coins.dart';
import '../model/discussion.dart';
import '../model/user.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_message.dart';
import 'about.dart';
import 'cgu.dart';
import 'help.dart';
import '../core/app_export.dart';

bool light=false;
class Settings extends StatefulWidget{
  Settings({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  User? user;
  bool loading = true;
  String plan = 'FREE';

  @override
  void initState() {
    load();
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
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      body:
      loading ?  Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      ) :
      ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 80),
            child:
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(170),
                        image: DecorationImage(
                          image:
                          AssetImage(ImageConstant.imgEllipse),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(width: 5,color: Theme.of(context).colorScheme.primary)
                    ),
                  ),]
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${user!.nom} ${user!.prenom}', style: appStyle.H4(),),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.primaryContainer
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.subtitles),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(translator.subscription_free,style: appStyle.H5(color: isDark?Colors.white:Colors.black,weight: 'b'),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(plan!='GOLD')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if(plan=='FREE')
                  GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: BodyWidth()-40,
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(12, 42, 91, 1),
                        gradient: LinearGradient(
                            colors: [colorScheme.primary,const Color(0xFF121212)],
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(translator.subscription_premium,style: appStyle.H4(weight: 'b',color: Colors.white),),
                            Padding(padding: getPadding(top:15)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(translator.subscription_premium_desc,textAlign: TextAlign.center,style: appStyle.H5(color: Colors.white),),
                            ),
                            Padding(padding: getPadding(top:10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()));
                                  },
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color(0xFF121212)),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          )
                                      )),
                                  child:
                                  Text(
                                    translator.subscription_premium_upgrade,
                                    style: appStyle.H4(color: Colors.white,weight: 'bold'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()));
                    },
                    child: Container(
                      height: 100,
                      width: BodyWidth()-40,
                      margin: const EdgeInsets.only(left:10),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(12, 42, 91, 1),
                        image: DecorationImage(image: AssetImage('assets/images/fond_gold.jpg'),fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(translator.subscription_gold,style: appStyle.H4(weight: 'b',color: Colors.white),),
                            Padding(padding: getPadding(top:15)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(translator.subscription_gold_desc,textAlign: TextAlign.center,style: appStyle.H5(color: Colors.white),),
                            ),
                            Padding(padding: getPadding(top:10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){},
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          )
                                      )),
                                  child:
                                  Text(
                                    translator.subscription_gold_upgrade,
                                    style: appStyle.H4(color: Colors.white,weight: 'b'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
            },
            child: Container(
              padding: const EdgeInsets.all( 10),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.person_fill,size: 34,),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Text(translator.my_account,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),)
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.moon_stars_fill, size: 34),
                    const SizedBox(width: 8),
                    Text(
                      translator.dark_mode,
                      style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.transparent,
                  onChanged: (bool value) {
                    final newMode = value ? ThemeMode.dark : ThemeMode.light;

                    saveThemeMode(newMode); // <- Save to cache

                    ThemeSettingChange(
                      settings: ThemeSettings(
                        sourceColor: themeProvider.settings.value.sourceColor,
                        themeMode: newMode,
                      ),
                    ).dispatch(context);
                  },
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSwitcherView(initial: false,)));
            },
            child: Container(
              padding: EdgeInsets.all( 10),
              child: Row(
                children: [
                  Icon(CupertinoIcons.globe,size: 34,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Text(translator.language,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),)
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Help()));
            },
            child: Container(
              padding: EdgeInsets.all( 10),
              child: Row(
                children: [
                  Icon(CupertinoIcons.question,size: 34,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Text(translator.help,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),)
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CGU()));
            },
            child: Container(
              padding: EdgeInsets.all( 10),
              child: Row(
                children: [
                  Icon(CupertinoIcons.doc_text_search,size: 34,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Flexible(child: Text(translator.termsConditions,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),))
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          GestureDetector(
            onTap: (){

              Navigator.push(context, MaterialPageRoute(builder: (context) => Deconnexion()));
            },
            child: Container(
              padding: EdgeInsets.all( 10),
              child: Row(
                children: [
                  Icon(CupertinoIcons.arrowshape_turn_up_right,size: 34,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Text(translator.logout,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),)
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => About()));
            },
            child: Container(
              padding: EdgeInsets.all( 10),
              child: Row(
                children: [
                  Icon(CupertinoIcons.heart_circle_fill ,size: 34,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  Text(translator.about,style: appStyle.H5(weight: 'bold',color: Theme.of(context).colorScheme.onSurface),)
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5)),

        ],
      ),
    );
  }
  load() async{
    loading = true;
    user = await AuthApi().getUser().then((value) => value);
    await saveKey("lastPage",'settings');
    setState(() {
      loading = false;
    });
  }
}