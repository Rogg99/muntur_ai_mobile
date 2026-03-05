import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/widget_comment.dart';

import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Comment.dart';

class WidgetReply extends StatefulWidget {
  final Comment? info;
  final WidgetCommentState? parent;

  const WidgetReply({
    super.key,
    required this.info,
    required this.parent,
  });

  @override
  State<WidgetReply> createState() => WidgetReplyState();
}

class WidgetReplyState extends State<WidgetReply> {
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final comment = widget.info;
    final parent = widget.parent;

    if (comment == null) return const SizedBox.shrink();

    return Container(
      padding: getPadding(top: 15),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: getPadding(left: 25)),

              // ── Avatar ─────────────────────────────────────────
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Center(
                  child: comment.userPhoto != 'none'
                      ? Container(
                          margin: getMargin(all: 8),
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            color: UIColors.boxFillColor,
                            image: DecorationImage(
                              image: NetworkImage(
                                  'http://muntur.steps4u.net/api/muntur${comment.userPhoto}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.account_circle_rounded,
                          size: 32,
                          color: Colors.grey,
                        ),
                ),
              ),

              // ── Contenu ────────────────────────────────────────
              Container(
                padding: getPadding(left: 5, top: 5, right: 5, bottom: 5),
                margin: getMargin(right: 5, left: 5),
                width: ((MediaQuery.of(context).size.width) * 0.8) - 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: UIColors.blueGray100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Nom
                    Row(
                      children: [
                        Text(
                          '${comment.userName} > ${comment.replyUserName}',
                          maxLines: 1,
                          style: appStyle.txtStream(size: 18, weight: 'bold'),
                        ),
                      ],
                    ),

                    // Image (si présente)
                    if (comment.image.isNotEmpty &&
                        comment.image.toLowerCase() != 'none')
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(comment.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Texte avec copie longpress
                    GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: comment.contenu))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('message copié dans le presse papier'),
                            ),
                          );
                        });
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Text(
                            comment.contenu,
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: appStyle.txtStream(size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(padding: getPadding(top: 5)),

          // ── Actions ────────────────────────────────────────────
          Padding(
            padding: getPadding(left: 32),
            child: Row(
              children: [
                Padding(padding: getPadding(left: 21 + 20)),
                Text(
                  _getDuree(comment.time.toDouble()),
                  style: appStyle.H5(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: getPadding(left: 30)),

                // Répondre
                GestureDetector(
                  onTap: () {
                    if (parent == null) return;
                    parent.parent?.linealComment = parent;
                    parent.parent?.replyTo.lineal = parent.comment?.id ?? '';
                    parent.parent?.replyTo.replyTo = comment.id;
                    parent.parent?.replyTo.userName = comment.userName;
                    parent.parent?.replyTo.userId = comment.userId;
                    parent.parent?.show_answer = true;
                    parent.parent?.showkeyboard();
                    parent.parent?.linealComment = parent;
                    parent.parent?.setState(() {});
                  },
                  child: Text(
                    'Répondre',
                    style: appStyle.H5(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // Compteur likes
                Text(
                  comment.likes.toString(),
                  style: appStyle.H5(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Bouton like (local uniquement — pas d'API)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (comment.liked == true) {
                        comment.liked = false;
                        comment.likes -= 1;
                      } else {
                        comment.liked = true;
                        comment.likes += 1;
                      }
                    });
                  },
                  child: Icon(
                    comment.liked == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: comment.liked == true ? Colors.red : null,
                    size: 20,
                  ),
                ),

                Padding(padding: getPadding(left: 10)),
              ],
            ),
          ),

          Padding(padding: getPadding(top: 10)),
        ],
      ),
    );
  }

  String _getDuree(double time) {
    final double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    final double periode = actual - time;
    if (periode / 3600 < 1) return '${(periode / 60).floor()} min';
    if (periode / 3600 < 24) return '${(periode / 3600).floor()} h';
    return '${(periode / (3600 * 24)).floor()} j';
  }
}
