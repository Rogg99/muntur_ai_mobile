import 'dart:convert';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/helper.dart';
import 'package:munturai/services/api/media.dart';
import '../core/colors/colors.dart';
import '../model/user.dart';
import '../widgets/custom_filter_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/widget_profile_tile.dart';

bool light=false;
class Profile extends StatefulWidget{
  const Profile({super.key,});

  @override
  State<Profile> createState() => ProfileState();
}
class ProfileState extends State<Profile>  with TickerProviderStateMixin{
  User? user;
  bool loading = true, uploadingImage = false, uploadingError = false;
  bool showProfile = false;
  bool setName = false;
  bool setGender = false;
  bool setDescription = false,setLocation=false;
  bool setAge=false,setHeight=false,setSexuality=false,setExpectation=false,
      setAstrology=false,setLanguage=false,setLanguage2=false,setKids=false,
      setPets=false,setTabac=false,setAlcohol=false,setStudy=false,
      setReligion=false,setSituation=false,setPersonality=false,setHobbies=false;

  int height=160;
  String birth="2000-01-01";
  var heightminExtremas=[140,229];
  bool certified = false;
  String school_level='none';
  String city='none';
  String attirance='none';
  String status='none';
  String language='none';
  String language2='none';
  String children='none';
  String smoke='none';
  String alcohol='none';
  String personality='none';
  String pet='none';
  String religion='none';
  String astrology='none';
  String expectation='none';
  String hobbie='none';

  final namecontroller = TextEditingController(); //locationController
  final locationController = TextEditingController(); //locationController
  final descriptioncontroller = TextEditingController();
  final locationcontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final companyNamecontroller = TextEditingController();
  final jobTitlecontroller = TextEditingController();
  final schoolNamecontroller = TextEditingController();

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
    final isDark = themeProvider.themeMode() == ThemeMode.dark;
    // user = User();

