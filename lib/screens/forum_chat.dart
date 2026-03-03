// ignore_for_file: unnecessary_cast, unused_catch_clause, empty_catches

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:munturai/widgets/widget_message2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';

import '../core/colors/colors.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/widget_message.dart';

bool lightForum = false;

class ForumChatView extends ConsumerStatefulWidget {
  Discussion? disc;
  ForumChatView({
    super.key,
    this.disc,
  });
  @override
  ConsumerState<ForumChatView> createState() => ForumChatState(disc: disc);
}

class ForumChatState extends ConsumerState<ForumChatView>
    with TickerProviderStateMixin {
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
  String currentUserId = '';
  List<String> medias = [];
  int lastTime = 0;
  late Animation<double> animation;
  late AnimationController controller;

  late VideoPlayerController _controller;

  ForumChatState({
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
    loopCheck.cancel();
    messagecontroller.dispose();
    pageController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    if (showSelectedMedia == true) {
      showmedia = false;
      showSelectedMedia = false;
      setState(() {});
      return false;
    } else if (viewSelectedMedia == true) {
      showmedia = false;
      showSelectedMedia = false;
      viewSelectedMedia = false;
      setState(() {});
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);

    // Read current user ID from auth provider
    final userState = ref.watch(authStateProvider);
    currentUserId = userState.valueOrNull?.id ?? '';

    // Watch forum messages from Riverpod (Isar + online-first)
    final messagesState = ref.watch(chatMessagesProvider(disc?.id ?? 'none'));
    if (messagesState is AsyncData) {
      messages = (messagesState.value ?? [])
          .map((m) => UIMessage(
                id: m.id,
                disc_id: m.discId,
                temp_id: m.tempId,
                emetteur: m.senderId,
                emetteurName: m.senderName,
                contenu: m.contenu,
                answerTo: m.answerTo,
                media: m.media,
                mediaName: m.mediaName,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(titleTxt: disc!.title),
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
                            ? Center(
                                child: Text('Vidéo sélectionnée',
                                    style: appStyle.H4()))
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
                                        child: Text(media.split('.').last,
                                            style: appStyle.H3(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface))),
                                  ),
                                  Padding(padding: getPadding(top: 20)),
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(media.split('/').last,
                                        style: appStyle.H4(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface)),
                                  )),
                                ],
                              ),
                  )
                : const SizedBox(),
            (showSelectedMedia == false && viewSelectedMedia == false)
                ? Container(
                    height: BodyHeight() - 110,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        if (messages.isEmpty)
                          MessageWidget2(message: UIMessage(), head: true),
                        Container(
                          height: BodyHeight() - 202,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.separated(
                            separatorBuilder: (context, i) {
                              return SizedBox(height: getHorizontalSize(15));
                            },
                            itemBuilder: (context, index) {
                              return MessageWidget2(
                                message: messages[index],
                                sender:
                                    messages[index].emetteur == currentUserId,
                                head: false,
                              );
                            },
                            itemCount: messages.length,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            // Input bar
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                height: 50 +
                    min(4, (messagecontroller.text.length ~/ 19).toInt()) * 8,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                  top: min(
                                              4,
                                              (messagecontroller.text.length ~/
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
                                            .surface
                                            .withValues(alpha: 0.2),
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
                                      onPressed: () async {
                                        final text =
                                            messagecontroller.text.trim();
                                        if (text.isEmpty) return;
                                        setState(() {
                                          showAnswer = false;
                                          loadAnswer = true;
                                          messagecontroller.clear();
                                        });
                                        await ref
                                            .read(chatMessagesProvider(
                                                    disc?.id ?? 'none')
                                                .notifier)
                                            .sendForumMessage(
                                              text,
                                              senderId: currentUserId,
                                              answerToId: answerTo.id == 'auto'
                                                  ? 'none'
                                                  : answerTo.id,
                                            );
                                        setState(() {
                                          loadAnswer = false;
                                          answerTo = UIMessage();
                                          showAnswer = false;
                                        });
                                        syncView();
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
            // Loading indicator
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: getPadding(bottom: 50.0),
                child: AnimatedContainer(
                  height: loadAnswer ? 50 : 0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 3; i++)
                        Container(
                          height: getSize(15),
                          width: getSize(15),
                          margin: i > 0 ? getMargin(left: 8) : null,
                          decoration: BoxDecoration(
                            color: (animation.value >= i * 0.25 &&
                                    animation.value < (i + 1) * 0.25)
                                ? Theme.of(context).colorScheme.surface
                                : UIColors.blueGray100,
                            borderRadius:
                                BorderRadius.circular(getHorizontalSize(7)),
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
      return '$dayCalendar, $day $month $year';
    }
    String duree = '';
    double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    double periode = actual - time;
    if (periode / 3600 < 1) {
      duree = '${(periode / 60).floor()}min';
    } else if (periode / 3600 < 24) {
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('kk:mm');
    } else {
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('MM/dd');
    }
    return duree;
  }

  String getDuration(int time) {
    return DateTime.fromMillisecondsSinceEpoch(time).format('mm:ss');
  }

  takeImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: imageSource);
    if (file != null) {
      media = file.path;
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
    var exts = ['JPG', 'PNG', 'GIF', 'WebP', 'BMP', 'WBMP', 'JPEG'];
    return exts.any((e) => e.toLowerCase() == extension.toLowerCase());
  }

  bool isVideo(String extension) {
    var exts = ['MP4', 'AVI', 'OGG', 'MOV'];
    return exts.any((e) => e.toLowerCase() == extension.toLowerCase());
  }

  int getIndexOfMessage(String id) {
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].id == id) return i;
    }
    return -1;
  }

  chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      media = result.files.single.path ?? '';
      showSelectedMedia = true;
      showmedia = true;
      setState(() {});
    } else {
      showmedia = false;
    }
    setState(() {});
  }
}
