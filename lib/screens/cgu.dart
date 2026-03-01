import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/discussion.dart';
import '../model/user.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_message.dart';
import '../../core/app_export.dart';

bool light=false;
class CGU extends StatefulWidget{
  CGU({Key? key,
  })
      : super(
    key: key,
  );
  @override
  State<CGU> createState() => CGUState();
}
class CGUState extends State<CGU>  with TickerProviderStateMixin{
  User? user;
  bool loading = true;
  var controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://badoo.com/fr/terms#fr/terms'));
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: 'CGU'),
      body: WebViewWidget(controller: controller),
    );
  }

  load() async{
    loading = true;
    user = await AuthApi().getUser().then((value) => value);

  }



}