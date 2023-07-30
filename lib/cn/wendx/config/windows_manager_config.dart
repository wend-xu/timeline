import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';
import 'package:window_manager/window_manager.dart';

Future initWindows() async {
  /// 此处应该是通过ffi调用了原生方法
  await windowManager.ensureInitialized();

  SysConfigService sysConfigService = GetIt.instance.get<SysConfigService>();

  var winSize = await sysConfigService.read(Const.winSize);
  var winMinSize = await sysConfigService.read(Const.winMinSize);
  var winOnTop = await sysConfigService.read(Const.winOnTop);

  /// 设置窗口选项
  WindowOptions windowOptions = WindowOptions(
      size: createSizeFomConfig(winSize),
      minimumSize: createSizeFomConfig(winMinSize),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
      // title: "这是个标题",
      alwaysOnTop: configIsEnable(winOnTop));

  /// 等待准备展示后执行的逻辑
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Size createSizeFomConfig(SysConfig sysConfig) {
  Map<String, dynamic> decode = json.decode(sysConfig.value);
  double width = decode[Const.width] as double;
  double height = decode[Const.height] as double;
  return Size(width, height);
}

bool configIsEnable(SysConfig sysConfig) {
  return Able.get(sysConfig.value) == Const.enable;
}
