import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/utils/image_constant.dart';
import 'package:munturai/core/utils/size_utils.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/Info.dart';
import 'package:munturai/model/message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:munturai/model/garage.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/screens/login.dart';
import 'package:munturai/screens/notifications.dart';
import 'package:munturai/screens/profile.dart';
import 'package:munturai/screens/settings.dart';
import 'package:munturai/widgets/custom_image_view.dart';
import 'package:munturai/model/user.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/core/theming/dimens.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:munturai/widgets/widget_forum.dart';
import 'package:munturai/widgets/widget_garage.dart';
import 'package:munturai/widgets/widget_marker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:latlong2/latlong.dart';

import '../model/Token.dart';
import '../services/api/auth.dart';
import '../services/api/chat.dart';
import '../services/api/databaseHelper.dart';
import '../services/api/localisation.dart';
import '../utils/divisionsFilter.dart';
import '../widgets/widget_discussion.dart';
import '../widgets/widget_info.dart';
import 'garage.dart';
import 'infos.dart';
import 'maps.dart';

String SelectedMenu = 'Home';
String appVersion = '1.0.18';
double paddingtitle = 150;

var user = User();
final ValueNotifier<List<Info>> infos = ValueNotifier([]);

final ValueNotifier<String> langage = ValueNotifier('français');

bool light = false;
bool lang = false;
TextEditingController buttonmaleController = TextEditingController();
String radioGroup = "";

enum languages { Francais, English }

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({Key? key})
      : super(
          key: key,
        );
  @override
  ConsumerState<HomeScreen> createState() => StateHomeScreen();
}

