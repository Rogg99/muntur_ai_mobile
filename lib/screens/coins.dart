import 'package:munturai/model/abonnement.dart';
import 'package:munturai/model/service.dart';
import 'package:munturai/screens/pay.dart';
import 'package:munturai/widgets/widget_coinsPack.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import '../model/user.dart';

bool light=false;
class Coins extends StatefulWidget{
  Coins({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<Coins> createState() => CoinsState();
}
class CoinsState extends State<Coins>  with TickerProviderStateMixin{
  User? user;
  bool loading = true;
  bool hidden = false;
  PageController controller = PageController();
  Abonnement? abonnement;

  int pageIndex = 0;
  int SubIndex = 0;
  bool showDrawer=false,buying=false;
  TextEditingController numberController=TextEditingController();
  String buyMessage='',buyWith = 'MoMo';

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
    Locale currentLocale = Localizations.localeOf(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;

    final coinProducts = [
      Product(
        longName: 'COINS PACK 500',
        shortName: 'COINS PACK 500',
        code: 'COINS-PACK-500',
        currency: 'XAF',
        price: 400,
        realPrice: 500
      ),
      Product(
          longName: 'COINS PACK 1000',
          shortName: 'COINS PACK 1000',
          code: 'COINS-PACK-1000',
          currency: 'XAF',
          price: 750,
          realPrice: 900
      ),
      Product(
          longName: 'COINS PACK 2000',
          shortName: 'COINS PACK 2000',
          code: 'COINS-PACK-2000',
          currency: 'XAF',
          price: 1300,
          realPrice: 1500
      ),
      Product(
          longName: 'COINS PACK 5000',
          shortName: 'COINS PACK 5000',
          code: 'COINS-PACK-5000',
          currency: 'XAF',
          price: 3500,
          realPrice: 4000
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading:
          Center(
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          title:
          Text(translator.coins,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H3(weight: 'bold'),
          ),
          backgroundColor: colorScheme.background,
        ),
        body:
        Stack(
          children: [
            GridView.count(
              childAspectRatio: 210/300,
              primary: false,
              padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 50),
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              crossAxisCount: 2,
              children: [
                for(int i=0;i<coinProducts.length;i++)
                  CoinsPackWidget(
                    width: 140,
                    height: 180,
                    service: coinProducts[i],
                    popular: i==1,
                    selected: SubIndex==i,
                    onPressed: (){
                      setState(() {
                        SubIndex = i;
                      });
                    },
                  ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child:
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Pay(service:coinProducts[SubIndex])));
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
                              translator.continue__,
                              style: appStyle.H4(),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  load() async{
    loading = true;
    user=User();
    abonnement = Abonnement();
    //user = await API.getUI_user().then((value) => value[0]);

  }
}

Widget PlanFeatures(List<String> features, AppStyle appStyle, ColorScheme colorScheme,{bool golden=false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: features
        .map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Expanded(child: Text(feature, style: appStyle.H4())),
          const Spacer(),
          if (!golden) Icon(Icons.check_circle_outline, color: colorScheme.primary)
          else
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage('assets/images/fond_gold.jpg'),fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(50)
            ),
            child: Icon(Icons.check_circle, color: colorScheme.background)),
        ],
      ),
    ))
        .toList(),
  );
}
