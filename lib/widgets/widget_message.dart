import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_player/video_player.dart';

import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';

/// Widget d'affichage d'un message dans ChatView.
/// Dépendances legacy Discussion/User/ChatApi/DatabaseHelper supprimées.
/// syncMessage() supprimé : le retry est géré par chatMessagesProvider.
class MessageWidget extends StatefulWidget {
  final GlobalKey? idKey;
  final UIMessage? message;
  final UIMessage? answerTo;
  final int answerIndex;

  /// ID de la discussion (ex: disc.type pour savoir si forum)
  final String discType;

  /// ID de l'utilisateur connecté (remplace User.id)
  final String userId;
  final Chat_ chatView;
  final bool show_time;

  MessageWidget({
    Key? key,
    required this.idKey,
    required this.message,
    required this.answerTo,
    this.answerIndex = 0,
    required this.discType,
    required this.userId,
    required this.chatView,
    this.show_time = false,
  }) : super(key: key);

  @override
  State<MessageWidget> createState() => MessageWidget_(
      key: idKey,
      discType: discType,
      userId: userId,
      message: message,
      answerTo: answerTo,
      answerIndex: answerIndex,
      chatView: chatView);
}

class MessageWidget_ extends State<MessageWidget> {
  final GlobalKey _containerKey = GlobalKey();
  Key? key;
  UIMessage? message;
  UIMessage? answerTo;
  int answerIndex;
  String discType;
  String userId;
  Chat_ chatView;
  bool showTime;
  bool loadPhoto = false;
  bool mediaIsDownloaded = false;
  late VideoPlayerController _controller;

  MessageWidget_({
    required this.message,
    required this.discType,
    required this.chatView,
    required this.userId,
    this.showTime = false,
    this.answerIndex = 0,
    required this.key,
    required this.answerTo,
  });

  Color _color = Colors.transparent;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(''))..initialize();

    if (isVideo(message!.media.split('.').last)) {
      if (message!.media.startsWith('/data/')) {
        _controller = VideoPlayerController.file(File(message!.media))
          ..initialize().then((_) => setState(() {}));
      } else {
        _controller = VideoPlayerController.networkUrl(Uri(
            scheme: 'http',
            host: 'omc.steps4u.net',
            path: 'api/omc/media/${message!.media}'))
          ..initialize().then((_) => setState(() {}));
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final bool sending = (userId == message!.emetteur);
    final bool show_name = (discType == 'forum');
    int messagelength =
        message!.contenu.length >= 36 ? 36 : message!.contenu.length;
    int answerlength =
        answerTo!.contenu.length >= 36 ? 36 : answerTo!.contenu.length;
    double proportion = (((MediaQuery.of(context).size.width) * 0.8)) / 36;
    if (message!.answerTo != 'none') {
      messagelength =
          messagelength > answerlength ? messagelength : answerlength;
    }
    double messageSize = (messagelength * proportion) + 50;

    return SwipeTo(
      key: key,
      onRightSwipe: (details) {
        chatView.answerTo = answerTo!;
        chatView.showAnswer = true;
        chatView.setState(() {});
      },
      onLeftSwipe: (details) {
        chatView.answerTo = answerTo!;
        chatView.showAnswer = true;
        chatView.setState(() {});
      },
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(color: _color),
        child: Padding(
          padding: getPadding(top: 14),
          child: Row(
            mainAxisAlignment:
                sending ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: (MediaQuery.of(context).size.width) * 0.8,
                    minWidth: 60),
                child: Container(
                  padding: getPadding(left: 5, top: 5, right: 5, bottom: 5),
                  margin: getMargin(right: 5, left: 5),
                  width:
                      (message!.mediaName != 'none' || message!.media != 'none')
                          ? (MediaQuery.of(context).size.width) * 0.6
                          : messageSize,
                  decoration: sending
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer)
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: UIColors.boxFillColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Nom de l'émetteur (forums uniquement)
                      if (show_name && !sending)
                        Text(
                          message!.emetteurName,
                          maxLines: null,
                          style: appStyle
                              .txtArimoHebrewSubset(weight: 'bold')
                              .copyWith(letterSpacing: getHorizontalSize(0.26)),
                        ),

                      // Réponse à
                      if (message!.answerTo != 'none')
                        GestureDetector(
                          onTap: () {
                            chatView.scrollcontroller.scrollToIndex(answerIndex,
                                preferPosition: AutoScrollPosition.begin,
                                duration: const Duration(seconds: 1));
                          },
                          child: Container(
                            height: 36,
                            padding: getPadding(
                                top: 5, left: 10, right: 10, bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              border: Border(
                                  top: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 4)),
                            ),
                            child: ListView(
                              children: [
                                Text(
                                  answerTo!.emetteur == userId
                                      ? 'Vous'
                                      : answerTo!.emetteurName,
                                  overflow: TextOverflow.ellipsis,
                                  style: appStyle.txtAclonica(
                                      size: 16,
                                      color: UIColors.warningColor,
                                      weight: 'bold'),
                                ),
                                Padding(padding: getPadding(left: 10)),
                                Text(
                                  answerTo!.contenu,
                                  overflow: TextOverflow.ellipsis,
                                  style: appStyle.H6(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Contenu du message
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                                  ClipboardData(text: message!.contenu))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'message copié dans le presse papier')),
                            );
                          });
                        },
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              message!.contenu,
                              maxLines: null,
                              textAlign: TextAlign.left,
                              style: appStyle.H6(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),

                      // Heure + statut
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTime(message!.date_envoi),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: appStyle
                                  .txtArimoHebrewSubset(color: Colors.blueGrey)
                                  .copyWith(
                                      letterSpacing: getHorizontalSize(0.28)),
                            ),
                            if (sending) Padding(padding: getPadding(left: 10)),
                            if (sending) _statusIcon(message!.state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String state) {
    if (state == 'sent' || state == 'received' || state == 'read') {
      return const Icon(Icons.check, size: 12);
    }
    if (state == 'failed') {
      return const Icon(Icons.warning, color: Colors.red, size: 12);
    }
    return const Icon(Icons.access_time, size: 12);
  }

  String _getTime(String isoDate) {
    try {
      return DateTime.parse(isoDate).toLocal().toString().substring(11, 16);
    } catch (_) {
      return '';
    }
  }

  bool isImage(String extension) {
    const exts = ['jpg', 'png', 'gif', 'webp', 'bmp', 'wbmp'];
    return exts.contains(extension.toLowerCase());
  }

  bool isVideo(String extension) {
    const exts = ['mp4', 'avi', 'ogg'];
    return exts.contains(extension.toLowerCase());
  }

  Future<bool> mediaIsinLocal(String file) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${file.split('/').last}').exists();
  }
}
