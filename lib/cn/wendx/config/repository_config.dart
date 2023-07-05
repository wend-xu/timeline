import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timeline/cn/wendx/config/app_info.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/repo/impl/sqlite_timeline_repository.dart';
import 'package:timeline/cn/wendx/repo/impl/sys_config_repository_impl.dart';
import 'package:timeline/cn/wendx/repo/sqliite_repository.dart';

Future openSqliteAndRegisterRepository() async {
  var logger = Logger();

  /// windows和linux需要使用使用 ffi，macos、android 和 ios是自带sqlite的不需要ffi
  if (Platform.isWindows || Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
  }

  var sqliteInitHelper =
      SqliteRepositoryInitHelper([SqliteTimelineRepository(), SysConfigRepositoryImpl()]);

  var databasesPath = await getDatabasesPath();
  logger.i("数据库文件路径$databasesPath");
  var dbPath = join(databasesPath, AppInfo.dbName);
  Database db = await openDatabase(dbPath,
      onCreate: sqliteInitHelper.onDbCreate(),
      onUpgrade: sqliteInitHelper.onDbUpgrade(),
      onDowngrade: sqliteInitHelper.onDbDowngrade(),
      version: AppInfo.dbVersion);
  logger.i("数据库打开完成，准备初始化 sqlite repository");
  sqliteInitHelper.onDbOpen(db);
  logger.i("开始注册 repository 到 IOC 容器");
  sqliteInitHelper.registerToIoc();
  logger.i("初始化完成");
}



class SqliteRepositoryInitHelper with IocRegisterHelper{
  final Logger _l = Logger();

  final List<SqliteRepository> _sqliteRepositoryList;

  SqliteRepositoryInitHelper(this._sqliteRepositoryList);

  /// 无论是创建还是修改，
  /// 合理的情况应该是把所有的 SqliteRepository 升级到同一版本，然后在执行下一版本升级
  /// 表与表可能存在外键关联，且除了ddl还会存在赋予初始值的dml
  OnDatabaseCreateFn onDbCreate() {
    return (Database db, int version) {
      for (int currentVersion = 1;
          currentVersion < version + 1;
          currentVersion++) {
        _l.i(
            "数据库第一次创建，执行数据库初始化操作,开始执行version: $currentVersion 初始化,当前数据库版本： $version ");
        for (SqliteRepository sqliteRepository in _sqliteRepositoryList) {
          var sqlScript =
              sqliteRepository.sqlScriptUpgradeOnVersion(currentVersion);
          sqlScript(db, version, version);
          _l.i(
              "执行sql 脚本，sqliteRepository：[${sqliteRepository.runtimeType.toString()}] 在 version $currentVersion 执行成功");
        }
        _l.i(
            "数据库已完成版本 $currentVersion 初始化，最新版本: $version 是否已完成 ${currentVersion == version}");
      }
    };
  }

  OnDatabaseVersionChangeFn onDbUpgrade() {
    return (Database db, int oldVersion, int newVersion) {
      _l.i("开始准备数据库升级，当前数据库版本： $oldVersion ,目标数据库版本 $newVersion ");

      for (int currentVersion = oldVersion + 1;
          currentVersion < newVersion + 1;
          currentVersion++) {
        _l.i(
            "开始执行应用数据库升级操，开始执行version: $currentVersion 初始化,当前数据库版本： $newVersion");
        for (SqliteRepository sqliteRepository in _sqliteRepositoryList) {
          var sqlScript =
              sqliteRepository.sqlScriptUpgradeOnVersion(currentVersion);
          sqlScript(db, oldVersion, newVersion);
          _l.i(
              "执行sql 脚本，sqliteRepository：[${sqliteRepository.runtimeType.toString()}] 在 version $currentVersion 执行成功");
        }
        _l.i(
            "数据库已完成版本 $currentVersion 初始化，最新版本: $newVersion 是否已完成 ${currentVersion == newVersion}");
      }
    };
  }

  OnDatabaseVersionChangeFn onDbDowngrade() {
    return (Database db, int oldVersion, int newVersion) {};
  }

  void onDbOpen(Database db) {
    for (var sqliteRepository in _sqliteRepositoryList) {
      _l.i("开始初始化 【${sqliteRepository.runtimeType.toString()}】,注册数据源");
      sqliteRepository.onDbOpen(db);
    }
  }

  @override
  List registerList()  => _sqliteRepositoryList;

}
