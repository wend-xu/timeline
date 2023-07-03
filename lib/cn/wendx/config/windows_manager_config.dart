import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/repo/sys_config_repository.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';
import 'package:window_manager/window_manager.dart';

Future initWindows() async {

  /// 此处应该是通过ffi调用了原生方法
  await windowManager.ensureInitialized();

  SysConfigService sysConfigService = GetIt.instance.get<SysConfigService>();

  SysConfig winSize = await sysConfigService.read(Const.winSize);


  /// 设置窗口选项
  WindowOptions windowOptions = const WindowOptions(
      size: Size(750, 850),
      minimumSize: Size(600, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      // title: "这是个标题",
      alwaysOnTop: false);

  /// 等待准备展示后执行的逻辑
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
