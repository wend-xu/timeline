import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/repo/timeline_reporitory.dart';

class SqliteTimelineRepository extends TimelineRepository {
  static const String _dbName = "time_line.db";

  static const String _tableName = "time_line";
  static const String _columnNoteTime = "note_time";
  static const String _columnContent = "content";
  static const String _columnTotal = "total";
  static const String _columnDelStatus = "del_status";
  static const int _notDel = 0;
  static const int _del = 1;

  late Database _database;

  SqliteTimelineRepository._();

  static Future<SqliteTimelineRepository> instance() async {
    var repository = SqliteTimelineRepository._();
    await repository._init();
    return repository;
  }

  Future<void> _init() async {
    var databasesPath = await getDatabasesPath();
    print("》》》》》》》》》》》》数据库文件路径$databasesPath");
    var dbPath = join(databasesPath, _dbName);
    _database = await openDatabase(dbPath, onCreate: dbCreate, version: 1);
  }

  @override
  Future<TimelineResp<TimelineLimitOneDay>> readOneDay(
      TimelineLimitOneDay limit) async {
    List<Map<String, dynamic>> query = await _database.query(_tableName,
        where:
            "date(note_time / 1000, 'unixepoch', 'localtime') = ? and $_columnDelStatus = $_notDel ",
        whereArgs: [
          formatDate(limit.date, [yyyy, '-', mm, '-', dd])
        ]);
    return TimelineResp(limit, _convert(query));
  }

  // @override
  // Future<TimelineResp> read(TimelineLimit limit) {
  //   return Future.delayed(Duration(seconds: 5), () async {
  //     List<Map<String, dynamic>> query = await _database.query(_tableName,
  //         where: "date(note_time / 1000, 'unixepoch', 'localtime') = ?",
  //         whereArgs: [
  //           formatDate(limit.date, [yyyy, '-', mm, '-', dd])
  //         ]);
  //     Map<DateTime, String> map = new SplayTreeMap();
  //     for (var element in query) {
  //       DateTime noteTime =
  //       DateTime.fromMillisecondsSinceEpoch(element[_columnNoteTime]);
  //       String content = element[_columnContent] as String;
  //       map[noteTime] = content;
  //     }
  //     return TimelineResp(limit, map);
  //   });

  @override
  Future<void> write(String line, DateTime date) async {
    if (!_database.isOpen) {
      throw "数据库未连接";
    }
    _database.insert(_tableName,
        {_columnContent: line, _columnNoteTime: date.millisecondsSinceEpoch});
  }

  // @override
  // Future<void> write(String line, DateTime date) {
  //   return Future.delayed(Duration(seconds: 5),(){
  //     if (!_database.isOpen) {
  //       throw "数据库未连接";
  //     }
  //     _database.insert(_tableName,
  //         {_columnContent: line, _columnNoteTime: date.millisecondsSinceEpoch});
  //   });
  // }

  OnDatabaseCreateFn dbCreate = (Database db, int version) async {
    db.execute(
        "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, $_columnContent TEXT, $_columnNoteTime DATETIME, $_columnDelStatus INT DEFAULT $_notDel)");
  };

  /// if empty from db result,system has not create any record,the first record datetime as now
  /// if not , get index 0 in list,get note_time and return
  @override
  Future<DateTime> firstRecordDateTime() async {
    List<Map<String, dynamic>> rawFromDb = await _database.rawQuery(
        "select * from $_tableName where $_columnDelStatus = $_notDel  order by $_columnNoteTime asc limit 1");
    if (rawFromDb.isEmpty) {
      return DateTime.now();
    }
    var firstRecord = rawFromDb[0];
    return DateTime.fromMillisecondsSinceEpoch(firstRecord[_columnNoteTime]);
  }

  @override
  Future<TimelineResp<TimelineLimitSearch>> read(
      TimelineLimitSearch search) async {
    // if (search.isEmpty()) {
    //   return TimelineResp.emptyR(search, message: "未输入搜索参数");
    // }

    String where = '''
    where $_columnDelStatus = $_notDel 
      ${(search.contentLike == null || search.contentLike!.isEmpty) ? '' : 'and $_columnContent like "%${search.contentLike!}%"'}
      ${search.noteTimeLe == null ? '' : 'and $_columnNoteTime >= "${search.noteTimeLe!.millisecondsSinceEpoch}"'} 
      ${search.noteTimeGe == null ? '' : 'and $_columnNoteTime <= "${search.noteTimeGe!.millisecondsSinceEpoch}"'} 
    ''';

    String sql = '''
    select * from $_tableName 
      $where 
      order by $_columnNoteTime desc limit ${search.limit} offset ${search.offset};
    ''';

    var total = await count(search);
    search.total = total;

    print(sql);
    List<Map<String, dynamic>> rawFromDb =
        total > 0 ? await _database.rawQuery(sql) : [];
    return TimelineResp(search, _convert(rawFromDb));
  }

  Map<DateTime, String> _convert(List<Map<String, dynamic>> rawFromDb) {
    Map<DateTime, String> map = new SplayTreeMap();
    for (var element in rawFromDb) {
      DateTime noteTime =
          DateTime.fromMillisecondsSinceEpoch(element[_columnNoteTime]);
      String content = element[_columnContent] as String;
      map[noteTime] = content;
    }
    return map;
  }

  @override
  Future closeSources() async {
    _database.close();
  }

  @override
  Future<int> count(TimelineLimitSearch search) async {
    String where = '''
    where $_columnDelStatus = $_notDel 
      ${(search.contentLike == null || search.contentLike!.isEmpty) ? '' : 'and $_columnContent like "%${search.contentLike!}%"'}
      ${search.noteTimeLe == null ? '' : 'and $_columnNoteTime >= "${search.noteTimeLe!.millisecondsSinceEpoch}"'} 
      ${search.noteTimeGe == null ? '' : 'and $_columnNoteTime <= "${search.noteTimeGe!.millisecondsSinceEpoch}"'} 
    ''';

    String countSql = '''
    select count(*) as $_columnTotal from $_tableName 
     $where 
    ''';
    List<Map<String, dynamic>> countFromDb = await _database.rawQuery(countSql);
    return countFromDb[0][_columnTotal] as int;
  }

  @override
  Future<String> readByDataTime(DateTime dateTime) async {
    List<Map<String, Object?>> list = await _database.query(_tableName,
        where: "$_columnNoteTime =  ? and $_columnDelStatus = $_notDel ",
        whereArgs: [dateTime.millisecondsSinceEpoch]);
    if (list.isNotEmpty && list[0][_columnContent] != null) {
      return list[0][_columnContent] as String;
    }
    return "";
  }

  @override
  Future<bool> updateByDateTime(DateTime dateTime, String content) async {
    var count = await _database.update(_tableName, {_columnContent: content},
        where: "$_columnNoteTime =  ? and $_columnDelStatus = $_notDel",
        whereArgs: [dateTime.millisecondsSinceEpoch]);
    return count == 1;
  }

  @override
  Future<bool> deleteByDateTime(DateTime dateTime) async {
    var count = await _database.update(_tableName, {_columnDelStatus: _del},
        where: "$_columnNoteTime =  ? and $_columnDelStatus = $_notDel",
        whereArgs: [dateTime.millisecondsSinceEpoch]);
    return count == 1;
  }
}
