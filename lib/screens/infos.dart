import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theming/app_style.dart';
import '../core/theming/theme.dart';
import '../core/utils/size_utils.dart';
import '../model/Info.dart';
import '../services/api/notification.dart';
import '../widgets/widget_info.dart';
import '../datas/samples.dart';

bool light=false;
class Infos extends StatefulWidget{
  Infos({Key? key})
      : super(
    key: key,
  );
  @override
  State<Infos> createState() => Infos_();
}
class Infos_ extends State<Infos>  with TickerProviderStateMixin{
  bool isLoading=true;
  List<Info> infos = [];
  @override
  void initState() {
    fetchInfos();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    List<Info> sampleInfos = [sampleInfo];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: !isLoading ?
      Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          )):
      Container(
        // padding: getPadding(left: 16,right: 16),
        child:
        ListView.separated(
          separatorBuilder: (context,i){
            return Padding(padding: getPadding(top: 15));
          },
          itemBuilder: (context,index){
            return
              WidgetInfo(
                info:sampleInfos[0]
              );
          }, itemCount: sampleInfos.length,
        )
      ),
    );
  }

  fetchInfos() async {
    print('fetching new infos');
    List<Info> infos_ = [];
    var datas=[];
    var results;
    await NotificationApi().getInfos().then((response) => {
      if (response.statusCode == 200)
        {
          results = json.decode(response.body),
          datas = results['data'],
          for (var i = 0; i < datas.length; i++)
            {
              infos_.add(Info(
                id: datas[i]["id"],
                path: datas[i]['path'],
                statut: datas[i]['statut'],
                image: datas[i]['image'],
                title: datas[i]['title'],
                time: datas[i]['time'],
              )),
            },
        },
        infos = infos_,
        isLoading = false,
        setState(() {})
    });
  }

}