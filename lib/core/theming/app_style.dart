import 'package:flutter/material.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/utils/size_utils.dart';

class AppStyle {
  final ThemeData? theme;

  AppStyle({required this.theme});

  static AppStyle of(BuildContext context) {
    return AppStyle(theme: Theme.of(context));
  }

  TextStyle txtError = TextStyle(
    fontSize: getFontSize(
      13,
    ),
    color: Colors.red,
    fontFamily: 'Arimo Hebrew Subset',
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  TextStyle txtWarning = TextStyle(
    color: UIColors.warningColor,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Arimo Hebrew Subset',
    fontWeight: FontWeight.w600,
  );

  double getDeviceDpi() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    //log('Screen DPR : ' + data.devicePixelRatio.toString());
    return data.devicePixelRatio;
  }

  TextStyle txtAclonica({double size=14,String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Aclonica',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle txtStream({double size=14,String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Stream',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle txtArimoHebrewSubset({double size=14,String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Arimo Hebrew Subset',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle txtRoboto({double size=14,String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Roboto',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle txtDefault({double size=14,String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H1({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 34,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H2({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 28,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H3({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 24,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H4({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 18,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H5({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 16,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H6({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 14,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H7({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 12,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

  TextStyle H8({String weight='Regular',Color? color}){
    return TextStyle(
      color: color ?? theme!.colorScheme.onSurface,
      fontSize: 10,
      fontFamily: 'Sk-Modernist',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

}

