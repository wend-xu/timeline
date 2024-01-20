import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/config/logger_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/provider/hot_key/multiline_input_action_provider.dart';
import 'package:timeline/cn/wendx/provider/hot_key/send_action_provider.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';
import 'package:window_manager/window_manager.dart';

Future hotkeyInit() async {
  StaticLogger.i("开始注册全局快捷键");
  var hotKeyManager = HotKeyManager.instance;

  await hotKeyManager.unregisterAll();
  var configService = GetIt.instance.get<SysConfigService>();

  var hotKeyCallDisplay = _fromConfig(await configService.read(Const.hotKeyCallDisplay));
  hotKeyManager.register(hotKeyCallDisplay,keyDownHandler: (hotKey) async{
    if(await windowManager.isFocused()){
      windowManager.hide();
    }else{
      await windowManager.show();
      await windowManager.focus();
    }
  });
  StaticLogger.i("完成全局快捷键注册");


}

// app 内快捷键，部分需要跟状态结合，需在provider初始化完成后执行
Future hotkeyInitInApp(BuildContext context)async{
  var configService = GetIt.instance.get<SysConfigService>();

  StaticLogger.i("开始局部快捷键注册");
  var hotKyeMultilineInput = _fromConfig(await configService.read(Const.hotKeyMultiLineInput));
  hotKeyManager.register(hotKyeMultilineInput,keyUpHandler: (hotkey) async {
    var sendActionProvider = Provider.of<SendActionProvider>(context,listen:false );
    sendActionProvider.newline();
  });

  var send = _fromConfig(await configService.read(Const.hotKeySend));
  hotKeyManager.register(send,keyUpHandler: (hotkey) async{
    var sendActionProvider = Provider.of<SendActionProvider>(context,listen:false );
    sendActionProvider.send();
  });
  StaticLogger.i("完成局部快捷键注册");
}

HotKey _fromConfig(SysConfig sysConfig){
  return HotKey.fromJson(sysConfig.mapValue());
}

