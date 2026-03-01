import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/garage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/colors/colors.dart';

bool light=false;

Future<void> _launchUrl(Uri _url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
class GarageDetails extends StatefulWidget{
  Garage garage;
  GarageDetails({Key? key,required this.garage})
      : super(
    key: key,
  );
  @override
  State<GarageDetails> createState() => GarageDetails_(garage: garage);
}
class GarageDetails_ extends State<GarageDetails>{
  Garage garage;
  String setTitle='';
  bool showfilter=false;
  bool showimagesource=false;
  bool load_photo=false;
  double height=200;
  String photo='';
  int pageIndex=0;

  GarageDetails_({Key? key,required this.garage});

  @override
  void initState() {
    //getDatas();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).colorScheme.onBackground,),
                onPressed: () {
                    Navigator.of(context).pop();
                  },
              );
        }) ,
        title: Text("Infos Garage",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H3(weight: 'bold'),
          ),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        elevation: 0,
      ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          children: [
            Container(
              height: getVerticalSize(200,),
              width: BodyWidth(),
              decoration: BoxDecoration(
                  color: UIColors.boxFillColor,
                  image: (garage.photo!='none' && garage.photo!='None' && garage.photo.isNotEmpty)?
                  DecorationImage(
                    image: FileImage(File('/data/user/0/com.steps.davinci.muntuai/app_flutter/${garage.photo.split('/').last}')),
                    fit: BoxFit.cover,
                  ):const DecorationImage(
                      image: AssetImage('assets/images/avatar.jpg'),
                      fit: BoxFit.cover
                  )
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(garage.nom,style: appStyle.H3(weight: 'bold'),),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child:
              Flexible(child: Text(garage.description,style: appStyle.H5(weight: 'bold'),)),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Localisation : ",style: appStyle.H6(),),
                  Text("${garage.ville} , ${garage.pays}",style: appStyle.H5(weight: 'bold'),),
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                children: [
                  const Icon(Icons.email),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Email : ",style: appStyle.H6(),),
                  Text(garage.email,style: appStyle.H5(weight: 'bold'),),
                  const Spacer(),
                  GestureDetector(child: Text("Send mail",style: appStyle.H6(color: Theme.of(context).colorScheme.background),),
                    onTap: (){
                      var url = Uri.parse('mailTo:${garage.email}');
                      launchUrl(url);

                    },
                  )
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                children: [
                  const Icon(Icons.phone),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Telephone 1 : ",style: appStyle.H6(),),
                  Text(garage.telephone1.replaceAll('nan', ''),style: appStyle.H5(weight: 'bold'),),
                  (garage.telephone1!='none' && garage.telephone1!='')?
                  GestureDetector(child: Text("Call",style: appStyle.H5(color: Theme.of(context).colorScheme.background),),
                  onTap: (){
                    if(garage.telephone1!='none' && garage.telephone1!='') {
                      var url = Uri.parse('phone:+237${garage.telephone1}');
                      launchUrl(url);
                    }
                  },
                  ):const SizedBox(),
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                children: [
                  const Icon(Icons.phone),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Telephone 2 : ",style: appStyle.H6(),),
                  Text(garage.telephone2,style: appStyle.H5(weight: 'bold'),),
                  (garage.telephone2!='none' && garage.telephone2!='')?
                  GestureDetector(child: Text("Call",style: appStyle.H5(color: Theme.of(context).colorScheme.background),),
                    onTap: (){
                      if(garage.telephone2!='none' && garage.telephone2!='') {
                        var url = Uri.parse('phone:+237${garage.telephone2}');
                        launchUrl(url);
                      }
                    },
                  ):const SizedBox(),
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Horaire : ",style: appStyle.H6(),),
                  Column(
                    children: [
                      Text("${translator.monday} - ${translator.saturday} ",style: appStyle.H5(),),
                      Text("${garage.heureOuverture.substring(0,5)} AM - ${garage.heureFermeture.substring(0,5)} PM",style: appStyle.H5(weight: 'bold'),),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                children: [
                  const Icon(Icons.stars),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Rating : ",style: appStyle.H6(),),
                  for (var i in List.generate(garage.rating.floor(), (index) => index))
                    Icon(Icons.star,color: Theme.of(context).colorScheme.primary,size: 16.0,),
                  Text("${garage.rating}/5",style: appStyle.H5(weight: 'bold'),),
                ],
              ),
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.photo_library),
                  const Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Photos ",style: appStyle.H6(weight: 'Bold'),),
                ],
              ),
            ),
            Wrap(
              children: [
                for (var img in jsonDecode(garage.medias))
                  Padding(
                    padding: getPadding(top: 10,left: 16,right: 16),
                    child: Container(
                      height: getVerticalSize(200,),
                      width: BodyWidth(),
                      decoration: BoxDecoration(
                          color: UIColors.boxFillColor,
                          image: DecorationImage(
                            image: NetworkImage(img),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                  ),
              ]
            
            ),
            const Divider(indent: 8.0,endIndent: 8.0,),

          ],
        ),
      ),
    );
  }

}


