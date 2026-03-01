import 'package:munturai/model/abonnement.dart';
import 'package:munturai/model/service.dart';
import 'package:munturai/screens/pay.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import '../model/user.dart';
import '../widgets/widget_subscription.dart';

bool light=false;
class Subscription extends StatefulWidget{
  Subscription({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<Subscription> createState() => SubscriptionState();
}
class SubscriptionState extends State<Subscription>  with TickerProviderStateMixin{
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

    final premiumFeatures = [
      translator.feature_premium_see_who_liked,
      translator.feature_premium_undo_swipe,
      translator.feature_premium_unlimited_likes,
      translator.feature_premium_weekly_boost,
      translator.feature_premium_advanced_filters,
      translator.feature_premium_ai_suggestions,
    ];
    final goldFeatures = [
      translator.feature_gold_all_premium,
      translator.feature_gold_message_without_match,
      translator.feature_gold_three_boosts,
      translator.feature_gold_gold_badge,
      translator.feature_gold_priority_visibility,
      translator.feature_gold_exclusive_profiles,
    ];

    final premiumServices = [
      Product(
        longName: 'OFFER PREMIUM 1 MONTH',
        shortName: 'PREMIUM 1 MONTH',
        code: 'PREMIUM-1-MONTH',
        currency: 'XAF',
        price: 2000,
        realPrice: 3500,
        months: 1
      ),
      Product(
          longName: 'OFFER PREMIUM 3 MONTHS',
          shortName: 'PREMIUM 3 MONTHS',
          code: 'PREMIUM-3-MONTHS',
          currency: 'XAF',
          price: 5500,
          realPrice: 10000,
          months: 3
      ),
      Product(
          longName: 'OFFER PREMIUM 6 MONTHS',
          shortName: 'PREMIUM 6 MONTHS',
          code: 'PREMIUM-6-MONTHS',
          currency: 'XAF',
          price: 15000,
          realPrice: 25000,
          months: 6
      ),
    ];
    final goldServices = [
      Product(
          longName: 'OFFER GOLD 1 MONTH',
          shortName: 'GOLD 1 MONTH',
          code: 'GOLD-1-MONTH',
          currency: 'XAF',
          price: 3500,
          realPrice: 5000,
          months: 1
      ),
      Product(
          longName: 'OFFER GOLD 3 MONTHS',
          shortName: 'GOLD 3 MONTHS',
          code: 'GOLD-3-MONTHS',
          currency: 'XAF',
          price: 10000,
          realPrice: 13500,
          months: 3
      ),
      Product(
          longName: 'OFFER GOLD 6 MONTHS',
          shortName: 'GOLD 6 MONTHS',
          code: 'GOLD-6-MONTHS',
          currency: 'XAF',
          price: 28500,
          realPrice: 36000,
          months: 6
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(titleTxt: translator.plan),
        body:
        Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          pageIndex=0;
                          controller.animateToPage(pageIndex, duration: const Duration(seconds: 1), curve: Curves.easeIn);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: BodyWidth()/2,
                        decoration: BoxDecoration(
                          border: Border(bottom: pageIndex==0?BorderSide(color: colorScheme.primary):BorderSide.none)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Premium',style: appStyle.H4(weight: pageIndex==0?'b':'Regular',color: pageIndex==0?colorScheme.onSurface:Colors.blueGrey),)
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          pageIndex=1;
                          controller.animateToPage(pageIndex, duration: const Duration(seconds: 1), curve: Curves.easeIn);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: BodyWidth()/2,
                        decoration: BoxDecoration(
                            border: Border(bottom: pageIndex==1?BorderSide(color: colorScheme.primary):BorderSide.none)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Gold',style: appStyle.H4(weight: pageIndex==1?'b':'Regular',color: pageIndex==1?colorScheme.primary:Colors.blueGrey),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: BodyHeight()-100,
                  child:
                  PageView(
                    controller: controller,
                    onPageChanged: (index){
                      setState(() {
                        pageIndex=index;
                      });
                    },
                    children: [
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                        children:[
                          PlanFeatures(premiumFeatures, appStyle, colorScheme),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for(int i=0;i<premiumServices.length;i++)
                                SubscriptionWidget(
                                  width: 140,
                                  height: 180,
                                  service: premiumServices[i],
                                  index: i,
                                  popular: i==1,
                                  type: 'Premium',
                                  subscriptionState: this,
                                ),
                              ],
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 40))
                        ],
                      ),
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                        children:[
                          PlanFeatures(goldFeatures, appStyle, colorScheme,golden: true),
                          Container(
                            height: 200,
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for(int i=0;i<goldServices.length;i++)
                                  SubscriptionWidget(
                                    width: 140,
                                    height: 180,
                                    service: goldServices[i],
                                    index: i,
                                    popular: i==1,
                                    type: 'Gold',
                                    subscriptionState: this,
                                  ),
                              ],
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 40))
                        ],
                      ),
                    ],
                  ),
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
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Pay(service: pageIndex==0?premiumServices[SubIndex]:goldServices[SubIndex],)));
                        });
                      },
                      child:
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration:
                        pageIndex==1?
                        BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/fond_gold.jpg'),fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(50.0),):
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
