import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/features/news/domain/entities/news_entity.dart';
import 'package:munturai/model/Comment.dart';
import 'package:munturai/services/api/notification.dart';

import '../core/colors/colors.dart';
import '../core/theming/app_style.dart';
import '../core/theming/theme.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/Info.dart';
import '../model/Message.dart';
import '../model/User.dart';
import '../services/api/auth.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_comment.dart';
import '../widgets/widget_info.dart';

bool light = false;

class InfoView extends StatefulWidget {
  Info? info;
  bool keyboardFocus;
  InfoView({
    Key? key,
    required this.info,
    this.keyboardFocus = false,
  }) : super(
          key: key,
        );
  @override
  State<InfoView> createState() =>
      InfoView_(info: info, keyboardFocus: keyboardFocus);
}

class InfoView_ extends State<InfoView> with TickerProviderStateMixin {
  Info? info;
  bool keyboardFocus;
  InfoView_({
    Key? key,
    required this.info,
    this.keyboardFocus = false,
  });
  bool isLoading = true;
  bool isLoadingMore = false;
  List<Comment> comments = [];
  final messagecontroller = TextEditingController();
  bool showimagesource = false;
  bool showmedia = false;
  bool show_answer = false;
  bool showSelectedMedia = false;
  String media = '';
  String contenu = '';
  final _focusNode = FocusNode();
  Comment replyTo = Comment();
  WidgetCommentState linealComment =
      WidgetCommentState(comment: Comment(), parent: null);
  @override
  void initState() {
    info!.contenu = 'INSCRIPTIONS SUR LES LISTES ÉLECTORALES ' +
        '\n Les descentes se poursuivent du Côté de Garoua Boulai sis au Marché Gado Badjene,  sous la Supervision de Abbo Hassimi Ibrahim PCC . Félicitations à toute l\'équipe mobilisée.' +
        '\n ✔️Le lieu , Hangar Marché de Gado Badjere' +
        '\n ✔️le Jour , Le Mercredi 10 Janvier 2024' +
        '\n ✔️le Nom du PCC , Abbo Hassimi Ibrahim' +
        '\n ✔️le éléments mobilisés, Une voiture 3 personnes, Deux kits ELECAM, et 82 personnes inscrites.' +
        '\n ✔️la Zone Couverte pour les Inscriptions:' +
        '\n Le village de Gado Badjere.' +
        '\n Patrick OBAM' +
        '\n @tout le monde' +
        '\n Nazir Mohammed Nassir Christian Moussima Salvador Ngono Thomas Ekalle Jovial Herve Dzangue Anne Féconde NOAH Thomas Malanga Abdoulaye Mohamadou Sandrine Bayema Nadine Enoumedi Mme Makondo Viviane Sébastien Nkamba Boubakari Massardine Hardaway Yebga Arthur Assam Debora Devos Nkot Aristide Eko\'o Yembel Marcelle Emilie Marc Bakendj Michel Mbenda Bedouka';
    fetchInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showkeyboard() {
    _focusNode.requestFocus();
  }

  void hidekeyboard() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context);
    var themeProvider = ThemeProvider.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        }),
        title: Padding(
          padding: getPadding(left: 100),
          child: Text(
            info!.title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: appStyle.H3(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: BodyHeight() - 105,
            child: ListView(
              children: [
                WidgetInfo(
                  news: NewsEntity(
                    id: info?.id ?? '',
                    title: info?.title ?? '',
                    image: info?.image ?? '',
                    contenu: info?.contenu ?? '',
                    path: info?.path ?? '',
                    time: info?.time ?? 0,
                    likes: info?.likes ?? 0,
                    comments: info?.comments ?? 0,
                    liked: info?.liked ?? false,
                  ),
                  clickable: false,
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Commentaires ',
                        style: appStyle.txtRoboto(
                            size: 18, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.background,
                      ))
                    : Container(
                        padding: getPadding(left: 8, right: 8, bottom: 15),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          for (var index = 0; index < comments.length; index++)
                            WidgetComment(
                              info: comments[index],
                              parent: this,
                            ),
                          /*
                        for(var index=0;index<2;index++)
                          widgetComment(
                            info:Comment(
                              id: index.toString(),
                              userName:  index==1?'Franck':'rogg',
                              contenu: index==1?'Premier hah ahahahah ahahgeah ahgzeghaeahg gahzgegh  agtehga':'2undo',
                              replyUserName: index==1?'rogg':'none',
                            ),
                            parent: this,
                          ),

                         */
                        ])),
                (info!.comments > comments.length &&
                        isLoading == false &&
                        isLoadingMore == false)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                isLoadingMore = true;
                                setState(() {});
                              },
                              child: Text(
                                'Afficher plus ',
                                style: appStyle.H4(
                                    color: Colors.blueGrey, weight: 'bold'),
                              ),
                            )
                          ],
                        ),
                      )
                    : (isLoadingMore)
                        ? Center(
                            child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.background,
                          ))
                        : SizedBox(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              width: double.maxFinite,
              height: showimagesource ? 150 : 0,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  boxShadow: [BoxShadow()],
                  borderRadius: BorderRadius.only(
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
                              Icon(Icons.image),
                              Padding(padding: getPadding(left: 8)),
                              Text(
                                'Gallerie',
                                style: appStyle.H4(),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                        Padding(padding: getPadding(top: 30)),
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
              color: UIColors.primaryAccent,
              height: (show_answer ? 100 : 50) +
                  min(4, (messagecontroller.text.length ~/ 19).toInt()) * 8,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    show_answer
                        ? Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  //setState(() {});
                                  //scrollcontroller.scrollToIndex(getIndexOfmessage(replyTo.id), preferPosition: AutoScrollPosition.begin,duration: Duration(seconds: 1));
                                  //scrollcontroller.highlight(getIndexOfmessage(replyTo.id));
                                  // allMessageWidgetsStates[getIndexOfmessage(replyTo.id)].currentState!.highlight();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    height: 37,
                                    padding: getPadding(
                                        top: 5, left: 10, right: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                      color: UIColors.blueGray100,
                                      border: Border(
                                          left: BorderSide(
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
                                              'Réponse à ' +
                                                  (replyTo.userId == user.id
                                                      ? 'vous même'
                                                      : replyTo.userName),
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  appStyle.txtStream(size: 18),
                                            ),
                                            Padding(
                                                padding: getPadding(left: 10)),
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
                                  padding:
                                      const EdgeInsets.only(top: 12, right: 16),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            replyTo = Comment();
                                            show_answer = false;
                                          });
                                        },
                                        child: Icon(
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
                        : SizedBox(),
                    Padding(
                      padding: getPadding(top: 3, bottom: 15),
                      //padding: MediaQuery.of(context).viewInsets,
                      child: Row(
                        children: [
                          /*
                          showmedia?
                          SizedBox():
                          Transform.rotate(
                            angle: 70,
                            child:
                            IconButton(
                              icon: Icon(Icons.attach_file_outlined ,color: Theme.of(context).primaryColor,size: 30),
                              onPressed: () {
                                showimagesource=!showimagesource;
                                setState(() {});
                              },
                            ),
                          ),
                          showmedia?
                          SizedBox():
                          IconButton(
                            icon: Icon(Icons.camera_alt,color: Theme.of(context).primaryColor,size: 30),
                            onPressed: () {
                              takeImage(ImageSource.camera);
                              showmedia=true;
                              setState(() {});
                            },
                          ),
                           */
                          Container(
                            //height: 40 + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                            //margin: getMargin(left: 10,top: showmedia?7: min(4,(messagecontroller.text.length ~/ 19)) >0 ?7:0),
                            margin: getMargin(left: 10),
                            decoration: BoxDecoration(
                                color: UIColors.blueGray100,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  //height: 40 + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                                  //width: BodyWidth() - (showmedia ? 75:172),
                                  width: BodyWidth() - 75,
                                  margin: getMargin(right: 10),
                                  decoration: BoxDecoration(
                                      color: UIColors.blueGray100,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: TextField(
                                    onChanged: (e) {
                                      setState(() {});
                                    },
                                    controller: messagecontroller,
                                    focusNode: _focusNode,
                                    style: appStyle.H5(),
                                    cursorColor: UIColors.cursorColor,
                                    maxLines: 4,
                                    minLines: 1,
                                    autofocus: keyboardFocus,
                                    decoration: InputDecoration(
                                      hintText: 'Réagir ...',
                                      fillColor: UIColors.edittextFillColor,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: getPadding(bottom: 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                              onPressed: () {
                                show_answer = false;
                                setState(() {});
                                sendReplyTest();
                              },
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
        ],
      ),
    );
  }

  User user = User();

  takeImage(ImageSource imagesource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: imagesource);
    if (file != null) {
      media = file.path ?? '';
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
    var image_extensions = ['JPG', 'PNG', 'GIF', 'WebP', 'BMP', 'WBMP'];
    //print(extension);
    for (var i = 0; i < image_extensions.length; i++)
      if (extension.toLowerCase() == image_extensions[i].toLowerCase())
        return true;
    return false;
  }

  fetchInfo() async {
    user = await AuthApi().getUser().then((value) => value as User);
    print('fetching new infos');
    List<Comment> comments_ = [];
    var datas = [];
    var results;
    await NotificationApi().getInfo(info!.id).then((response) => {
          if (response.statusCode == 200)
            {
              results = json.decode(response.body),
              datas = (results['data'] as Map)['comments'],
              for (var i = 0; i < datas.length; i++)
                {
                  comments_.add(Comment(
                    id: datas[i]["id"],
                    contenu: datas[i]['contenu'],
                    likes: datas[i]['likes'],
                    liked: datas[i]['liked'],
                    userPhoto: datas[i]['userphoto'],
                    userName: datas[i]['username'],
                    replyTo: datas[i]['replyTo'],
                    image: datas[i]['statut'] != '' ? datas[i]['image'] : '',
                    comments: datas[i]['comments'],
                    time: datas[i]['time'],
                  )),
                },
            },
          comments = comments_,
          isLoading = false,
          setState(() {})
        });
    if (keyboardFocus) showkeyboard();
  }

  sendReply() async {
    replyTo.contenu = messagecontroller.text;
    if (messagecontroller.text != '') {
      await NotificationApi()
          .commentInfo(info!.id, replyTo)
          .then((response) => {
                if (response.statusCode == 200)
                  {
                    replyTo.id =
                        (json.decode(response.body)['data'] as Map)['id'],
                    if (linealComment.parent == null)
                      {
                        comments.add(replyTo),
                      }
                    else
                      {
                        linealComment.replies.add(replyTo),
                        linealComment.setState(() {})
                      },
                    linealComment =
                        WidgetCommentState(comment: Comment(), parent: null),
                    messagecontroller.text = '',
                    FocusManager.instance.primaryFocus?.unfocus(),
                    setState(() {})
                  }
                else
                  {
                    print(response.body),
                    toast('Commentaire non envoyé! Vous etes hors connexion')
                  }
              });
    }
  }

  sendReplyTest() async {
    replyTo.contenu = messagecontroller.text;
    if (messagecontroller.text != '') {
      replyTo.id = comments.length.toString();
      if (linealComment.parent == null) {
        comments.add(new Comment(
            id: comments.length.toString(),
            info: info!.id,
            contenu: messagecontroller.text,
            replyTo: 'none',
            replyUserName: 'none',
            lineal: 'none',
            userId: user.id,
            userName: user.nom + ' ' + user.prenom,
            userPhoto: user.photo,
            time: DateTime.now().millisecondsSinceEpoch ~/ 1000));
      } else {
        linealComment.replies.add(new Comment(
            id: comments.length.toString(),
            info: info!.id,
            contenu: messagecontroller.text,
            replyTo: replyTo.replyTo,
            lineal: linealComment.comment!.id,
            replyUserName: replyTo.userName,
            userId: user.id,
            userName: user.nom + ' ' + user.prenom,
            userPhoto: user.photo,
            time: DateTime.now().millisecondsSinceEpoch ~/ 1000));
        linealComment.comment!.comments++;
        linealComment.setState(() {});
      }
      linealComment = WidgetCommentState(comment: Comment(), parent: null);
      messagecontroller.text = '';
      info!.comments++;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    }
  }
}
