import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/repo/sqliite_repository.dart';
import 'package:timeline/cn/wendx/repo/sys_config_repository.dart';

class SysConfigRepositoryImpl extends SysConfigRepository
    with SqliteRepository, IocRegister<SysConfigRepository> {
  static const String _tableName = "sys_config";

  final Logger _log = Logger();

  @override
  void register(SysConfigRepository instance) {
    GetIt.instance.registerSingleton<SysConfigRepository>(instance);
  }

  @override
  void upgradeSqlScriptRegister(OnVersionSqlScriptHolder upgradeHolder) {
    upgradeHolder.onVersion(2, (db, oldVersion, newVersion) {
      db.execute('''
 CREATE TABLE $_tableName (	
	id INTEGER PRIMARY KEY,
	key TEXT unique,
	value TEXT,
	pid int default 0,
	level int default 1,
	sort int default 0,
	extras Text default "{}",
	description Text default "",
	createTime DATETIME,
	modifyTime DATETIME default CURRENT_TIMESTAMP,
	delStatus INT DEFAULT 0
);
      ''');

      /// 默认语言
      db.insert(_tableName,
          SysConfig.create(Const.lang, Const.zh, description: "系统语言").toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 窗口是否置顶
      db.insert(
          _tableName,
          SysConfig.create(Const.winOnTop, Const.disable,
                  description: "窗口是否启用置顶，默认为false")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 窗口大小
      db.insert(
          _tableName,
          SysConfig.createWithMapValue(
                  Const.winSize, {Const.width: 800.00, Const.height: 600.00},
                  description: "窗口默认尺寸")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 窗口最小尺寸
      db.insert(
          _tableName,
          SysConfig.createWithMapValue(
                  Const.winMinSize, {"width": 600.00, "height": 500.00},
                  description: "窗口最小尺寸")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 快捷键 父级
      var hotKey =
          SysConfig.create(Const.hotKey, Const.hotKey, description: "热键父级");
      db.insert(_tableName, hotKey.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 发送快捷键
      HotKey send = HotKey(KeyCode.enter, scope: HotKeyScope.inapp);
      db.insert(
          _tableName,
          hotKey
              .childWithMapValue(Const.hotKeySend, send.toJson(),
                  description: "触发输入的热键")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 多行快捷键
      HotKey hotKeyMultiLineInput = HotKey(KeyCode.enter,
          modifiers: [KeyModifier.shift], scope: HotKeyScope.inapp);
      db.insert(
          _tableName,
          hotKey
              .childWithMapValue(
                  Const.hotKeyMultiLineInput, hotKeyMultiLineInput.toJson(),
                  description: "触发多行输入的热键")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 唤起快捷键
      HotKey hotKeyCallDisplay = HotKey(KeyCode.keyT,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system);
      db.insert(
          _tableName,
          hotKey
              .childWithMapValue(
                  Const.hotKeyCallDisplay, hotKeyCallDisplay.toJson(),
                  description: "后台唤起应用显示的热键")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      /// 是否启用系统托盘
      db.insert(
          _tableName,
          SysConfig.create(Const.openTray, Const.enable,
                  description: "是否开启系统托盘，开启后才支持后台唤起")
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<SysConfig> read(String key) async {
    var query =
        await database.query(_tableName, where: "key = ?", whereArgs: [key]);
    if (query.isNotEmpty) {
      return SysConfig.formJson(query[0]);
    }
    return SysConfig.notExist(key);
  }

  @override
  Future<List<SysConfig>> readAll() async {
    var all = await database.query(_tableName);
    return all.map<SysConfig>((e) => SysConfig.formJson(e)).toList();
  }

  @override
  Future<List<SysConfig>> writeBatch(List<SysConfig> configList) async {
    List<SysConfig> result = [];
    for (var config in configList) {
      var latest = await write(config);
      result.add(latest);
    }
    return result;
  }

  @override
  Future<SysConfig> write(SysConfig sysConfig) async {
    String key = sysConfig.key;
    SysConfig fromDb = await read(key);
    _log.i("当前 key [$key ] ${fromDb.exist() ? '已存在，执行更新操作' : '不存在，执行插入操作'}");
    sysConfig = fromDb.exist() ? fromDb.doUpdate(sysConfig) : sysConfig;
    database.insert(_tableName, sysConfig.toJson());
    SysConfig latest = await read(key);
    _log.i("key [$key ] 处理完毕：${latest.toJson().toString()} ");
    return latest;
  }
}