    return Stack(
      children: [
        Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading:
              Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios,),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              centerTitle: true,
              title:
              Text(translator.profile,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: appStyle.H3(color: Theme.of(context).colorScheme.onSurface, weight: 'bold'),
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
              // elevation: 2,
            ),
            body:
            loading ?  Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),
            ) :
            Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 80),
                      child:
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(170),
                                image: DecorationImage(
                                  image:
                                  AssetImage(ImageConstant.imgEllipse),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(width: 5,color: Theme.of(context).colorScheme.primary)
                              ),
                            ),]
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Padding(
                      padding: getPadding(top: 30.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(translator.my_account,
                              style: appStyle.txtRoboto( weight: 'b',size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProfileTile(
                        icon: const Icon(Icons.email),
                        text: translator.email_label,
                        desc: user!.email,
                        onPressed: (){
                          setState(() {
                            setName = true;
                          });
                        }
                    ),
                    ProfileTile(
                        icon: const Icon(Icons.phone),
                        text: translator.hint_phone,
                        desc: user!.telephone,
                        onPressed: (){
                          setState(() {
                            setAge = true;
                          });
                        }
                    ),
                    ProfileTile(
                        icon: const Icon(Icons.password),
                        text: translator.password_hint,
                        desc: '************',
                        onPressed: (){
                          setState(() {
                            setDescription = true;
                          });
                        }
                    ),
                    ProfileTile(
                        icon: const Icon(Icons.location_on_sharp),
                        text: translator.location,
                        desc: user!.ville,
                        onPressed: (){
                          setState(() {
                            setLocation = true;
                          });
                        }
                    ),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Padding(
                      padding: getPadding(top: 30.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(translator.personalInfos,
                              style: appStyle.txtRoboto( weight: 'b',size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProfileTile(
                      icon: const Icon(Icons.person),
                      text: translator.name,
                      desc: '${user!.nom} ${user!.prenom}',
                      onPressed: (){
                        setState(() {
                          setName = true;
                        });
                      }
                    ),
                    ProfileTile(
                        icon: const Icon(Icons.calendar_month),
                        text: translator.birthDateLabel,
                        desc: user!.date_naissance,
                        onPressed: (){
                          setState(() {
                            setAge = true;
                          });
                        }
                    ),
                    Padding(padding: getPadding(top: 40)),

                  ],
                ),
              ],
            ),
        ),
        if(setName)
          CustomFilterCard(
            title:translator.name,
            desc: '',
            body:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namecontroller,
                    style: appStyle.H6(),
                    keyboardType: TextInputType.text,
                    cursorColor: UIColors.cursorColor,
                    decoration: InputDecoration(
                      hintText: translator.surnameHint,
                      label: Text(translator.surnameHint),
                      fillColor: UIColors.edittextFillColor,
                      border: OutlineInputBorder(
                        gapPadding: 1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.background),
                        borderRadius: BorderRadius.circular(10),
                      ),

                    ),
                  ),
                  Padding(padding: getPadding(top:15)),
                  TextField(
                    controller: prenomcontroller,
                    style: appStyle.H6(),
                    keyboardType: TextInputType.text,
                    cursorColor: UIColors.cursorColor,
                    decoration: InputDecoration(
                      hintText: translator.nameHint,
                      label: Text(translator.nameHint),
                      fillColor: UIColors.edittextFillColor,
                      border: OutlineInputBorder(
                        gapPadding: 1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.background),
                        borderRadius: BorderRadius.circular(10),
                      ),

                    ),
                  ),
                  Padding(padding: getPadding(top:15)),
                  PrimaryButton(
                      text: translator.save,
                      padding: 50,
                      radius: 50,
                      onPressed: (){
                        user!.nom = namecontroller.text;
                        user!.prenom = prenomcontroller.text;
                        closeAllFilters();
                      }
                  ),
                ],
              ),
            onClose: (){
              closeAllFilters();
              setState(() {});
            },
          ),
        if(setAge)
          CustomFilterCard(
            title:translator.birthDateLabel,
            desc:'',
            body:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: getPadding(top: 20),
                  height: 300,
                  child: CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      firstDate: DateTime(1950),
                      lastDate: DateTime(DateTime.now().year-18),
                    ),
                    value: [DateTime.parse(birth)],
                    onValueChanged: (dates) {
                      setState(() {
                        birth = dates[0]!.format("YYYY-MM-DD");
                      });
                    },
                  ),
                ),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: (){
                    user!.date_naissance = birth;
                    closeAllFilters();
                  }
                ),
              ],
            ),
            onClose: (){
              closeAllFilters();
              setState(() {});
            },
          ),
        if(setLocation)
          CustomFilterCard(
            title:translator.location,
            desc:'',
            body:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: BodyWidth()-30,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface)
                  ),
                  child: GooglePlacesAutoCompleteTextFormField(
                      style: appStyle.H6(),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search),
                        hintText: translator.enter_city_hint,
                      ),
                      textEditingController: locationController,
                      googleAPIKey: ApiHelper().GOOGLE_MAPS_APIKEY,
                      debounceTime: 400, // defaults to 600 ms
                      //countries: ["de"], // optional, by default the list is empty (no restrictions)
                      isLatLngRequired: true, // if you require the coordinates from the place details
                      getPlaceDetailWithLatLng: (prediction) {
                        // this method will return latlng with place detail
                        print("Coordinates: (${prediction.lat},${prediction.lng})");
                        // filter.location_lat = '${prediction.lat}';
                        // filter.location_lon = '${prediction.lng}';
                        print('${prediction.lat} **** ${prediction.lng}');
                      }, // this callback is called when isLatLngRequired is true
                      itmClick: (prediction) {
                        locationController.text = prediction.description??'';
                        print(prediction.placeId);
                        locationController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                        setState(() {
                          city = locationController.text;
                          setLocation=false;
                        });
                        FocusManager.instance.primaryFocus?.unfocus();
                        locationController.text='';
                      }
                  ),
                ),
                Padding(padding: getPadding(top: 30)),
                PrimaryButton(
                    text: translator.save,
                    padding: 50,
                    radius: 50,
                    onPressed: (){
                      user!.ville = city;
                      closeAllFilters();
                    }
                ),
              ],
            ),
            onClose: (){
              closeAllFilters();
              setState(() {});
            },
          ),
      ],
    );
  }

  load() async{
    loading = true;
    // user = User();
    user = await AuthApi().getUser().then((value) => value);

    namecontroller.text = user!.nom;
    prenomcontroller.text = user!.prenom;

    await saveKey("lastPage",'settings');

    setState(() {
      loading = false;
    });
  }

  saveUser()async{
    await saveKey('user',user!.toJson());
  }

  closeAllFilters(){
    saveUser();
    setState(() {
      setAge = false;
      setName = false;
    });
  }

  String getDate(num time,{bool hh_mm=false,bool yy_mm=false}){
    if(hh_mm)
      return DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('kk:mm');
    if(yy_mm){
      var days=['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
      var months=['Janvier','Fevrier','Mars','Avril','Mai','Juin','Juillet','Aout'
        ,'Septembre','Octobre','Novembre','Decembre'];
      String day = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).day.toString();
      String dayCalendar = days[DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).weekday-1];
      String month = months[DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).month-1];
      String year = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).year.toString();
      String date= dayCalendar+', '+day+' '+month+' '+year;
      return date;
    }
    String duree='';
    double actual=DateTime.now().millisecondsSinceEpoch/1000;
    double periode = actual-time;
    if(periode/3600<1)
      duree = (periode/60).floor().toString() + 'min';
    else if(periode/3600<24)
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('kk:mm');
    else
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('MM/dd');
    return duree;
  }

  takeImage() async {
    uploadingImage = true;
    uploadingError = false;
    setState(() {});
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickMedia();
    if (file != null) {
      await MediaApi().createMedia(file.path).then((response) async {
        if(response.statusCode==200) {
          var mediaId = jsonDecode(response.stream.toString())['id'];
          var mediaUrl = jsonDecode(response.stream.toString())['url'];
          await MediaApi().updateProfilePhoto(file.path,mediaId).then((response){
            if(response.statusCode==200) {
              uploadingImage = false;
              user!.photo = mediaUrl;
            }
            else{
              uploadingImage = true;
              uploadingError = false;
              setState(() {});
            }
          });
          saveUser();
          uploadingImage = false;
        }
        else{
          uploadingImage = true;
          uploadingError = false;
          setState(() {});
        }

      });
    }
    setState(() {});
  }

}