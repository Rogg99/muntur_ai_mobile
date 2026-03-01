import 'package:munturai/screens/pay_extern.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/service.dart';

import '../core/colors/colors.dart';
import '../model/user.dart';
import '../widgets/loading.dart';

bool light=false;
class Pay extends StatefulWidget{
  Product? service;
  Pay({super.key,required this.service});

  @override
  State<Pay> createState() => PayState();
}
class PayState extends State<Pay> {
  User? user;
  bool loading = true;
  bool buying = false;
  String buyType='';
  TextEditingController numberController=TextEditingController();
  String buyMessage='',buyWith = 'MoMo';
  String countryCode = '+237';

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
    final countriesIndicators = ['+237','+234','+242','+235',];

    return Scaffold(
        backgroundColor: colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading:
          Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          title:
          Text(translator.pay,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H3(weight: 'bold'),
          ),
          backgroundColor: colorScheme.background,
        ),
        body:
        Stack(
          children: [
            ListView(
              children: [
                Padding(padding: getPadding(top: 30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child:
                      Text(widget.service!.longName,
                        style: appStyle.txtRoboto(size: 22,weight: 'b').copyWith(decoration: TextDecoration.none),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Padding(padding: getPadding(top: 50)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: getPadding(left: 20)),
                    Text(translator.duration,
                      style: appStyle.H4(weight: 'b').copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Text(' ${translator.days(widget.service!.months * 30)}',
                      style: appStyle.H4(color: Colors.grey).copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: getPadding(left: 20)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: getPadding(left: 20)),
                    Text(translator.price,
                      style: appStyle.H5(weight: 'b').copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    Text('${widget.service!.price} ${widget.service!.currency}',
                      style: appStyle.H5(color: Colors.grey).copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: getPadding(left: 20)),
                  ],
                ),
                Padding(padding: getPadding(top: 50)),
                Row(
                  children: [
                    Padding(padding: getPadding(left: 20)),
                    Text(translator.pay_with,
                      style: appStyle.txtRoboto(size: 20,weight: 'b').copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Padding(padding: getPadding(top: 30)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      width: BodyWidth()*0.20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius:  BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 50,
                      child: DropdownButton(
                        value: countryCode,
                        underline: const SizedBox(),
                        items: [
                          for(var country in countriesIndicators)
                            DropdownMenuItem(
                              value: country,
                              child: Text(country,style: appStyle.H6(),),
                            ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            countryCode = value!;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      width: BodyWidth()*0.65,
                      height: 50,
                      child: TextField(
                        controller: numberController,
                        style: appStyle.H6(),
                        decoration: InputDecoration(
                            hintText: translator.hint_phone,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                        ),
                      ),
                    ),
                  ],
                ),
                buying?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40,child: Loading(),),
                    ],
                  ),
                ):
                buyMessage.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40,child: Text(buyMessage,style: appStyle.H5(),),),
                    ],
                  ),
                ):const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 15),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(translator.active_subscription_warning
                          ,style: appStyle.H7(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _showCongratsDialog(context);
                          setState(() {
                            // showDrawer=true;
                          });
                        },
                        child:
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration:
                          BoxDecoration(color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(50.0),),
                          width: BodyWidth()-70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                translator.pay,
                                style: appStyle.txtRoboto(size: 20,color: UIColors.primaryAccent),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0,vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.onBackground,
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        translator.or_separator,
                        style: appStyle.H6(),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.onBackground,
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            var url = 'https://www.google.com/';
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PayExtern(url: url,)));
                            // showDrawer=true;
                          });
                        },
                        child:
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: BodyWidth()-70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pay with credit card',
                                style: appStyle.H5(),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
    );
  }

  load() async{
    setState(() {
      loading = true;
    });


    setState(() {
      loading = false;
    });
  }


  void _showCongratsDialog(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogcontext) {
        return AlertDialog(
          content:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded,color: Colors.yellow,size: 36),
                  Icon(Icons.star_outline_rounded,color: Colors.yellow,size: 64,),
                  Icon(Icons.star_outline_rounded,color: Colors.yellow,size: 48),
                ],
              ),
              Text("Félicitations, vous avez completé votre achat avec succès !!!",
                style: appStyle.H5(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translator.ok,style: appStyle.H6(color: colorScheme.secondary),),
              onPressed: () async{
                Navigator.of(dialogcontext).pop();
              },
            ),
          ],
        );
      },
    );
  }




}