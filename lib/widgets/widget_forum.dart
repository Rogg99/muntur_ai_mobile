import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/utils/dateUtils.dart';

class WidgetForum extends StatefulWidget {
  DiscussionModel? disc;
  WidgetForum({
    super.key,
    required this.disc,
  });

  @override
  State<StatefulWidget> createState() => WidgetForumState();
}

class WidgetForumState extends State<WidgetForum> {
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
    final AppLocalizations translator = AppLocalizations.of(context)!;
    return GestureDetector(
        onTap: () async {
          // var usr = await API.getUI_user().then((value) => value[0]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatView(
                        disc: widget.disc,
                      )));
        },
        child: Container(
          padding: getPadding(all: 10),
          width: double.infinity,
          child: Row(
            children: [
              if (widget.disc!.photo.startsWith('http'))
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: ConstantsProvider.getColorFromLetter(
                        context, widget.disc!.title.substring(0, 1)),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.disc!.photo,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                      child: Text(
                        widget.disc!.title.substring(0, 1).toUpperCase(),
                        style: appStyle.H3(weight: 'bold', color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        widget.disc!.title.substring(0, 1).toUpperCase(),
                        style: appStyle.H3(weight: 'bold', color: Colors.white),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: ConstantsProvider.getColorFromLetter(
                        context, widget.disc!.title.substring(0, 1)),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Center(
                    child: Text(
                      widget.disc!.title.substring(0, 1).toUpperCase(),
                      style: appStyle.H3(weight: 'bold', color: Colors.white),
                    ),
                  ),
                ),
              Container(
                padding: getPadding(left: 10, right: 10),
                width: size.width - 150,
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
                    Padding(padding: getPadding(top: 5)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.disc!.last_writer == (widget.disc!.initiateur)
                            ? '${translator.you} : ${widget.disc!.last_message}'
                            : widget.disc!.last_message,
                        style: appStyle
                            .H6(
                                color: widget.disc!.unreadCount > 0
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.grey)
                            .copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
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
                      getLocalizedDate(widget.disc!.last_date,
                          Localizations.localeOf(context).languageCode),
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
}
