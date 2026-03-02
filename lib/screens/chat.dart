// ignore_for_file: unnecessary_cast, unused_catch_clause, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/features/chatbot/data/models/message_model.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
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
import '../model/user.dart';
import '../services/api/chat.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/widget_message.dart';

bool light = false;

class ChatView extends ConsumerStatefulWidget {
  Discussion? disc;
  ChatView({
    super.key,
    this.disc,
  });
  @override
  ConsumerState<ChatView> createState() => Chat_(disc: disc);
}

class Chat_ extends ConsumerState<ChatView> with TickerProviderStateMixin {
  bool show_login = false;
  bool showimagesource = false;
  bool loadAnswer = false;
  bool showmedia = false;
  bool showSelectedMedia = false;
  bool viewSelectedMedia = false;
  bool showAnswer = false;
  bool load_photo = false;
  bool show_militant = false;
  bool show_locality = false;
  bool loading = true;
  List<MessageWidget> allMessageWidgets = [];
  List<GlobalKey<MessageWidget_>> allMessageWidgetsStates = [];
  UIMessage answerTo = UIMessage();
  String media = "";
  List<UIMessage> messages = [];
  PageController pageController = PageController();
  AutoScrollController scrollcontroller = AutoScrollController();
  final messagecontroller = TextEditingController();
  Discussion? disc;
  User? user;
  List<String> medias = [];
  int lastTime = 0;
  late Animation<double> animation;
  late AnimationController controller;

  late VideoPlayerController videoController;

