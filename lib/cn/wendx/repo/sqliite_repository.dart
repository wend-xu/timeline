import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timeline/cn/wendx/config/app_info.dart';
import 'package:timeline/cn/wendx/config/logger_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';

/// [OnVersionSqlScriptFn] : 当 sqlite数据库发生变更时触发的会调方法
///   如当前应用 数据库版本为 9
///     创建： 执行 version 1 ～ 9 的所有回调
///     升级，假设当前版本为3: 执行 version 4 ～ 9 的所有回调
///
/// [OnVersionSqlScriptHolder] ： 供 SqliteRepository 的实现类调用，便于维护的方式注册对应版本的脚本
///
/// [SqliteRepository] : 实现了 sqlite通用特性的类，需要链接sqlite的repository 通过mix的方式混入
///    1. 注入 sqlite 数据源
///    2. 维护数据库升级/降级脚本
///

/// 用于版本变更 ddl 语句
typedef OnVersionSqlScriptFn = Function(
    Database db, int oldVersion, int newVersion);

OnVersionSqlScriptFn doNothingOnVersionSqlScriptFn =
    (Database db, int oldVersion, int newVersion) =>
    StaticLogger.i("当前版本 $newVersion , 旧版本： $oldVersion ,将不执行任何操作");

/// 用于注册保存不同版本的ddl语句
class OnVersionSqlScriptHolder {
  final List<OnVersionSqlScriptFn> _sqlScriptList;

  OnVersionSqlScriptHolder()
      : _sqlScriptList =
  List.filled(AppInfo.dbVersion, doNothingOnVersionSqlScriptFn);

  void onVersion(int version, OnVersionSqlScriptFn func) {
    _sqlScriptList[version - 1] = func;
  }

  OnVersionSqlScriptFn getVersion(int version) {
    return _sqlScriptList[version - 1];
  }

  List<OnVersionSqlScriptFn> get sqlScriptList =>
      List.unmodifiable(_sqlScriptList);
}

/// 如果一个Repository为Sqlite，需要混入此类提供的一些特性
/// 1. 初始化数据源 database，目前支持的仅单数据源
/// 2. 注册 升级脚本
/// 3. 注册 降级脚本，降级特性暂时不被支持，先留取抽象结构
mixin SqliteRepository {
  final OnVersionSqlScriptHolder _upgradeHolder = OnVersionSqlScriptHolder();

  final OnVersionSqlScriptHolder _downgradeHolder = OnVersionSqlScriptHolder();

  late final Database _db;

  bool _upHasInit = false;
  bool _downHasInit = false;

  List<OnVersionSqlScriptFn> sqlScriptUpgrade() {
    _initUpgrade();
    return _upgradeHolder.sqlScriptList;
  }

  OnVersionSqlScriptFn sqlScriptUpgradeOnVersion(int version) {
    _initUpgrade();
    return _upgradeHolder.getVersion(version);
  }

  void _initUpgrade() {
    if (_upHasInit == false) {
      upgradeSqlScriptRegister(_upgradeHolder);
      _upHasInit = true;
    }
  }

  List<OnVersionSqlScriptFn> sqlScriptDowngrade() {
    _initDowngrade();
    return _downgradeHolder.sqlScriptList;
  }

  OnVersionSqlScriptFn sqlScriptDowngradeOnVersion(int version) {
    _initDowngrade();
    return _downgradeHolder.getVersion(version);
  }

  void _initDowngrade() {
    if (_downHasInit == false) {
      downgradeSqlScriptRegister(_downgradeHolder);
      _downHasInit = true;
    }
  }

  /// 提供子类实现的升级脚本注册器
  /// 必须实现
  void upgradeSqlScriptRegister(OnVersionSqlScriptHolder upgradeHolder);

  /// 提供子类实现的降级脚本注册器
  /// 可选实现，暂不支持
  ///
  /// 你无法预知未来的操作，所以降级操作好像没什么用？
  /// 如果要实现，应该是接受外部信息，因为你无法预知未来的操作
  /// 如请求服务器信息，或者接收一个外部脚本信息源，否则在表结构不兼容的情况下 降级应该是不可行
  /// 且在表结构不兼容的情况下，降级势必会丢失信息不可恢复
  /// 此时除非出现不兼容结构就用新标
  void downgradeSqlScriptRegister(OnVersionSqlScriptHolder downgradeHolder) {
    /// implement when need
  }

  /// when database open call by [SqliteInitHelper]
  /// if need any logic call overwrite this method
  void onDbOpen(Database db) {
    _db = db;
  }

  Database get database => _db;

  String get colId => "id";
  String get colDelStatus => "delStatus";
  String get colCreateTime  => "createTime";
  String get colModifyTime => "modifyTime";
  String get colTotal  => "total";
  String get limitNotDel => " $colDelStatus = ${Const.notDel} ";
}


