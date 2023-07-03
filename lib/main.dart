import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:timeline/cn/wendx/config/service_config.dart';
import 'package:timeline/cn/wendx/config/windows_manager_config.dart';
import 'package:timeline/cn/wendx/route/name_route_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'cn/wendx/config/repository_config.dart';


void main() async {
  /// WidgetsFlutterBinding 将是 Widget 架构和 Flutter Engine 连接的核心桥梁，
  /// 也是整个 Flutter 应用层的核心。通过 ensureInitialized() 方法我们可以得到一个全局单例
  /// 部分依赖于原生功能需要在完成WidgetsFlutterBinding.ensureInitialized()后才能正常调用
  WidgetsFlutterBinding.ensureInitialized();

  /// 打开数据库并加载 repository
  /// sqlite repository 和 repository 是两层抽象
  /// 并且注册 IOC 容器使用的是 repository
  /// 后续需要更换为 本地sqlite+远程同步或远程同步的模式，
  /// 只需要重新实现 repository 层后修改初始注册方法
  await openSqliteAndRegisterRepository();

  /// 注册服务层
  await registerService();

  /// 初始化窗口
  await initWindows();

  await hotKeyManager.unregisterAll();


  String osName = Platform.operatingSystem;

  ///   {"btn_1":8589935090 ,"brn_2":4294967309 }
  String hotkey_multiline = '''
  {"btn_1":${KeyCode.shift.keyId} ,"brn_2":${KeyCode.enter.keyId} }
  ''';
  print(hotkey_multiline);

  Map<String,dynamic> hotkey = {"btn_1":KeyCode.shift.keyId,"btn_2":KeyCode.enter.keyId};
  var encode = json.encode(hotkey);
  print(encode);
  Map<String, dynamic> map = json.decode(encode);

  if(osName == "macos"){
    HotKeyManager.instance.register(
      HotKey(
        KeyCode.keyT,
        modifiers: [KeyModifier.control,KeyModifier.shift],
        scope: HotKeyScope.system
      ),
      keyDownHandler: (hotKey)async {
        if(await windowManager.isFocused()){
          windowManager.hide();
        }else{
          await windowManager.show();
          await windowManager.focus();
        }
      }
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeline',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: R.timeline,
      routes:R.routes() ,
        builder: (context, widget) {
          return MediaQuery(
            //设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
    );
  }
}
