import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:munturai/services/api/databaseHelper.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:munturai/widgets/widget_message2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';

import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/user.dart';
import '../services/api/chat.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_message.dart';

bool light=false;
class ForumChatView extends StatefulWidget{
  Discussion? disc;
  ForumChatView({super.key,
    this.disc,
  });
  @override
  State<ForumChatView> createState() => ForumChatState(disc: disc);
}
class ForumChatState extends State<ForumChatView>  with TickerProviderStateMixin{
  bool show_login=false;
  bool showimagesource=false;
  bool loadAnswer=false;
  bool showmedia=false;
  bool showSelectedMedia = false;
  bool viewSelectedMedia = false;
  bool showAnswer=false;
  bool load_photo=false;
  bool show_militant=false;
  bool show_locality=false;
  bool loading=true;
  List<MessageWidget> allMessageWidgets = [];
  List<GlobalKey<MessageWidget_>> allMessageWidgetsStates = [];
  UIMessage answerTo=UIMessage();
  String media="";
  List<UIMessage> messages=[];
  PageController pageController = PageController();
  AutoScrollController scrollcontroller = AutoScrollController();
  final messagecontroller = TextEditingController();
  Discussion? disc;
  User? user;
  List<String> medias = [];
  int lastTime = 0;
  late Animation<double> animation;
  late AnimationController controller;

  late VideoPlayerController _controller;
  
  ForumChatState({Key? key,
    this.disc,
  });
  Timer loopCheck = Timer(Duration.zero, () { }) ;

  late final _observer = ScrollObserver.boxMulti(
    axis: Axis.vertical,
    itemCount: messages.length,
  );

