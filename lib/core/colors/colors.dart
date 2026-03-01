import 'dart:ui';
import 'package:flutter/material.dart';

class UIColors  {
  static Color primaryColor = fromHex('#EDA2F5');
  static Color primaryDark = fromHex('#231824');
  static Color primaryAccent = Colors.white;
  static Color bigbutton = fromHex('#03A9F4');
  static Color edittextFillColor = fromHex('#BED4CC');
  static Color boxFillColor = fromHex('#3B3B3B42');
  static Color boxStrokeColor = primaryDark;
  static Color warningColor = fromHex('#F19101');
  static Color errorColor = fromHex('BC0000');
  static Color successColor = primaryColor;
  static Color labelColor = primaryColor;
  static Color hintTextColor = fromHex('#7C8D86');
  static Color cursorColor = primaryDark;
  static Color blueGray100 = fromHex('#d9d9d9');
  static Color txtInactive = Colors.black26;
}

class UIColorsDark  {
  static Color primaryColor = fromHex('#EDA2F5');
  static Color primaryDark = Colors.white;
  static Color primaryAccent = Colors.black54;
  static Color edittextFillColor = fromHex('#BED4CC');
  static Color boxFillColor = fromHex('#939C98');
  static Color boxStrokeColor = primaryDark;
  static Color warningColor = fromHex('#F19101');
  static Color errorColor = fromHex('BC0000');
  static Color successColor = primaryColor;
  static Color labelColor = primaryColor;
  static Color hintTextColor = fromHex('#7C8D86');
  static Color cursorColor = primaryDark;
  static Color blueGray100 = fromHex('#d9d9d9');
  static Color txtInactive = Colors.white54;
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}