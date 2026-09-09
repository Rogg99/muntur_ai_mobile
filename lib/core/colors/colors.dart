import 'dart:ui';
import 'package:flutter/material.dart';

// Brand palette, from the AUTOSYNX logotype (assets/images/logo AUTOSYNX FIN-01.jpg.jpeg):
// purple #7B2CBF, navy #0C2745, white #FFFFFF.
class UIColors  {
  static Color primaryColor = fromHex('#7B2CBF');
  static Color primaryDark = fromHex('#0C2745');
  static Color primaryAccent = Colors.white;
  static Color bigbutton = fromHex('#7B2CBF');
  static Color edittextFillColor = fromHex('#EFE7FA');
  static Color boxFillColor = fromHex('#3B3B3B42');
  static Color boxStrokeColor = primaryDark;
  static Color warningColor = fromHex('#F19101');
  static Color errorColor = fromHex('BC0000');
  static Color successColor = fromHex('#00C48C');
  static Color labelColor = primaryColor;
  static Color hintTextColor = fromHex('#7C8D96');
  static Color cursorColor = primaryDark;
  static Color blueGray100 = fromHex('#d9d9d9');
  static Color txtInactive = Colors.black26;
}

class UIColorsDark  {
  static Color primaryColor = fromHex('#A566E0');
  static Color primaryDark = Colors.white;
  static Color primaryAccent = fromHex('#0C2745');
  static Color bigbutton = fromHex('#A566E0');
  static Color edittextFillColor = fromHex('#13315B');
  static Color boxFillColor = fromHex('#939C98');
  static Color boxStrokeColor = primaryDark;
  static Color warningColor = fromHex('#F7B84B');
  static Color errorColor = fromHex('EF5350');
  static Color successColor = fromHex('#1EE0A0');
  static Color labelColor = primaryColor;
  static Color hintTextColor = fromHex('#9AA7B8');
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