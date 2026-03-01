import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/garage.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/screens/garage.dart';
import 'package:munturai/screens/home.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import 'package:munturai/services/api/helper.dart';
import '../model/user.dart';
import 'loading_image.dart';


class WidgetMarker extends StatefulWidget{
  final Garage garage;
  final StateHomeScreen parent;
  const WidgetMarker({
    super.key,
    required this.garage,
    required this.parent,
  });

  @override
  State<StatefulWidget> createState() => WidgetMarkerState(garage: garage,parent: parent);
}
class WidgetMarkerState extends State<WidgetMarker>{
  Garage garage;
  StateHomeScreen parent;
  WidgetMarkerState({
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
    return 
      GestureDetector(
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GarageDetails(garage: garage)));
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(garage.nom,
                  style: appStyle.H5(
                    weight: 'Bold',
                    color: parent.selectedGarage!.id == garage.id ?Colors.blue: Colors.red),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Icon(Icons.location_on,size: 36,color: parent.selectedGarage!.id == garage.id ? Colors.blue : Colors.red,))
              ),
            ],
          ),
        ),
      );
  }
}
