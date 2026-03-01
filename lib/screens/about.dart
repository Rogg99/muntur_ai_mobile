import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../model/user.dart';
import '../widgets/CustomAppBar.dart';

bool light=false;
class About extends StatefulWidget{
  About({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<About> createState() => AboutState();
}
class AboutState extends State<About>  with TickerProviderStateMixin{
  User? user;
  bool loading = true;
  PackageInfo? packageInfo;

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

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: translator.about),
      body:Center(
        child: loading ?  SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ) :
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(ImageConstant.logo_white,width: 200,height: 200,)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(
                  'Version : ${packageInfo!.version}.${packageInfo!.buildNumber}',style: appStyle.H4()
                ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(
                    'Build date : 23-06-2025',style: appStyle.H4()
                ))
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(
                    'Copyright © 2025 by \n MUNTUR Inc.',
                  textAlign: TextAlign.center,
                  style: appStyle.H4(),
                ))
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 50)),
          ],
        ),
      ),
    );
  }

  load() async{
    setState(() {
      loading = true;
    });

    packageInfo =  await PackageInfo.fromPlatform();

    setState(() {
      loading = false;
    });
  }



}