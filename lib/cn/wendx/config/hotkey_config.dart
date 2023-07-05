import 'package:get_it/get_it.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:timeline/cn/wendx/config/logger_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';
import 'package:window_manager/window_manager.dart';

Future hotkeyInit() async {
  StaticLogger.i("开始注册快捷键");
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
}

HotKey _fromConfig(SysConfig sysConfig){
  return HotKey.fromJson(sysConfig.mapValue());
}

