import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Discussion.dart';
import 'package:munturai/model/garage.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/screens/garage.dart';
import 'package:munturai/screens/home.dart';
import 'package:munturai/services/api/helper.dart';
import '../model/User.dart';

class widgetGarage extends StatefulWidget{
  Garage garage;
  StateHomeScreen parent;
  widgetGarage({
    Key? key,
    required this.garage,
    required this.parent,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() => widgetGarage_(garage: garage,parent: parent);


}

class widgetGarage_ extends State<StatefulWidget>{
  Garage garage;
  StateHomeScreen parent;
  widgetGarage_({
    Key? key,
    required this.garage,
    required this.parent,
  });
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GarageDetails(garage: garage)));
        },
      child:  Container(
        padding: getPadding(all: 2),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child:
        Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Center(
                  child:
                  (garage.photo!='none' && garage.photo!='')?
                  Container(
                    margin: getMargin(all:8),
                    height: 50,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image:
                        DecorationImage(
                          image: NetworkImage('http://${ApiHelper().apiBaseUrl}${garage.photo}'),
                          fit: BoxFit.cover,
                        )
                    ),
                  ):
                  Container(
                    margin: getMargin(all:8),
                    height: 50,
                    width: 80,
                    decoration: BoxDecoration(
                      color: UIColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                      image:
                        DecorationImage(
                            image: AssetImage(ImageConstant.garage),
                            fit: BoxFit.contain
                        ),
                    ),
                  ),
              ),
            ),
            Container(
              padding: getPadding(left: 10,right: 10),
              width: size.width-132,
              child:
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(garage.nom,style: appStyle.H4(weight: 'bold'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                      Text(garage.description,style: appStyle.H5(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text('Note : ${garage.rating}/5',style: appStyle.H6(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
            Spacer(),
            Column(
              children: [
                IconButton(
                  onPressed: (){
                    parent.centerMapOnPosition(garage,context);
                    parent.setState(() {
                      
                    });
                    // show on the map

                  }, 
                  icon: Icon(Icons.adjust_rounded,color: Theme.of(context).colorScheme.primary,),
                ),
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                Text(garage.distance>1000?'${(garage.distance/1000).toString().substring(0,3)} Km':'${(garage.distance).floor().toString().substring(0,3)} m',style: appStyle.H6(weight: 'bold'),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
