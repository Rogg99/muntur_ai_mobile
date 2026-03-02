/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Orange-money.jpg
  AssetGenImage get orangeMoney => const AssetGenImage('assets/images/Orange-money.jpg');

  /// File path: assets/images/avatar.jpg
  AssetGenImage get avatar => const AssetGenImage('assets/images/avatar.jpg');

  /// File path: assets/images/bot_img.png
  AssetGenImage get botImg => const AssetGenImage('assets/images/bot_img.png');

  /// File path: assets/images/discussion_wallpaper1.jpg
  AssetGenImage get discussionWallpaper1 => const AssetGenImage('assets/images/discussion_wallpaper1.jpg');

  /// File path: assets/images/discussion_wallpaper2.jpg
  AssetGenImage get discussionWallpaper2 => const AssetGenImage('assets/images/discussion_wallpaper2.jpg');

  /// File path: assets/images/discussion_wallpaper4.jpg
  AssetGenImage get discussionWallpaper4 => const AssetGenImage('assets/images/discussion_wallpaper4.jpg');

  /// File path: assets/images/empty.jpg
  AssetGenImage get empty => const AssetGenImage('assets/images/empty.jpg');

  /// File path: assets/images/english_flag.png
  AssetGenImage get englishFlag => const AssetGenImage('assets/images/english_flag.png');

  /// File path: assets/images/french_flag.png
  AssetGenImage get frenchFlag => const AssetGenImage('assets/images/french_flag.png');

  /// File path: assets/images/garageIcon.png
  AssetGenImage get garageIcon => const AssetGenImage('assets/images/garageIcon.png');

  /// File path: assets/images/img_ellipse.png
  AssetGenImage get imgEllipse => const AssetGenImage('assets/images/img_ellipse.png');

  /// File path: assets/images/img_user_white_a700.svg
  String get imgUserWhiteA700 => 'assets/images/img_user_white_a700.svg';

  /// File path: assets/images/logo_dark.png
  AssetGenImage get logoDark => const AssetGenImage('assets/images/logo_dark.png');

  /// File path: assets/images/logo_white.png
  AssetGenImage get logoWhite => const AssetGenImage('assets/images/logo_white.png');

  /// File path: assets/images/map.png
  AssetGenImage get map => const AssetGenImage('assets/images/map.png');

  /// File path: assets/images/momo2.png
  AssetGenImage get momo2 => const AssetGenImage('assets/images/momo2.png');

  /// List of all assets
  List<dynamic> get values => [
        orangeMoney,
        avatar,
        botImg,
        discussionWallpaper1,
        discussionWallpaper2,
        discussionWallpaper4,
        empty,
        englishFlag,
        frenchFlag,
        garageIcon,
        imgEllipse,
        imgUserWhiteA700,
        logoDark,
        logoWhite,
        map,
        momo2
      ];
}

class Assets {
  Assets._();

  static const String config = 'assets/config.json';
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const String notifications = 'assets/notifications.dar';

  /// List of all assets
  List<String> get values => [config, notifications];
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
