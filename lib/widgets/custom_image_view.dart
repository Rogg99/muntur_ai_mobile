// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../core/theming/app_style.dart';
import 'loading.dart';
import 'loading_image.dart';


class CustomImageView extends StatefulWidget{
  String? url;
  double? height;
  double? width;
  String? asset;
  BoxFit? fit;
  CustomImageView({
    Key? key,
    this.url,
    this.height,
    this.width,
    this.asset,
    this.fit=BoxFit.cover,
  }) : super(
    key: key,
  );

  @override
  State<CustomImageView> createState() => CustomImageView_(asset:asset,url: url,height: height,fit: fit,width: width);
}

class CustomImageView_ extends State<CustomImageView> {
  String? url;
  String? asset;
  double? height;
  double? width;
  BoxFit? fit;

  CustomImageView_({
    this.url,
    this.asset,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });
  late VideoPlayerController controller;
  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    if (asset!=null){
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(
              asset!,),
              fit: BoxFit.cover,
            )
        ),
      );

    }
     else if(isVideo(url!.split('.').last)) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url!))
      ..initialize().then((_) {
        controller.play();
        setState(() {});
      });
      return Container(
          height: height,
          width: width,
          child: VideoPlayer(controller)
      );
    }
    else
      return CachedNetworkImage(
        imageUrl: 'http://munturai.steps4u.net/m/omc/'+url!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
            ),
          ),
        ),
        height: height,
        width: width,
        placeholder: (context, url) => Center(child: Loading()),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
    );

  }
  bool isVideo(String extension){
    var image_extensions=['MP4', 'avi', 'ogg'];
    for(var i=0;i<image_extensions.length;i++)
      if(extension == image_extensions[i].toLowerCase())
        return true;
    return false;
  }

}
