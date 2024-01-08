import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/repo/sqliite_repository.dart';
import 'package:timeline/cn/wendx/repo/timeline_repository_v2.dart';

class TimelineRepositoryV2Impl extends TimelineRepositoryV2
    with SqliteRepository, IocRegister<TimelineRepositoryV2> {
  static const String _tableName = "timeline";

  final Logger _l = Logger();

  @override
  void upgradeSqlScriptRegister(OnVersionSqlScriptHolder upgradeHolder) {
    upgradeHolder.onVersion(2, (db, oldVersion, newVersion) {
      db.execute('''
 CREATE TABLE $_tableName (	
	$colId INTEGER PRIMARY KEY,
	$colCreateTime DATETIME,
	$colModifyTime DATETIME default (strftime('%s','now')*1000),
	contentRich Text Default "",
	contentText Text Default "",
	contentNormalize Text Default "",
	version INT default 1,
	$colDelStatus INT DEFAULT 0
);
      ''');
    });
  }

  @override
  void register(TimelineRepositoryV2 instance) {
    GetIt.instance.registerSingleton<TimelineRepositoryV2>(instance);
  }

  @override
  Future<int> count(TimelineLimitSearch search) async {
    String where = '''
    where $limitNotDel 
      ${(search.contentLike == null || search.contentLike!.isEmpty) ? '' : 'and contentNormalize like "%${search.contentLike!}%"'}
      ${search.noteTimeLe == null ? '' : 'and $colCreateTime >= "${search.noteTimeLe!.millisecondsSinceEpoch}"'} 
      ${search.noteTimeGe == null ? '' : 'and $colCreateTime <= "${search.noteTimeGe!.millisecondsSinceEpoch}"'} 
    ''';

    String countSql = '''
    select count(*) as ${Const.total} from $_tableName 
     $where 
    ''';

    List<Map<String, dynamic>> countFromDb = await database.rawQuery(countSql);
    return countFromDb[0][Const.total] as int;
  }

  @override
  Future<bool> deleteByDateTime(DateTime dateTime) async {
    var count = await database.update(_tableName, {colDelStatus: Const.del},
        where: "$colCreateTime =  ? and $colDelStatus = ${Const.notDel}",
        whereArgs: [dateTime.millisecondsSinceEpoch]);
    return count >= 1;
  }

  @override
  Future<DateTime> firstRecordDateTime() async {
    List<Map<String, dynamic>> rawFromDb = await database.rawQuery(
        "select * from $_tableName where $colDelStatus = ${Const.notDel} order by $colCreateTime asc limit 1");
    if (rawFromDb.isEmpty) {
      return DateTime.now();
    }
    var firstRecord = rawFromDb[0];
    return DateTime.fromMillisecondsSinceEpoch(firstRecord["createTime"]);
  }

  @override
  Future<TimelineRespV2<TimelineLimitSearch>> read(
      TimelineLimitSearch search) async {
    String where = '''
    where $colDelStatus = ${Const.notDel} 
      ${(search.contentLike == null || search.contentLike!.isEmpty) ? '' : 'and contentNormalize like "%${search.contentLike!}%"'}
      ${search.noteTimeLe == null ? '' : 'and $colCreateTime >= "${search.noteTimeLe!.millisecondsSinceEpoch}"'} 
      ${search.noteTimeGe == null ? '' : 'and $colCreateTime <= "${search.noteTimeGe!.millisecondsSinceEpoch}"'} 
    ''';

    String sql = '''
    select * from $_tableName 
      $where 
      order by $colCreateTime ${search.isAsc?'asc':"desc"} limit ${search.limit} offset ${search.offset};
    ''';

    var total = await count(search);
    search.total = total;

    _l.i("查询语句：\n $sql");
    List<Map<String, dynamic>> rawFromDb =
        total > 0 ? await database.rawQuery(sql) : [];
    return TimelineRespV2(search, _convert(rawFromDb));
  }

  @override
  Future<Timeline> readByCreateTime(DateTime dateTime) async {
    List<Map<String, Object?>> list = await database.query(_tableName,
        where: "$colCreateTime =  ? and $limitNotDel ",
        whereArgs: [dateTime.millisecondsSinceEpoch]);
    if (list.isNotEmpty) {
      return Timeline.fromJson(list[0]);
    }
    return Timeline.create("").objNotExistAsT();
  }

  @override
  Future<TimelineRespV2<TimelineLimitOneDay>> readOneDay(
      TimelineLimitOneDay limit) async {
    List<Map<String, dynamic>> query = await database.query(_tableName,
        where:
            "date(note_time / 1000, 'unixepoch', 'localtime') = ? and $limitNotDel ",
        whereArgs: [
          formatDate(limit.date, [yyyy, '-', mm, '-', dd])
        ]);
    return TimelineRespV2(limit, _convert(query));
  }

  @override
  Future<Timeline> updateByDateTime(Timeline timeline) async {
    timeline.modifyTime = DateTime.now();
    await database.update(_tableName, timeline.toJson(),
        where: "$colCreateTime=  ? and $limitNotDel ",
        whereArgs: [timeline.createTime.millisecondsSinceEpoch]);
    return readByCreateTime(timeline.createTime);
  }

  @override
  Future<Timeline> write(Timeline timeline) async {
    timeline.createTime = timeline.createTime ?? DateTime.now();
    timeline.modifyTime = timeline.modifyTime ?? DateTime.now();
    int insertCount = await database.insert(_tableName, timeline.toJson());
    return readByCreateTime(timeline.createTime);
  }

  List<Timeline> _convert(List<Map<String, dynamic>> rawFromDb) {
    return rawFromDb.fold([], (previousValue, element) {
      var timeline = Timeline.fromJson(element);
      previousValue.add(timeline);
      return previousValue;
    });
  }

// Map<DateTime,Timeline> _convert(List<Map<String, dynamic>> rawFromDb) {
//   return rawFromDb.fold(SplayTreeMap<DateTime,Timeline>(), (previousValue, element) {
//     var timeline = Timeline.fromJson(element);
//     previousValue[timeline.createTime] = timeline;
//     return previousValue;
//   });
// }
}
