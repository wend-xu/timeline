import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/config/hotkey_config.dart';
import 'package:timeline/cn/wendx/config/service_config.dart';
import 'package:timeline/cn/wendx/config/windows_manager_config.dart';
import 'package:timeline/cn/wendx/provider/cont_area_provider.dart';
import 'package:timeline/cn/wendx/provider/func_area_provider.dart';
import 'package:timeline/cn/wendx/provider/hot_key/send_action_provider.dart';
import 'package:timeline/cn/wendx/provider/input_state_provider.dart';
import 'package:timeline/cn/wendx/provider/navi_provider.dart';
import 'package:timeline/cn/wendx/provider/theme_provider.dart';
import 'package:timeline/cn/wendx/route/name_route_manager.dart';
import 'package:timeline/cn/wendx/util/opencc_util.dart';

import 'cn/wendx/config/repository_config.dart';
import 'cn/wendx/config/sys_constant.dart';

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

  /// 注册快捷键
  await hotkeyInit();

  /// todo 后续调整位置
  // var openccUtil = OpenccUtil();
  // GetIt.instance.registerSingleton<OpenccUtil>(openccUtil);
  OpenccUtil.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      primarySwatch: Colors.blueGrey,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(fontSize: 12),
        hintStyle: TextStyle(fontSize: 12)
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(themeData)),
        ChangeNotifierProvider<FuncAreaProvider>(
            create: (_) => FuncAreaProvider(Const.naviTimeline)),
        ChangeNotifierProvider<NaviProvider>(create: (_) => NaviProvider()),
        // todo 此处放入初始化应该跟FuncAreaProvider有关联的
        ChangeNotifierProvider<ContAreaProvider>(create: (_) => ContAreaProvider(Const.contTimelineIndex)),
        ChangeNotifierProvider<SendActionProvider>(create: (_) => SendActionProvider()),
        ChangeNotifierProvider<InputStateProvider>(create: (_) => InputStateProvider()),
      ],
      builder: (context, child) {
        return _materialProviderWrapper(context);
      },
    );
  }

  Widget _materialProviderWrapper(BuildContext buildContext) {
    return _material(buildContext);
  }

  Widget _material(buildContext) {
    return MaterialApp(
        title: 'Timeline',
        theme: Provider.of<ThemeProvider>(buildContext).themeData,
        navigatorObservers: [FlutterSmartDialog.observer],
        initialRoute: R.layoutPage,
        routes: R.routes(),
        builder: FlutterSmartDialog.init(
          builder: (context, widget) {
            // 初始化局内快捷键
            hotkeyInitInApp(context);
            return Material(
              child: MediaQuery(
                //设置文字大小不随系统设置改变
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: widget!,
              ),
            );
          },
        ));
  }

}
