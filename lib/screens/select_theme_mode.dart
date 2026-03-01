import 'package:munturai/screens/switchlanguage.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../widgets/primary_button.dart';
class SelectThemeMode extends StatefulWidget{
  const SelectThemeMode({super.key});

  @override
  State<SelectThemeMode> createState() => SelectThemeModeState();
}

class SelectThemeModeState extends State<SelectThemeMode> {
  late bool isDark = false;

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
    final themeProvider = ThemeProvider.of(context);
    isDark = themeProvider.themeMode() == ThemeMode.dark;
    AppLocalizations translator = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title:
        Text('${translator.dark_mode} ?',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: appStyle.H3(color: Theme.of(context).colorScheme.onSurface, weight: 'bold'),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        // elevation: 2,
      ),
      body:
      Container(
        height: double.maxFinite,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Padding(padding: getPadding(top:30)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isDark = false;
                      });
                      const newMode = ThemeMode.light;
                      saveThemeMode(newMode); // <- Save to cache
                      ThemeSettingChange(
                        settings: ThemeSettings(
                          sourceColor: themeProvider.settings.value.sourceColor,
                          themeMode: newMode,
                        ),
                      ).dispatch(context);
                    },
                    child: Container(
                      height: 300,
                      width: BodyWidth()/2-20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: !isDark ? Theme.of(context).colorScheme.primary:Colors.transparent,width: 3 ),
                      ),
                      child:
                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: getPadding(top:10,left: 10),
                                child:
                                Icon( isDark?Icons.circle_outlined:Icons.check_circle,color: Theme.of(context).colorScheme.primary,),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(
                              child: Text(
                                translator.no,
                                style: appStyle.H4(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: getPadding(left:20)),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isDark = true;
                      });
                      const newMode = ThemeMode.dark ;
                      saveThemeMode(newMode); // <- Save to cache
                      ThemeSettingChange(
                        settings: ThemeSettings(
                          sourceColor: themeProvider.settings.value.sourceColor,
                          themeMode: newMode,
                        ),
                      ).dispatch(context);
                    },
                    child: Container(
                      height: 300,
                      width: BodyWidth()/2-20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isDark ? Theme.of(context).colorScheme.primary:Colors.transparent,width: 3 ),
                      ),
                      child:
                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: getPadding(top:10,left: 10),
                                child:
                                Icon( !isDark?Icons.circle_outlined:Icons.check_circle,color: Theme.of(context).colorScheme.primary,),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Center(
                              child: Text(
                                translator.yes,
                                style: appStyle.H4(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )


                ],
              ),
              Padding(padding: getPadding(top:100)),
              PrimaryButton(
                text: translator.continue__,
                radius: 60,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSwitcherView()));
                },
              ),
              Padding(padding: getPadding(top:10)),
            ]
          ),
        ),
      ),
    );
  }

}
