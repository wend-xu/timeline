import 'package:flutter/material.dart';

class CommonUtil {
  CommonUtil._();

  static TextStyle textColorBaseBg(BuildContext buildContext,
      {Color lightColor = Colors.white60,
      Color darkColor = Colors.black45,
      TextStyle? originStyle}) {
    var primaryColor = Theme.of(buildContext).colorScheme.background;
    Color color =
        primaryColor.computeLuminance() > 0.5 ? darkColor : lightColor;
    return originStyle == null
        ? TextStyle(color: color)
        : originStyle.copyWith(color: color);
  }

  // 定义一个函数，将一个全角字符转为半角字符
  static String fullWidthToHalfWidthChar(String char) {
    // 获取字符的Unicode编码
    int code = char.codeUnitAt(0);

    // 如果字符是全角空格，将其转为半角空格
    if (code == 0x3000) {
      return ' ';
    }

    // 如果字符是其他全角字符，将其编码减去0xFEE0，得到对应的半角字符
    if (code >= 0xFF01 && code <= 0xFF5E) {
      return String.fromCharCode(code - 0xFEE0);
    }

    // 如果字符不是全角字符，直接返回原字符
    return char;
  }

// 定义一个函数，将一个包含全角字符的字符串转为半角字符的字符串
  static String fullWidthToHalfWidth(String str) {
    // 使用字符串的split方法，将字符串分割为单个字符的列表
    List<String> chars = str.split('');

    // 使用列表的map方法，对每个字符调用全角转半角的函数，得到一个新的列表
    List<String> halfWidthChars = chars.map(fullWidthToHalfWidthChar).toList();

    // 使用列表的join方法，将新的列表拼接为一个字符串，返回结果
    return halfWidthChars.join('');
  }
}
