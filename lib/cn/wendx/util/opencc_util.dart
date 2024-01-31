import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_opencc_ffi/flutter_opencc_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeline/cn/wendx/config/logger_helper.dart';

import 'common_util.dart';

class OpenccUtil{

  final List<String> types = ["s2t", "t2s", "s2hk", "hk2s", "s2tw", "tw2s", "s2twp", "tw2sp", "t2hk", "hk2t", "t2jp", "jp2t", "t2tw", "tw2t"];
  late final Map<String, Converter> converters = {};

  static OpenccUtil? _instance ;

  OpenccUtil._(){
    _copyAssets().then((dataDir){
      for (String type in types) {
        converters[type] = createConverter(kIsWeb ? type : '$dataDir/$type.json');
      }
    });
  }

  static init(){
    _instance = OpenccUtil._();
  }


  static String t2s(String traditional){
    return _instance!.converters["t2s"]!.convert(traditional);
  }

  /// 归一化字符串
  ///   繁体 -> 简体
  ///   全角 -> 半角
  ///   大写 -> 小写
  static String normalizeText(String text){
    var halfWidthStr = CommonUtil.fullWidthToHalfWidth(text.toLowerCase());
    var t2sStr = t2s(halfWidthStr);
    StaticLogger.i("字符串归一化，原始字符串： \n $text 结果： \n $t2sStr");
    return t2sStr;
  }

  Future<String> _copyAssets() async {
    if(kIsWeb) {
      return '';
    }
    Directory dir = await getApplicationSupportDirectory();
    Directory openccDir = Directory('${dir.path}/opencc');
    if (openccDir.existsSync()) {
      return openccDir.path;
    }
    Directory tmp = Directory('${dir.path}/_opencc');
    if (tmp.existsSync()) {
      tmp.deleteSync(recursive: true);
    }
    tmp.createSync(recursive: true);
    List<String> assets = (await rootBundle.loadString('assets/opencc_assets.txt', cache: false)).split('\n');
    for (String f in assets) {
      File dest = File('${tmp.path}/$f');
      dest.createSync(recursive: true);
      ByteData data = await rootBundle.load('assets/opencc/$f');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      dest.writeAsBytesSync(bytes);
    }
    tmp.renameSync(openccDir.path);
    return openccDir.path;
  }
}