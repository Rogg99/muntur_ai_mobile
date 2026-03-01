import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import '../model/user.dart';
import 'login.dart';

bool light=false;
class Deconnexion extends StatefulWidget{
  Deconnexion({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<Deconnexion> createState() => DeconnexionState();
}
class DeconnexionState extends State<Deconnexion>  with TickerProviderStateMixin{
  User? user;
  bool loading = true;
  bool hidden = false;

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
        appBar: AppBar(
          leadingWidth: 90,
          centerTitle: true,
          leading:
          Center(
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title:
          Text(translator.logout,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H3(weight: 'bold'),
          ),
          backgroundColor: colorScheme.background,
        ),
        body:ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.logout_prompt,style: appStyle.H4(weight: 'b'),)
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child:
                  Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        margin: getMargin(bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                              image:
                              AssetImage(ImageConstant.imgEllipse),
                              //NetworkImage('http://munturai.steps4u.net/m/omc/'+(bloqueds[i].photos[0] as Map)['path']),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                      Text("${user!.nom} ${user!.prenom}",style: appStyle.H5(),),
                      //Text(user!.email,style: appStyle.txtRoboto(size: 20),),
                    ],
                  ),),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (){
                    _showLogoutDialog(context);
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(colorScheme.secondary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )
                      )),
                  child:
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(padding: getPadding(left:10)),
                        Text(
                          translator.logout_button,
                          style: appStyle.H5(),
                        ),
                        Padding(padding: getPadding(left:10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.or_separator,style: appStyle.H6(),)
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Text(translator.logout_delete_account,style: appStyle.H5(),),
                  onTap: (){
                    _showDeleteAccountDialog(context);
                  },
                )
              ],
            ),
          ],
        ),
    );
  }

  load() async{
    loading = true;
    user = await AuthApi().getUser().then((value) => value);
    setState(() {

    });

  }

  void _showLogoutDialog(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogcontext) {
        return AlertDialog(
          title: Text(translator.logout_title,style: appStyle.H4(weight: 'b'),),
          content:Text("En poursuivant vous devrez vous reconnecter à nouveau pour acceder à vos informations.",style: appStyle.H5(),),
          actions: <Widget>[
            TextButton(
              child: Text(translator.cancel,style: appStyle.H6(),),
              onPressed: () async{
                Navigator.of(dialogcontext).pop();
              },
            ),
            TextButton(
              child: Text(translator.logout,style: appStyle.H6(color: colorScheme.secondary),),
              onPressed: () async{
                await AuthApi().clearUserDatas();
                Navigator.of(dialogcontext).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogcontext) {
        return AlertDialog(
          title: Text(translator.logout_delete_account,style: appStyle.H5(),),
          content:Text("En poursuivant, vous allez perdre toutes les informations de votre compte.",
            style: appStyle.H5(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translator.cancel,style: appStyle.H6(),),
              onPressed: () async{
                Navigator.of(dialogcontext).pop();
              },
            ),
            TextButton(
              child: Text(translator.continue__,style: appStyle.H6(color: colorScheme.secondary),),
              onPressed: () async{
                await AuthApi().deleteUser(user!);
                await AuthApi().clearUserDatas();
                Navigator.of(dialogcontext).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}