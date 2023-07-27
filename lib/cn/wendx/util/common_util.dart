import 'package:flutter/material.dart';

class CommonUtil {

  CommonUtil._();

  static TextStyle textColorBaseBg(BuildContext buildContext,
      {Color lightColor = Colors.white60, Color darkColor = Colors.black45,TextStyle? originStyle}) {
    var primaryColor = Theme.of(buildContext).colorScheme.background;
    Color color =  primaryColor.computeLuminance() > 0.5?darkColor:lightColor;
    return originStyle == null?TextStyle(color:color):originStyle.copyWith(color: color);
  }
}