  @override
  void initState() {
    messagecontroller.clear();
    load();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    animation = Tween<double>(begin: 0, end: 0.75).animate(controller)
      ..addListener(() {
        if (!mounted) return;
        setState(() {
        });
      });
    controller.forward();
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    loopCheck.cancel(); // si utile
    messagecontroller.dispose();
    // _controller.dispose();
    pageController.dispose();
    controller.dispose();
    if (_controller.value.isInitialized) {
      _controller.dispose(); // video controller
    }
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    if (showSelectedMedia == true) {
      showmedia=false;
      showSelectedMedia = false;
      setState(() {});
      _controller.dispose();
      return false;
    }
    else if (viewSelectedMedia == true) {
      showmedia=false;
      showSelectedMedia = false;
      viewSelectedMedia = false;
      setState(() {});
      _controller.dispose();
      return false;
    }
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final themeProvider = ThemeProvider.of(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(titleTxt: disc!.title,),
        body:
        Stack(
          children: [
            (showSelectedMedia  && viewSelectedMedia==false)?
            Container(
              width: BodyWidth(),
              height: BodyHeight(),
              decoration: BoxDecoration(
                  color: (isImage(media.split('.').last) || isVideo(media.split('.').last))? Colors.black : Colors.white70
                ),
              child:
              isImage(media.split('.').last)?
              Image.file(
                  File(media),
                fit: BoxFit.contain,
                width: BodyWidth(),
                height: BodyHeight(),
              ):
              isVideo(media.split('.').last)?
              Stack(
                children: [
                  GestureDetector(
                    onTap:  (){
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(padding: getPadding(top: 200)),
                        Center(
                          child: Container(
                            width: BodyWidth(),
                            height: 300,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        Padding(padding: getPadding(top: 100)),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child:
                          Container(
                            width: BodyWidth(),
                            padding: getPadding(left: 10,right: 10),
                            child: Row(
                              children: [
                                Text(getDuration(_controller.value.position.inMilliseconds),style: appStyle.txtRoboto(size: 18,color: Colors.white),),
                                Flexible(
                                  child: VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    padding: EdgeInsets.all(8),
                                  ),
                                ),
                                Text(getDuration(_controller.value.duration.inMilliseconds),style: appStyle.txtRoboto(size: 18,color: Colors.white),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: (){
                          setState(() {
                          _controller.value.isPlaying
                          ? _controller.pause()
                              : _controller.play();
                          });
                      },
                      child: _controller.value.isPlaying ? SizedBox():Icon(Icons.play_circle,size: 60,color: Colors.white,),
                    ),
                  ),
                ],
              ):
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: getHorizontalSize(150),
                    height: getVerticalSize(150),
                    decoration: BoxDecoration(
                      color: UIColors.warningColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child:
                    Center(
                        child: Text(media.split('.').last,
                          style: appStyle.H3(color: Theme.of(context).colorScheme.background),)
                    ),
                  ),
                  Padding(padding: getPadding(top: 20)),
                  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(media.split('/').last,
                          style: appStyle.H4(color: Theme.of(context).colorScheme.background),),
                      )
                  ),
                ],
              ),
            ):SizedBox(),
            (showSelectedMedia==false && viewSelectedMedia)?
            Container(
              width: BodyWidth(),
              height: BodyHeight(),
              decoration: (isImage(media.split('.').last) || isVideo(media.split('.').last))?
              BoxDecoration(
                  color: Colors.black
              ): BoxDecoration(
                  color: Colors.white70
              ),
              child:
                  PageView.builder(
                    controller: pageController,
                    reverse: false,
                    itemCount: medias.length,
                      itemBuilder: (context,index){
                      if(isImage(medias[index].split('.').last))
                        return
                        Image.file(
                          File(medias[index]),
                          fit: BoxFit.contain,
                          width: BodyWidth(),
                          height: BodyHeight(),
                        );
                      else {
                        VideoPlayerController videoController = new VideoPlayerController.file(File(medias[index]))
                          ..initialize().then((_) {
                            setState(() {});
                          });
                       return Stack(
                          children: [
                            GestureDetector(
                              onTap:  (){
                                setState(() {
                                  videoController.value.isPlaying
                                      ? videoController.pause()
                                      : videoController.play();
                                });
                              },
                              child: Center(
                                child: Container(
                                  width: BodyWidth(),
                                  height: 300,
                                  child: VideoPlayer(videoController),
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    videoController.value.isPlaying
                                        ? videoController.pause()
                                        : videoController.play();
                                  });
                                },
                                child: videoController.value.isPlaying ? SizedBox():Icon(Icons.play_circle,size: 60,color: Colors.white,),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child:
                              VideoProgressIndicator(
                                videoController,
                                allowScrubbing: true,
                                padding: EdgeInsets.all(8),
                              ),
                            )
                          ],
                        );
                      }
                  }),
            ):SizedBox(),
            (showSelectedMedia==false && viewSelectedMedia==false)?
            Container(
              height: BodyHeight()-110,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child:
              Column(
                children: [
                  if(messages.length==0)
                  MessageWidget2(
                    message: UIMessage(),
                    head: true,
                  ),
                  Container(
                    height: BodyHeight()-202,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      separatorBuilder: (context,i){
                        return Container(
                          height: getHorizontalSize(15),
                          width: double.infinity,
                        );
                      },
                      itemBuilder: (context,index){
                        return
                          MessageWidget2(
                            message: messages[index],
                            sender: messages[index].emetteur == user!.id,
                            head: false,
                          );
                      }, itemCount: messages.length,
                    ),
                  ),
                ],
              )
            ):SizedBox(),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              AnimatedContainer(
                width:double.maxFinite,
                height: showimagesource ? 150 : 0 ,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    boxShadow: [BoxShadow()],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.linear,
                child:
                Stack(
                  children: [
                    Padding(
                      padding: getPadding(top: 10,left: 10,right: 10),
                      child:
                      ListView(
                        children: [
                          Padding(padding: getPadding(top: 10)),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showimagesource=false;
                              });
                              takeImage(ImageSource.gallery);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                Padding(padding: getPadding(left: 8)),
                                Text('Gallerie',
                                  style: appStyle.H4(),),
                                Spacer(),
                              ],
                            ),
                          ),
                          Padding(padding: getPadding(top: 30)),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showimagesource=false;
                              });
                              chooseFile();
                            },
                            child:
                            Row(
                              children: [
                                Icon(Icons.file_present_sharp),
                                Padding(padding: getPadding(left: 8)),
                                Text('Document',
                                  style: appStyle.H4(),),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child:
              Container(
                color: Theme.of(context).colorScheme.background,
                height: (showAnswer?100:50)  + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                child:
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      showAnswer?
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: (){
                              //setState(() {});
                              scrollcontroller.scrollToIndex(getIndexOfmessage(answerTo.id), preferPosition: AutoScrollPosition.begin,duration: Duration(seconds: 1));
                              //scrollcontroller.highlight(getIndexOfmessage(answerTo.id));
                              // allMessageWidgetsStates[getIndexOfmessage(answerTo.id)].currentState!.highlight();
                            },
                            child:
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child:
                              Container(
                                height: 37,
                                padding: getPadding(top: 5,left: 10,right: 10,bottom: 5),
                                decoration: BoxDecoration(
                                  color: UIColors.blueGray100,
                                  border: Border(top: BorderSide(color: Theme.of(context).colorScheme.background,width: 4,)),
                                ),
                                child:
                                Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(answerTo.emetteur == user!.id? 'Vous': answerTo.emetteurName,
                                          overflow: TextOverflow.ellipsis,
                                          style: appStyle.H5(color: UIColors.warningColor,weight: 'bold'),),
                                        Padding(padding: getPadding(left: 10)),
                                        Text(answerTo.contenu,
                                          overflow: TextOverflow.ellipsis,
                                          style: appStyle.H6(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child:
                            Padding(
                              padding: const EdgeInsets.only(top: 12,right: 16),
                              child: Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        answerTo = UIMessage();
                                        showAnswer=false;
                                      });
                                    },
                                    child:
                                    Icon(Icons.close,size: 24,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ):SizedBox(),
                      Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // showmedia?
                            // SizedBox():
                            // Transform.rotate(
                            //   angle: 70,
                            //   child:
                            //   IconButton(
                            //     icon: Icon(Icons.attach_file_outlined ,color: Theme.of(context).primaryColor,size: 30),
                            //     onPressed: () {
                            //       showimagesource=!showimagesource;
                            //       setState(() {});
                            //     },
                            //   ),
                            // ),
                            // showmedia?
                            // SizedBox():
                            // IconButton(
                            //   icon: Icon(Icons.camera_alt,color: Theme.of(context).primaryColor,size: 30),
                            //   onPressed: () {
                            //     takeImage(ImageSource.camera);
                            //     showmedia=true;
                            //     setState(() {});
                            //   },
                            // ),
                            Container(
                              height: 40 + min(4,(messagecontroller.text.length ~/ 17).toInt())*8,
                              width: BodyWidth()-30.w,
                              margin: getMargin(left: 10,top: showmedia?7: min(4,(messagecontroller.text.length ~/ 19)) >0 ?7:0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child:
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 40 + min(4,(messagecontroller.text.length ~/ 17).toInt())*8,
                                    width: BodyWidth()-80.w,
                                    // margin: const EdgeInsets.symmetric(horizontal: 10),
                                    // decoration: BoxDecoration(
                                    //     color: UIColors.blueGray100,
                                    //     borderRadius: BorderRadius.circular(20)
                                    // ),
                                    child:
                                    TextField(
                                      onChanged:(e){
                                        setState(() {});
                                      },
                                      controller: messagecontroller,
                                      style: appStyle.H5(),
                                      cursorColor: Theme.of(context).colorScheme.primary,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Message ...',
                                        fillColor: Theme.of(context).colorScheme.background.withOpacity(0.2),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: getPadding(bottom: 20),
                                    child: IconButton(
                                      icon: Icon(CupertinoIcons.arrow_up_circle_fill,color: Theme.of(context).colorScheme.primary,size: 28,),
                                      onPressed: () {
                                        setState(() {
                                          showAnswer = false;
                                          loadAnswer=true;
                                        });
                                        sendQuestion();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              Padding(
                padding: getPadding(bottom: 50.0),
                child: AnimatedContainer(
                  height: loadAnswer ? 50 : 0 ,
                  // height: 50,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: getSize(
                          15,
                        ),
                        width: getSize(
                          15,
                        ),
                        decoration: BoxDecoration(
                          color: animation.value < 0.25 ? Theme.of(context).colorScheme.background : UIColors.blueGray100,
                          borderRadius: BorderRadius.circular(
                            getHorizontalSize(
                              7,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: getSize(
                          15,
                        ),
                        width: getSize(
                          15,
                        ),
                        margin: getMargin(
                          left: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (animation.value >= 0.25 && animation.value <0.5) ? Theme.of(context).colorScheme.background : UIColors.blueGray100,
                          borderRadius: BorderRadius.circular(
                            getHorizontalSize(
                              7,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: getSize(
                          15,
                        ),
                        width: getSize(
                          15,
                        ),
                        margin: getMargin(
                          left: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (animation.value >=0.5) ? Theme.of(context).colorScheme.background : UIColors.blueGray100,
                          borderRadius: BorderRadius.circular(
                            getHorizontalSize(
                              7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAvailableMedias() async {
    medias = [];
    for(var i=0;i<messages.length;i++){
      if( isImage(messages[i].media.split('.').last) &&  isVideo(messages[i].media.split('.').last) &&
      await File((await getApplicationDocumentsDirectory()).path+'/'+messages[i].media.split('/').last).exists()){
        medias.add((await getApplicationDocumentsDirectory()).path+'/'+messages[i].media.split('/').last);
      }
    }
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

  String getDuration(int time){
    return DateTime.fromMillisecondsSinceEpoch(time).format('mm:ss');
  }

  load() async{
    loading = false;
    user = await AuthApi().getUser().then((value) => value as User?);
    messages = await DatabaseHelper().getMessagesFromDisc(disc!.id);
    // await fetchMessages();
    // if(mounted)
    //   loopCheck = Timer.periodic(Duration(seconds: 2), (timer) async{
    //     if(mounted){
    //       await fetchMessages();
    //     }
    //   }
    // );
    // else
    //   loopCheck = Timer(Duration.zero,(){});
  }

  takeImage(ImageSource imagesource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: imagesource);
    if (file != null) {
      media = file.path ?? '';
      showSelectedMedia=true;
      showSelectedMedia=true;
      showmedia=true;
      setState(() {
      });
    }
    else{
      media = '';
      showmedia=false;
    }
    setState(() {});
  }

  bool isImage(String extension){
    var image_extensions=['JPG', 'PNG', 'GIF', 'WebP', 'BMP','WBMP'];
    //print(extension);
    for(var i=0;i<image_extensions.length;i++)
      if(extension.toLowerCase() == image_extensions[i].toLowerCase())
        return true;
    return false;
  }

  bool isVideo(String extension){
    var image_extensions=['MP4', 'avi', 'ogg'];
    for(var i=0;i<image_extensions.length;i++)
      if(extension == image_extensions[i].toLowerCase())
        return true;
    return false;
  }

  int getIndexOfmessage(String id){
    for(var i=0;i<messages.length;i++){
      if(messages[i].id==id)
        return i;
    }
    return -1;
  }

  chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      media = result.files.single.path ?? '';
      if(isVideo(media.split('.').last))
        _controller = VideoPlayerController.file(File(media))
          ..initialize().then((_) {
            setState(() {});
          });
      _controller.addListener(() {
        setState(() {});
      });

      showSelectedMedia=true;
      showmedia=true;
      setState(() {
      });
    }
    else{
      showmedia=false;
    }
    setState(() {});
  }

  sendMessage() async {
    if(messagecontroller.text.isNotEmpty || media.isNotEmpty) {
      int time = (DateTime.now().millisecondsSinceEpoch /1000).floor();
      String time_format = DateTime.now().format('yyyy-MM-dd HH:mm');
      if(media.isNotEmpty){
        String newName='muntur'+time.toString()+'_'+user!.id.replaceAll(':', '').replaceAll('-', '') +'.'+media.split('.').last;
        File media_ = File(media);
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        File newFile = await media_.copy('$path'+'/'+newName);
        media=newFile.path;
      }
      UIMessage message = UIMessage(
        id: user!.id +':'+ time.toString(),
        temp_id: time.toString(),
        emetteur: user!.id,
        date_envoi: time_format,
        state: 'pending',
        contenu: (messagecontroller.text.isEmpty && (isVideo(media.split('.').last) || isImage(media.split('.').last))) ? media.split('/').last : messagecontroller.text.isEmpty ? 'none' :messagecontroller.text,
        disc_id: disc!.id,
        media: media.isEmpty ? 'none' : media,
        mediaName: media.isEmpty ? 'none' : media.split('.').last,
        answerTo: answerTo.id == 'auto' ? 'none' : answerTo.id,
      );
      disc!.last_date=time_format;
      disc!.last_writer=message.emetteur;
      disc!.last_message=message.contenu;
      if (disc!.id == 'auto') {
        disc!.id = message.emetteur +':'+time.toString();
        var body;
        DatabaseHelper().insertDiscussion(disc!).then((value) async =>
        {
          ChatApi().createDiscussion(disc!.toJson()).then((resp) =>
          {
            if (resp.statusCode == 200){
              body = json.decode(resp.body)['data'] as Map,
              disc!.id = body['id'],
            }
          }),
          message.disc_id = disc!.id,
        });
        await DatabaseHelper().insertMessage(message);
      }
      else{
        DatabaseHelper().updateDiscussion(disc!);
        DatabaseHelper().insertMessage(message);
      }
      messages.add(message);
      //print(messages.last.toJson());
      _observer.itemCount = messages.length;
      messagecontroller.clear();
      showSelectedMedia=false;
      showmedia=false;
      media = '';
      scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000));
      FocusScope.of(context).requestFocus(FocusNode());
      try{
        _controller.dispose();
      }
      on Exception catch (e){

      }
      setState(() {});
    }
  }

  sendQuestion() async {
    user = await AuthApi().getUser().then((value) => value as User);
    dev.log("DEBUG : "+user!.id);
    if(messagecontroller.text.isNotEmpty || media.isNotEmpty) {
      int time = (DateTime.now().millisecondsSinceEpoch /1000).floor();
      String time_format = DateTime.now().format('yyyy-MM-dd HH:mm');
      if(media.isNotEmpty){
        String newName='muntur'+time.toString()+'_'+user!.id.replaceAll(':', '').replaceAll('-', '') +'.'+media.split('.').last;
        File media_ = File(media);
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        File newFile = await media_.copy('$path'+'/'+newName);
        media=newFile.path;
      }
      UIMessage message = UIMessage(
        id: '',
        temp_id: time.toString(),
        emetteur: user!.id,
        date_envoi: time_format,
        state: 'pending',
        // contenu: (messagecontroller.text.isEmpty && (isVideo(media.split('.').last) || isImage(media.split('.').last))) ? media.split('/').last : messagecontroller.text.isEmpty ? 'none' :messagecontroller.text,
        contenu: messagecontroller.text,
        disc_id: '',
        media: media.isEmpty ? "[]" : media,
        mediaName: media.isEmpty ? 'none' : media.split('.').last,
        answerTo: answerTo.id == 'auto' ? 'none' : answerTo.id,
      );
      if (messages.length==0) {
        disc!.id = '';
        disc!.title = messagecontroller.text.length>30? messagecontroller.text.substring(0,30):messagecontroller.text;
        disc!.last_date=time_format;
        DatabaseHelper().insertDiscussion(disc!).then((value) async =>
        {
          message.disc_id = disc!.id,
        });
        await DatabaseHelper().insertMessage(message);
      }
      else{
        disc!.last_writer=message.emetteur;
        disc!.last_message=message.contenu;
        disc!.last_date=time_format;
        DatabaseHelper().updateDiscussion(disc!);
        DatabaseHelper().insertMessage(message);
      }
      messages.add(message);
      _observer.itemCount = messages.length;
      messagecontroller.clear();
      showSelectedMedia=false;
      showmedia=false;
      media = '';
      // try{
      //   _controller.dispose();
      // }
      // on Exception catch (e){
      // }
      var aiResp=UIMessage();
      await ChatApi().askAI(message).then((response) => {
        if(response.statusCode==200){
          aiResp = UIMessage.fromJson(json.decode(response.body)['data']),
          messages.add(aiResp),
          disc!.last_writer=aiResp.emetteur,
          disc!.last_message=aiResp.contenu,
          disc!.last_date=aiResp.date_envoi,
          DatabaseHelper().updateDiscussion(disc!),
          DatabaseHelper().insertMessage(aiResp),
        }
        else{
          dev.log('Muntur DEBUG: '+response.body),
        },

        setState(() {
          loadAnswer=false;
        })
      });
      scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000));
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        loadAnswer=false;
      });
    }
  }

  bool first=false;

  Future<void> fetchMessages() async {
    var different = false;
    var is_in = false;
    var results;
    var done;

    List<UIMessage> messages1 = [];
    bool is_in1 = false;
    var idx=0;
    User selfUser=await AuthApi().getUser().then((value) => value as User);
    List<UIMessage> updatedListMessages;
      await ChatApi().getMessagesFromDisc(disc_id: disc!.id, time: (await ChatApi().getLastTimeDisc(disc!.id)+12)).then((response) async =>
      {
        if (response.statusCode == 200)
          {
            results = json.decode(response.body),
            //print(results),
            done = results['data'],
            for (var i = 0; i < done.length; i++)
              {
                messages1.add(UIMessage(
                  id: done[i]["id"],
                  disc_id: done[i]["disc_id"],
                  temp_id: done[i]["temp_id"],
                  emetteur: done[i]["emetteur"],
                  emetteurName: done[i]["emetteurName"],
                  contenu: done[i]["contenu"],
                  media: done[i]["media"],
                  answerTo: done[i]["answerTo"],
                  mediaName: done[i]["mediaName"],
                  state: done[i]["state"],
                  date_envoi: done[i]["creation_date"] ?? 0,
                )),
              },
            updatedListMessages = await DatabaseHelper().getMessage().then((value) => value),
            for (var i = 0; i < messages1.length; i++)
              {
                if (updatedListMessages.isEmpty)
                  {
                    await DatabaseHelper().insertMessage(messages1[i]),
                  }
                else
                  {
                    is_in1 = false,
                    idx = -1,
                    for (var ie = 0; ie < updatedListMessages.length; ie++)
                      {
                        if (updatedListMessages[ie].id == messages1[i].id || updatedListMessages[ie].id == messages1[i].temp_id )
                          {
                            is_in1 = true,
                            idx = ie,
                          }
                      },
                    if (is_in1)
                      {
                        if(updatedListMessages[idx].id == messages1[i].temp_id)
                          await DatabaseHelper().updateMessage(messages1[i], id: updatedListMessages[idx].id),
                        if( messages1[i].emetteur != selfUser.id && updatedListMessages[idx].announced == 'no'){
                          messages1[i].announced = 'yes',
                          await DatabaseHelper().updateMessage(messages1[i])
                        },
                        if(updatedListMessages[idx].state != 'delete' && updatedListMessages[idx].state != messages1[i].state)
                          await DatabaseHelper().updateMessage(messages1[i])
                      }
                    else
                      {
                        await DatabaseHelper().insertMessage(messages1[i]),
                      }
                  }
              },
          }
      });
      await DatabaseHelper().getMessagesFromDisc(disc!.id).then((list) =>
      {
        if(messages.isNotEmpty){
          different = true,
          for(var i = 0; i < list.length; i++){
            if(DateTime.parse(list[i].date_envoi).isAfter(DateTime.parse(messages.last.date_envoi))){
              messages.add(list[i]),
              setState(() {}),
            }
          },
        }
        else{
          messages = list,
          setState(() {}),
          scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000)),
          },
      });
      disc!.last_check = DateTime.now().millisecondsSinceEpoch~/1000;
      await DatabaseHelper().updateDiscussion(disc!);
  }


}