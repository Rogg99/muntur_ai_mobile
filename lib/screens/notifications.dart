import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/widget_notification.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../model/discussion.dart';
import '../model/Notification.dart' as NotificationModel;
import '../datas/samples.dart';
import '../model/user.dart';
import '../widgets/widget_discussion.dart';

bool light=false;
class Notifications extends StatefulWidget{
  const Notifications({super.key,});
  @override
  State<Notifications> createState() => NotificationsState();
}
class NotificationsState extends State<Notifications>  with TickerProviderStateMixin{
  bool loading = true;
  List<User> bloqueds = [];

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Discussion> discussions=[];
  User user = User();

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final themeProvider = ThemeProvider.of(context);
    Locale currentLocale = Localizations.localeOf(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;
    List<NotificationModel.Notification> notifications = [sampleNotification];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.notifications),
      body: Stack(
        children: [
          (loading)?
          Skeletonizer(
            enabled: loading,
            child:
            ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: 3 ,//matchs.length,
                itemBuilder: (context,index){
                  return
                    WidgetNotification(notification: notifications[0]);
                }),
          ):
          Column(
            children: [
              SizedBox(
                height: BodyHeight()-298,
                child:
                ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: 3 ,//matchs.length,
                    itemBuilder: (context,index){
                      return
                        WidgetNotification(notification: notifications[0]);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  load() async{
    loading = true;
    setState(() {});
    //user = await API.getUI_user().then((value) => value[0]);

    for(var i=0;i<10;i++)
      bloqueds.add(User());

    loading = false;
    setState(() {});

  }

}