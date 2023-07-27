import 'package:json_annotation/json_annotation.dart';

typedef Const = SystemConstant;

class SystemConstant {
  static const int notDel = 0;

  static const int del = 1;

  static const Able enable = Able.enable;

  static const Able disable = Able.disable;

  static const DesktopNaviAreaWrapper desktopNaviArea = DesktopNaviAreaWrapper();

  static const String lang = "lang";

  static const String winOnTop =  "winOnTop ";

  static const String winSize = "winSize";

  static const String winMinSize = "winMinSize";

  static const String hotKey = "hotKey";

  static const String hotKeySend = "hotKeySend";

  static const String hotKeyMultiLineInput = "hotKeyMultiLineInput";

  static const String hotKeyCallDisplay = "hotKeyCallDisplay";

  static const String openTray = "openTray";

  static const String width = "width";

  static const String height = "height";

  static const String zh = "zh";

  static const String en = "en";

  static const String naviGroup = "naviGroup ";

  static const String naviTimeline = "naviTimeline";

  static const String naviSetting = "naviSetting ";

  static const String naviLoading = "naviLoading";

  static const String naviRefresh = "naviRefresh";

  static const String naviNothing = "naviNothing";

  SystemConstant._();
}

@JsonEnum(valueField: 'key')
enum Able{
  enable("enable"),disable("disable");

  final String key;

  const Able(this.key);

  /// 获取不到返回 [disable]
  static Able get(String key){
    return Able.values.firstWhere((el) => el.key == key, orElse: () => disable);
  }
}

@JsonEnum()
enum DesktopNaviArea{
  // leading
  destination,trailing;
}

class DesktopNaviAreaWrapper{
   // final DesktopNaviArea leading = DesktopNaviArea.leading;

   final DesktopNaviArea destination = DesktopNaviArea.destination;

   final DesktopNaviArea trailing  = DesktopNaviArea.trailing;

   const DesktopNaviAreaWrapper();
}
