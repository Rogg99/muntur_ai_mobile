import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/discussion.dart';
import 'package:munturai/model/message.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/services/api/helper.dart';
import '../model/user.dart';
import 'loading_image.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/model/discussion.dart';

class WidgetDiscussion extends StatefulWidget {
  DiscussionModel? disc;
  WidgetDiscussion({
    super.key,
    required this.disc,
  });

  @override
  State<StatefulWidget> createState() => WidgetDiscussionState();
}

class WidgetDiscussionState extends State<WidgetDiscussion> {
  User user = User();
  bool load = true;

  @override
  void initState() {
    //syncDisc();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return GestureDetector(
        onTap: () async {
          // var usr = await API.getUI_user().then((value) => value[0]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatView(
                        disc: widget.disc != null
                            ? Discussion(
                                id: widget.disc!.id,
                                title: widget.disc!.title,
                                initiateur: widget.disc!.initiateur,
                                interlocuteur: widget.disc!.interlocuteur,
                                last_message: widget.disc!.last_message,
                                last_date: widget.disc!.last_date,
                                last_writer: widget.disc!.last_writer,
                                photo: widget.disc!.photo,
                                type: widget.disc!.type,
                                last_check: widget.disc!.last_check,
                              )
                            : null,
                      )));
        },
        child: Container(
          padding: getPadding(all: 10),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                padding: getPadding(left: 10, right: 10),
                width: size.width - 100,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.disc!.title,
                        style: appStyle.H5(
                            weight: 'bold',
                            color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      getDate(widget.disc!.last_date),
                      style: appStyle.txtDefault(
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  String getDate(String time) {
    String duree = '';
    Duration periode = DateTime.now().difference(DateTime.parse(time));
    if (periode.inSeconds / 3600 < 1) {
      duree = '${(periode.inSeconds / 60).floor()} min';
    } else if (periode.inSeconds / 3600 < 24) {
      duree = DateTime.parse(time).format('kk:mm');
    } else {
      duree = DateTime.parse(time).format('dd/MM');
    }
    return duree;
  }
}