  Chat_({
    Key? key,
    this.disc,
  });
  Timer loopCheck = Timer(Duration.zero, () {});

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
        setState(() {});
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
    messages.clear();
    // try {
    //   _controller.dispose();
    // } catch (e) {
    //   print("Munturai DEBUG: video controller already disposed");
    // }
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    if (showSelectedMedia == true) {
      showmedia = false;
      showSelectedMedia = false;
      setState(() {});
      videoController.dispose();
      return false;
    } else if (viewSelectedMedia == true) {
      showmedia = false;
      showSelectedMedia = false;
      viewSelectedMedia = false;
      setState(() {});
      videoController.dispose();
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    AppLocalizations? translator = AppLocalizations.of(context)!;

    final messagesState = ref.watch(chatMessagesProvider(disc?.id ?? 'none'));
    if (messagesState is AsyncData) {
      messages = (messagesState.value ?? [])
          .map((m) => UIMessage(
                id: m.id,
                disc_id: m.discId,
                temp_id: m.tempId,
                emetteur: m.senderId,
                emetteurName: m.senderName,
                emetteurPhoto: m.senderPhoto,
                contenu: m.contenu,
                answerTo: m.answerTo,
                media: m.media,
                mediaName: m.mediaName,
                mediaSize: m.mediaSize,
                announced: m.announced,
                state: m.messageState,
                date_envoi: m.dateEnvoi.toIso8601String(),
              ))
          .toList();
      messages.sort((a, b) =>
          DateTime.parse(a.date_envoi).compareTo(DateTime.parse(b.date_envoi)));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          titleTxt: disc!.title,
        ),
        body: Stack(
          children: [
            (showSelectedMedia && viewSelectedMedia == false)
                ? Container(
                    width: BodyWidth(),
                    height: BodyHeight(),
                    decoration: BoxDecoration(
                        color: (isImage(media.split('.').last) ||
                                isVideo(media.split('.').last))
                            ? Colors.black
                            : Colors.white70),
                    child: isImage(media.split('.').last)
                        ? Image.file(
                            File(media),
                            fit: BoxFit.contain,
                            width: BodyWidth(),
                            height: BodyHeight(),
                          )
                        : isVideo(media.split('.').last)
                            ? Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        videoController.value.isPlaying
                                            ? videoController.pause()
                                            : videoController.play();
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(padding: getPadding(top: 200)),
                                        Center(
                                          child: SizedBox(
                                            width: BodyWidth(),
                                            height: 300,
                                            child: VideoPlayer(videoController),
                                          ),
                                        ),
                                        Padding(padding: getPadding(top: 100)),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            width: BodyWidth(),
                                            padding:
                                                getPadding(left: 10, right: 10),
                                            child: Row(
                                              children: [
                                                Text(
                                                  getDuration(videoController
                                                      .value
                                                      .position
                                                      .inMilliseconds),
                                                  style: appStyle.txtRoboto(
                                                      size: 18,
                                                      color: Colors.white),
                                                ),
                                                Flexible(
                                                  child: VideoProgressIndicator(
                                                    videoController,
                                                    allowScrubbing: true,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                  ),
                                                ),
                                                Text(
                                                  getDuration(videoController
                                                      .value
                                                      .duration
                                                      .inMilliseconds),
                                                  style: appStyle.txtRoboto(
                                                      size: 18,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          videoController.value.isPlaying
                                              ? videoController.pause()
                                              : videoController.play();
                                        });
                                      },
                                      child: videoController.value.isPlaying
                                          ? const SizedBox()
                                          : const Icon(
                                              Icons.play_circle,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: getHorizontalSize(150),
                                    height: getVerticalSize(150),
                                    decoration: BoxDecoration(
                                        color: UIColors.warningColor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text(
                                      media.split('.').last,
                                      style: appStyle.H3(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                    )),
                                  ),
                                  Padding(padding: getPadding(top: 20)),
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      media.split('/').last,
                                      style: appStyle.H4(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                    ),
                                  )),
                                ],
                              ),
                  )
                : const SizedBox(),
            (showSelectedMedia == false && viewSelectedMedia)
                ? Container(
                    width: BodyWidth(),
                    height: BodyHeight(),
                    decoration: (isImage(media.split('.').last) ||
                            isVideo(media.split('.').last))
                        ? const BoxDecoration(color: Colors.black)
                        : const BoxDecoration(color: Colors.white70),
                    child: PageView.builder(
                        controller: pageController,
                        reverse: false,
                        itemCount: medias.length,
                        itemBuilder: (context, index) {
                          if (isImage(medias[index].split('.').last)) {
                            return Image.file(
                              File(medias[index]),
                              fit: BoxFit.contain,
                              width: BodyWidth(),
                              height: BodyHeight(),
                            );
                          } else {
                            VideoPlayerController videoController =
                                new VideoPlayerController.file(
                                    File(medias[index]))
                                  ..initialize().then((_) {
                                    setState(() {});
                                  });
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      videoController.value.isPlaying
                                          ? videoController.pause()
                                          : videoController.play();
                                    });
                                  },
                                  child: Center(
                                    child: SizedBox(
                                      width: BodyWidth(),
                                      height: 300,
                                      child: VideoPlayer(videoController),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        videoController.value.isPlaying
                                            ? videoController.pause()
                                            : videoController.play();
                                      });
                                    },
                                    child: videoController.value.isPlaying
                                        ? const SizedBox()
                                        : const Icon(
                                            Icons.play_circle,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: VideoProgressIndicator(
                                    videoController,
                                    allowScrubbing: true,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                )
                              ],
                            );
                          }
                        }),
                  )
                : const SizedBox(),
            (showSelectedMedia == false && viewSelectedMedia == false)
                ? Container(
                    height: BodyHeight() - 110,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        if (messages.isEmpty)
                          MessageWidget2(
                            message: UIMessage(),
                            head: true,
                          ),
                        Container(
                          height: BodyHeight() - 202,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.separated(
                            separatorBuilder: (context, i) {
                              return SizedBox(
                                height: getHorizontalSize(15),
                                width: double.infinity,
                              );
                            },
                            itemBuilder: (context, index) {
                              return MessageWidget2(
                                message: messages[index],
                                sender: messages[index].emetteur == user!.id,
                                head: false,
                              );
                            },
                            itemCount: messages.length,
                          ),
                        ),
                      ],
                    ))
                : const SizedBox(),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                width: double.maxFinite,
                height: showimagesource ? 150 : 0,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    boxShadow: const [BoxShadow()],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                duration: const Duration(milliseconds: 600),
                curve: Curves.linear,
                child: Stack(
                  children: [
                    Padding(
                      padding: getPadding(top: 10, left: 10, right: 10),
                      child: ListView(
                        children: [
                          Padding(padding: getPadding(top: 10)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showimagesource = false;
                              });
                              takeImage(ImageSource.gallery);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.image),
                                Padding(padding: getPadding(left: 8)),
                                Text(
                                  translator.gallery,
                                  style: appStyle.H4(),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                          Padding(padding: getPadding(top: 30)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showimagesource = false;
                              });
                              chooseFile();
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.file_present_sharp),
                                Padding(padding: getPadding(left: 8)),
                                Text(
                                  'Document',
                                  style: appStyle.H4(),
                                ),
                                const Spacer(),
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
              child: Container(
                color: Theme.of(context).colorScheme.background,
                height: (showAnswer ? 100 : 50) +
                    min(4, (messagecontroller.text.length ~/ 19).toInt()) * 8,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      showAnswer
                          ? Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    //setState(() {});
                                    scrollcontroller.scrollToIndex(
                                        getIndexOfmessage(answerTo.id),
                                        preferPosition:
                                            AutoScrollPosition.begin,
                                        duration: const Duration(seconds: 1));
                                    //scrollcontroller.highlight(getIndexOfmessage(answerTo.id));
                                    // allMessageWidgetsStates[getIndexOfmessage(answerTo.id)].currentState!.highlight();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Container(
                                      height: 37,
                                      padding: getPadding(
                                          top: 5,
                                          left: 10,
                                          right: 10,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                        color: UIColors.blueGray100,
                                        border: Border(
                                            top: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          width: 4,
                                        )),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                answerTo.emetteur == user!.id
                                                    ? translator.you
                                                    : answerTo.emetteurName,
                                                overflow: TextOverflow.ellipsis,
                                                style: appStyle.H5(
                                                    color:
                                                        UIColors.warningColor,
                                                    weight: 'bold'),
                                              ),
                                              Padding(
                                                  padding:
                                                      getPadding(left: 10)),
                                              Text(
                                                answerTo.contenu,
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, right: 16),
                                    child: Row(
                                      children: [
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              answerTo = UIMessage();
                                              showAnswer = false;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: Row(
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
                              height: 40 +
                                  min(
                                          4,
                                          (messagecontroller.text.length ~/ 17)
                                              .toInt()) *
                                      8,
                              width: BodyWidth() - 30.w,
                              margin: getMargin(
                                  left: 10,
                                  top: showmedia
                                      ? 7
                                      : min(
                                                  4,
                                                  (messagecontroller
                                                          .text.length ~/
                                                      19)) >
                                              0
                                          ? 7
                                          : 0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40 +
                                        min(
                                                4,
                                                (messagecontroller
                                                            .text.length ~/
                                                        17)
                                                    .toInt()) *
                                            8,
                                    width: BodyWidth() - 80.w,
                                    // margin: const EdgeInsets.symmetric(horizontal: 10),
                                    // decoration: BoxDecoration(
                                    //     color: UIColors.blueGray100,
                                    //     borderRadius: BorderRadius.circular(20)
                                    // ),
                                    child: TextField(
                                      onChanged: (e) {
                                        setState(() {});
                                      },
                                      controller: messagecontroller,
                                      style: appStyle.H5(),
                                      cursorColor:
                                          Theme.of(context).colorScheme.primary,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Message ...',
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .background
                                            .withOpacity(0.2),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: getPadding(bottom: 20),
                                    child: IconButton(
                                      icon: Icon(
                                        CupertinoIcons.arrow_up_circle_fill,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showAnswer = false;
                                          loadAnswer = true;
                                        });
                                        sendQuestion(context);
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
              child: Padding(
                padding: getPadding(bottom: 50.0),
                child: AnimatedContainer(
                  height: loadAnswer ? 50 : 0,
                  // height: 50,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                  child: Row(
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
                          color: animation.value < 0.25
                              ? Theme.of(context).colorScheme.background
                              : UIColors.blueGray100,
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
                          color:
                              (animation.value >= 0.25 && animation.value < 0.5)
                                  ? Theme.of(context).colorScheme.background
                                  : UIColors.blueGray100,
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
                          color: (animation.value >= 0.5)
                              ? Theme.of(context).colorScheme.background
                              : UIColors.blueGray100,
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
    for (var i = 0; i < messages.length; i++) {
      if (isImage(messages[i].media.split('.').last) &&
          isVideo(messages[i].media.split('.').last) &&
          await File(
                  '${(await getApplicationDocumentsDirectory()).path}/${messages[i].media.split('/').last}')
              .exists()) {
        medias.add(
            '${(await getApplicationDocumentsDirectory()).path}/${messages[i].media.split('/').last}');
      }
    }
  }

  String getDate(num time, {bool hh_mm = false, bool yy_mm = false}) {
    if (hh_mm) {
      return DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('kk:mm');
    }
    if (yy_mm) {
      var days = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche'
      ];
      var months = [
        'Janvier',
        'Fevrier',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Aout',
        'Septembre',
        'Octobre',
        'Novembre',
        'Decembre'
      ];
      String day = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .day
          .toString();
      String dayCalendar = days[
          DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000).weekday - 1];
      String month = months[
          DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000).month - 1];
      String year = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .year
          .toString();
      String date = '$dayCalendar, $day $month $year';
      return date;
    }
    String duree = '';
    double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    double periode = actual - time;
    if (periode / 3600 < 1) {
      duree = '${(periode / 60).floor()}min';
    } else if (periode / 3600 < 24)
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('kk:mm');
    else
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('MM/dd');
    return duree;
  }

  String getDuration(int time) {
    return DateTime.fromMillisecondsSinceEpoch(time).format('mm:ss');
  }

  load() async {
    loading = true;
    user = await AuthApi().getUser().then((value) => value as User?);
    if (disc!.id != 'auto') {
      messages = await DatabaseHelper().getMessagesFromDisc(disc!.id);
    }
    setState(() {
      loading = false;
    });
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
      showSelectedMedia = true;
      showSelectedMedia = true;
      showmedia = true;
      setState(() {});
    } else {
      media = '';
      showmedia = false;
    }
    setState(() {});
  }

  bool isImage(String extension) {
    var imageExtensions = ['JPG', 'PNG', 'GIF', 'WebP', 'BMP', 'WBMP'];
    //print(extension);
    for (var i = 0; i < imageExtensions.length; i++) {
      if (extension.toLowerCase() == imageExtensions[i].toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  bool isVideo(String extension) {
    var imageExtensions = ['MP4', 'avi', 'ogg'];
    for (var i = 0; i < imageExtensions.length; i++) {
      if (extension == imageExtensions[i].toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  int getIndexOfmessage(String id) {
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      media = result.files.single.path ?? '';
      if (isVideo(media.split('.').last)) {
        videoController = VideoPlayerController.file(File(media))
          ..initialize().then((_) {
            setState(() {});
          });
      }
      videoController.addListener(() {
        setState(() {});
      });

      showSelectedMedia = true;
      showmedia = true;
      setState(() {});
    } else {
      showmedia = false;
    }
    setState(() {});
  }

  syncView() {
    _observer.itemCount = messages.length;
    messagecontroller.clear();
    showSelectedMedia = false;
    showmedia = false;
    media = '';
    scrollcontroller.scrollToIndex(messages.length - 1,
        preferPosition: AutoScrollPosition.end,
        duration: const Duration(milliseconds: 1000));
    if (mounted) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  sendMessage(UIMessage message, BuildContext context,
      {bool start = true}) async {
    UIMessage aiResp = UIMessage();
    String timeFormat = DateTime.now().format('yyyy-MM-dd HH:mm');

    if (start) {
      ChatApi().startAIChat().then((startDiscResp) async => {
            if (kDebugMode)
              print(
                  'Muntur DEBUG: starting discussion response ${startDiscResp.body.toString()}'),
            if (startDiscResp.statusCode == 200)
              {
                disc!.id = json.decode(startDiscResp.body)['id'],
                disc!.last_writer = message.emetteur,
                disc!.last_message = message.contenu,
                disc!.last_date = timeFormat,
                setState(() {}),
                message.disc_id = disc!.id,
                messages.add(message),
                syncView(),
                // Save in local database
                DatabaseHelper().insertDiscussion(disc!),
                DatabaseHelper().insertMessage(message),
              }
            // else{
            //   dev.log('Muntur DEBUG: failed to create discussion ${startDiscResp.body.toString()}'),
            // },
          });
    }

    await ChatApi().askAI(message).then((response) => {
          if (response.statusCode == 200)
            {
              aiResp = UIMessage.fromJson(json.decode(response.body)['data']),
              messages.add(aiResp),
              disc!.last_writer = aiResp.emetteur,
              disc!.last_message = aiResp.contenu,
              disc!.last_date = aiResp.date_envoi,
              syncView(),

              // Save in local database
              DatabaseHelper().updateDiscussion(disc!),
              DatabaseHelper().insertMessage(aiResp),
            }
          else
            {
              if (kDebugMode)
                print('Muntur DEBUG: failed to send message ${response.body}'),
            },
          setState(() {
            loadAnswer = false;
          }),
        });
    setState(() {
      loadAnswer = false;
    });
    DatabaseHelper().insertDiscussion(disc!).then((value) async => {
          await DatabaseHelper().insertMessage(message),
        });
  }

  sendQuestion(BuildContext context) async {
    user = await AuthApi().getUser().then((value) => value as User);
    if (kDebugMode) {
      print('Munturai DEBUG: Sending question ...');
    }
    if (messagecontroller.text.isNotEmpty || media.isNotEmpty) {
      int time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      String timeFormat = DateTime.now().format('yyyy-MM-dd HH:mm');
      if (media.isNotEmpty) {
        String newName =
            'muntur${time}_${user!.id.replaceAll(':', '').replaceAll('-', '')}.${media.split('.').last}';
        File media_ = File(media);
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        File newFile = await media_.copy('$path/$newName');
        media = newFile.path;
      }
      UIMessage message = UIMessage(
        id: '',
        temp_id: time.toString(),
        emetteur: user!.id,
        date_envoi: timeFormat,
        state: 'pending',
        // contenu: (messagecontroller.text.isEmpty && (isVideo(media.split('.').last) || isImage(media.split('.').last))) ? media.split('/').last : messagecontroller.text.isEmpty ? 'none' :messagecontroller.text,
        contenu: messagecontroller.text,
        disc_id: disc!.id,
        media: media.isEmpty ? "[]" : media,
        mediaName: media.isEmpty ? 'none' : media.split('.').last,
        answerTo: answerTo.id == 'auto' ? 'none' : answerTo.id,
      );
      UIMessage aiResp = UIMessage();
      if (disc!.title == 'New Discussion' || messages.isEmpty) {
        disc!.title = messagecontroller.text.length > 30
            ? messagecontroller.text.substring(0, 30)
            : messagecontroller.text;
      }
      await ChatApi().askAI(message).then((response) => {
            if (response.statusCode == 200)
              {
                aiResp = UIMessage.fromJson(json.decode(response.body)['data']),
                messages.add(message),
                messages.add(aiResp),
                disc!.id = aiResp.disc_id,
                disc!.last_writer = aiResp.emetteur,
                disc!.last_message = aiResp.contenu,
                disc!.last_date = aiResp.date_envoi,
                setState(() {}),
                syncView(),

                // Save in local database
                if (messages.length == 2)
                  {
                    DatabaseHelper().insertDiscussion(disc!),
                  }
                else
                  {
                    DatabaseHelper().updateDiscussion(disc!),
                  },
                DatabaseHelper().insertMessage(aiResp),
              }
            else
              {
                if (kDebugMode)
                  print(
                      'Muntur DEBUG: failed to send message ${response.body}'),
              },
            setState(() {
              loadAnswer = false;
            }),
          });
    }
  }

  bool first = false;

  Future<void> fetchMessages() async {
    var different = false;
    var isIn = false;
    var results;
    var done;

    List<UIMessage> messages1 = [];
    bool isIn1 = false;
    var idx = 0;
    User selfUser = await AuthApi().getUser().then((value) => value);
    List<UIMessage> updatedListMessages;
    await ChatApi()
        .getMessagesFromDisc(
            disc_id: disc!.id,
            time: (await ChatApi().getLastTimeDisc(disc!.id) + 12))
        .then((response) async => {
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
                  updatedListMessages = await DatabaseHelper()
                      .getMessage()
                      .then((value) => value),
                  for (var i = 0; i < messages1.length; i++)
                    {
                      if (updatedListMessages.isEmpty)
                        {
                          await DatabaseHelper().insertMessage(messages1[i]),
                        }
                      else
                        {
                          isIn1 = false,
                          idx = -1,
                          for (var ie = 0;
                              ie < updatedListMessages.length;
                              ie++)
                            {
                              if (updatedListMessages[ie].id ==
                                      messages1[i].id ||
                                  updatedListMessages[ie].id ==
                                      messages1[i].temp_id)
                                {
                                  isIn1 = true,
                                  idx = ie,
                                }
                            },
                          if (isIn1)
                            {
                              if (updatedListMessages[idx].id ==
                                  messages1[i].temp_id)
                                await DatabaseHelper().updateMessage(
                                    messages1[i],
                                    id: updatedListMessages[idx].id),
                              if (messages1[i].emetteur != selfUser.id &&
                                  updatedListMessages[idx].announced == 'no')
                                {
                                  messages1[i].announced = 'yes',
                                  await DatabaseHelper()
                                      .updateMessage(messages1[i])
                                },
                              if (updatedListMessages[idx].state != 'delete' &&
                                  updatedListMessages[idx].state !=
                                      messages1[i].state)
                                await DatabaseHelper()
                                    .updateMessage(messages1[i])
                            }
                          else
                            {
                              await DatabaseHelper()
                                  .insertMessage(messages1[i]),
                            }
                        }
                    },
                }
            });
    await DatabaseHelper().getMessagesFromDisc(disc!.id).then((list) => {
          if (messages.isNotEmpty)
            {
              different = true,
              for (var i = 0; i < list.length; i++)
                {
                  if (DateTime.parse(list[i].date_envoi)
                      .isAfter(DateTime.parse(messages.last.date_envoi)))
                    {
                      messages.add(list[i]),
                      setState(() {}),
                    }
                },
            }
          else
            {
              messages = list,
              setState(() {}),
              scrollcontroller.scrollToIndex(messages.length - 1,
                  preferPosition: AutoScrollPosition.end,
                  duration: const Duration(milliseconds: 1000)),
            },
        });
    disc!.last_check = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await DatabaseHelper().updateDiscussion(disc!);
  }
}
