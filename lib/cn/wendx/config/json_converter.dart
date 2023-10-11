
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeline/cn/wendx/util/date_utils.dart';

/// 时间戳格式转换
class DateTimeEpochConverter implements JsonConverter<DateTime, int> {
  const DateTimeEpochConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(timestamp_is_second(json)?timestamp_second_to_milli(json):json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

/// 图标数据转换
class IconDataConverter implements JsonConverter<IconData,Map<String,dynamic>>{
  static const String _codePoint = "codePoint";
  static const String _fontFamily = "fontFamily";
  static const String _fontPackage = "fontPackage";
  static const String _matchTextDirection = "matchTextDirection";


  const IconDataConverter();

  @override
  IconData fromJson(Map<String,dynamic> json) {
    return IconData(
      json[_codePoint],
      fontFamily:json[_fontFamily],
      fontPackage:json[_fontPackage],
      matchTextDirection:json[_matchTextDirection],
    );
  }

  @override
  Map<String,dynamic> toJson(IconData icon) {
    return {
      _codePoint:icon.codePoint,
      _fontFamily:icon.fontFamily,
      _fontPackage:icon.fontPackage,
      _matchTextDirection:icon.matchTextDirection,
    };
  }

}