class StateHomeScreen extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  List<String> results = [];
  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }

  bool showfilter = false,
      show_inscription = false,
      show_preinscription = false,
      searchbarvisibilty = false;
  int selected_eventfilter = 0;
  final searchcontroller = TextEditingController();
  final dobstartcontroller = TextEditingController();
  final dobendcontroller = TextEditingController();
  final dorstartcontroller = TextEditingController();
  final dorendcontroller = TextEditingController();
  String deviceType = '', keywordEvent = '';
  String userBodyStats = '';
  String globalBodyStats = '';
  bool isLoading = true,
      isLoadingForums = true,
      searchdone = true,
      loadGarages = true,
      showGarages = true;
  List<String> categories = [];
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  List<String> allPays = countries_fr;
  List<Garage> garages = [];
  String selectedPays = 'Cameroun';

  int statChoice = 0;
  PageController statsPageController = PageController();

  void _onItemTapped(int index) {
    if (index == 1 && !isLoading) {
      //statsPageController.animateToPage(0, duration: Duration(milliseconds: 1000), curve: Curves.linear);
      fetchgarages("", context);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  bool userinsState = true;
  bool userpreState = true;

  Point position1 = Point(latitude: 3.861536, longitude: 11.486072);
  MapController _mapctl = MapController();
  final FocusNode garageSearchfocusNode = FocusNode();

  Garage? selectedGarage;
  List<Marker> markers = [];
  List<Marker> markersToShow = [];
  List<Map<String, Object>> markersGarages = [];

  final garageSearchController = TextEditingController();

  @override
  void initState() {
    deviceType = getDeviceType();
    //selectedPays=allPays[0];
    getKey('language').then((value) => {langage.value = value});
    syncViews();
    SelectedMenu = 'Home';
    var height = BodyHeight();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
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
    AppLocalizations translator = AppLocalizations.of(context)!;
    var isDark = themeProvider.themeMode() == ThemeMode.dark;
    garageSearchfocusNode.addListener(() {
      // if keyboard is up, set showgarages to false
      if (garageSearchfocusNode.hasFocus) {
        showGarages = false;
        loadGarages = false;
      }
      setState(() {});
    });

    // ignore: no_leading_underscores_for_local_identifiers
    List<String> _titlesView = [
      translator.homeTitle,
      translator.searchTitle,
      translator.newsTitle,
      translator.forumsTitle,
      translator.settings_title
    ];
    List<Widget> _widgetOptions = <Widget>[
      Scaffold(
        body: SizedBox.expand(
          child: ref.watch(discussionsProvider).when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text('Error: $err',
                      style: appStyle.H4(color: Colors.red)),
                ),
                data: (discussionsList) {
                  if (discussionsList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You haven\'t started no chat yet, start a new one to enjoy MUNTUR AI !!!',
                          style: appStyle.H4(
                              color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: getPadding(left: 16, right: 16),
                    child: ListView.separated(
                      separatorBuilder: (context, i) {
                        return SizedBox(
                          height: getHorizontalSize(15),
                          width: double.infinity,
                        );
                      },
                      itemBuilder: (context, index) {
                        return WidgetDiscussion(
                          disc: discussionsList[index],
                        );
                      },
                      itemCount: discussionsList.length,
                    ),
                  );
                },
              ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatView(disc: Discussion(id: 'auto'))));
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          label: Text(
            translator.newDiscussion,
            style: const TextStyle(color: Colors.white),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      SizedBox.expand(
        child: Stack(
          children: [
            SizedBox(
                width: BodyWidth(),
                height: BodyHeight() - 110.0,
                // decoration: BoxDecoration(
                //   image: DecorationImage(image: AssetImage(ImageConstant.map),fit: BoxFit.cover),
                // ),
                child: FlutterMap(
                  mapController: _mapctl,
                  options: MapOptions(
                    initialCenter: position1.getLatLng(),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=' +
                              LocalisationApi().GOOGLE_MAPS_APIKEY,
                      userAgentPackageName: 'com.steps.davinci.muntuai',
                    ),
                    MarkerLayer(
                      markers: markersToShow,
                    ),
                  ],
                )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    TextField(
                      controller: garageSearchController,
                      focusNode: garageSearchfocusNode,
                      style: appStyle.H5(),
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: InputDecoration(
                        hintText:
                            'What are you looking for? (garages, service station, technical visit center, etc...)',
                        fillColor: Theme.of(context).colorScheme.background,
                        filled: true,
                        border: OutlineInputBorder(
                          gapPadding: 1,
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.background),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.background),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSubmitted: (value) {
                        fetchgarages(
                            garageSearchController.value.text, context);
                      },
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GestureDetector(
                              onTap: () {
                                fetchgarages(
                                    garageSearchController.value.text, context);
                              },
                              child: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.background,
                                size: 32,
                              )),
                        )),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                width: double.maxFinite,
                height: (showGarages || loadGarages) ? height * 0.7 : 60,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: const [BoxShadow()],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                child: Stack(
                  children: [
                    Container(
                      margin: getPadding(all: 10),
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  showGarages = !showGarages;
                                });
                              },
                              child: Text(
                                'Results',
                                style: appStyle.H4(weight: 'bold'),
                              )),
                        ],
                      ),
                    ),
                    loadGarages
                        ? Center(
                            child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ))
                        : Padding(
                            padding: getPadding(top: 50, left: 10, right: 10),
                            child: ListView(
                              children: [
                                Padding(padding: getPadding(top: 30)),
                                for (var i = 0; i < garages.length; i++)
                                  widgetGarage(
                                      garage: garages[i], parent: this),
                              ],
                            ),
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Infos(),
      SizedBox.expand(
        child: ref.watch(forumsProvider).when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              error: (err, stack) => Center(
                child:
                    Text('Error: $err', style: appStyle.H4(color: Colors.red)),
              ),
              data: (forumsList) {
                if (forumsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No forums available yet !',
                        style: appStyle.H4(
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Container(
                  padding: getPadding(left: 16, right: 16),
                  child: ListView.separated(
                    separatorBuilder: (context, i) {
                      return SizedBox(
                        height: getHorizontalSize(15),
                        width: double.infinity,
                      );
                    },
                    itemBuilder: (context, index) {
                      return WidgetForum(
                        disc: forumsList[index],
                      );
                    },
                    itemCount: forumsList.length,
                  ),
                );
              },
            ),
      ),
      Settings(),
    ];

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.loop_rounded),
              onPressed: () {
                syncViews();
              },
            ),
            title: Center(
              child: Text(
                _titlesView.elementAt(_selectedIndex),
                style: appStyle.H3(),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: Dimens.padding.w),
                child: GestureDetector(
                  onTap: () async {
                    // var selfUser=await API.getUser().then((value) => value[0]);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Notifications()));
                  },
                  child: Container(
                    height: getVerticalSize(
                      60,
                    ),
                    width: getVerticalSize(
                      60,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                            child: Icon(
                          Icons.notifications,
                          size: 28,
                        )),
                        Positioned(
                          top: 5,
                          right: 2,
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 2, bottom: 2, left: 6, right: 6),
                                child: Text('6', style: appStyle.H8()),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              _widgetOptions.elementAt(_selectedIndex),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 16.0,
            backgroundColor: Theme.of(context).colorScheme.background,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  activeIcon: Icon(
                    Icons.home,
                    size: 28,
                  )),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                activeIcon: Icon(Icons.search, size: 28),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'News',
                activeIcon: Icon(Icons.newspaper, size: 28),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Forums',
                activeIcon: Icon(Icons.groups, size: 28),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
                activeIcon: Icon(Icons.settings, size: 28),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: _onItemTapped,
            selectedLabelStyle: appStyle.H6(),
          ),
        ));
  }

  bool firstclick = false;

  Future<bool> _onBackPressed() async {
    AppLocalizations translator = AppLocalizations.of(context)!;
    setState(() {
      _selectedIndex = 0;
    });
    if (firstclick == false) {
      firstclick = true;
      toast('clic again to leave',
          color: Theme.of(context).colorScheme.background);
      return false;
    } else {
      return true;
    }
  }

  void syncViews() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    user = await AuthApi().getUser().then((value) => value as User);

    isLoading = false;
    setState(() {});

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      ref.read(discussionsProvider.notifier).refresh();
      ref.read(forumsProvider.notifier).refresh();
    });
  }

  Future<List<Garage>> fetchgarages(String key, BuildContext context) async {
    final appStyle = AppStyle.of(context);
    List<Garage> garages_ = [];
    loadGarages = true;
    var datas = [];
    var results;
    await LocalisationApi().getGaragesAround(key).then((response) => {
          if (response.statusCode == 200)
            {
              results = json.decode(response.body),
              datas = results['data'],
              log(datas.toString()),
              for (var i = 0; i < datas.length; i++)
                {
                  garages_.add(Garage(
                    id: datas[i]["id"],
                    nom: datas[i]['nom'],
                    email: datas[i]['email'],
                    ville: datas[i]['ville'],
                    pays: datas[i]['pays'],
                    telephone1: datas[i]['telephone1'],
                    telephone2: datas[i]['telephone2'],
                    description: datas[i]['description'],
                    heureFermeture: datas[i]['heure_fermeture'],
                    heureOuverture: datas[i]['heure_ouverture'],
                    rating: (datas[i]['rating'] as num).toDouble(),
                    medias: (datas[i]['medias']).toString(),
                    distance: datas[i]['distance'],
                    photo: datas[i]['photo'] != 'none'
                        ? datas[i]['photo']
                        : 'none',
                    longitude: datas[i]['longitude'],
                    latitude: datas[i]['latitude'],
                  )),
                },
              loadGarages = false,
              showGarages = true,
            }
          else
            {
              toast(
                  "Oups! An error occured during the search , Please try again !",
                  color: Colors.redAccent),
              print(response.body)
            }
        });

    var userPos = await LocalisationApi().getCurrentPosition();
    markers = [];
    markersToShow = [];
    markersGarages = [];
    setState(() {
      position1 = Point.fromPosition(userPos);
      garages = garages_;
      markers.add(Marker(
        point: Point.fromPosition(userPos).getLatLng(),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: const Center(
                        child: Icon(
                  Icons.man,
                  color: Colors.blue,
                  size: 36,
                ))),
              ),
              Text(
                'You',
                style: appStyle.H4(weight: 'b', color: Colors.blue),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ));
      garages.forEach((element) {
        markers.add(Marker(
          point: LatLng(element.latitude, element.longitude),
          alignment: Alignment.topRight,
          child: WidgetMarker(
            garage: element,
            parent: this,
          ),
        ));
      });
      markersToShow = markers;
      _mapctl.move(LatLng(position1.latitude, position1.longitude), 12);
    });
    return garages_;
  }

  centerMapOnPosition(Garage garage, BuildContext context) {
    final appStyle = AppStyle.of(context);
    setState(() {
      selectedGarage = garage;
      showGarages = false;
      loadGarages = false;
    });
    _mapctl.move(LatLng(garage.latitude, garage.longitude), 15);
  }
}

class Point {
  double latitude;
  double longitude;
  Point({required this.latitude, required this.longitude});
  getLatLng() {
    return LatLng(this.latitude, this.longitude);
  }

  static fromPosition(Position position) {
    return Point(latitude: position.latitude, longitude: position.longitude);
  }

  static current() async {
    var _cur = await LocalisationApi().getCurrentPosition();
    return Point(latitude: _cur.latitude, longitude: _cur.longitude)
        .getLatLng();
  }
}
