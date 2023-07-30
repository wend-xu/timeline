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

  final Logger _log = Logger();

  @override
  void upgradeSqlScriptRegister(OnVersionSqlScriptHolder upgradeHolder) {
    upgradeHolder.onVersion(2, (db, oldVersion, newVersion) {
      db.execute('''
 CREATE TABLE $_tableName (	
	id INTEGER PRIMARY KEY,
	createTime DATETIME,
	modifyTime DATETIME default CURRENT_TIMESTAMP,
	contentRich Text Default "",
	contentText Text Default "",
	contentNormalize Text Default "",
	version INT default 1,
	delStatus INT DEFAULT 0
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
    where del_status = ${Const.notDel} 
      ${(search.contentLike == null || search.contentLike!.isEmpty)
        ? ''
        : 'and contentNormalize like "%${search.contentLike!}%"'}
      ${search.noteTimeLe == null ? '' : 'and createTime >= "${search
        .noteTimeLe!.millisecondsSinceEpoch}"'} 
      ${search.noteTimeGe == null ? '' : 'and createTime <= "${search
        .noteTimeGe!.millisecondsSinceEpoch}"'} 
    ''';

    String countSql = '''
    select count(*) as ${Const.total} from $_tableName 
     $where 
    ''';
    
    List<Map<String, dynamic>> countFromDb = await database.rawQuery(countSql);
    return countFromDb[0][Const.total] as int;
  }

  @override
  Future<bool> deleteByDateTime(DateTime dateTime) {
    // TODO: implement deleteByDateTime
    throw UnimplementedError();
  }

  @override
  Future<DateTime> firstRecordDateTime() {
    // TODO: implement firstRecordDateTime
    throw UnimplementedError();
  }

  @override
  Future<TimelineRespV2<TimelineLimitSearch>> read(TimelineLimitSearch search) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Timeline> readByDataTime(DateTime dateTime) {
    // TODO: implement readByDataTime
    throw UnimplementedError();
  }

  @override
  Future<TimelineRespV2<TimelineLimitOneDay>> readOneDay(TimelineLimitOneDay limit) {
    // TODO: implement readOneDay
    throw UnimplementedError();
  }


  @override
  Future<bool> updateByDateTime(DateTime dateTime, String content) {
    // TODO: implement updateByDateTime
    throw UnimplementedError();
  }


  @override
  Future<void> write(Timeline timeline) {
    // TODO: implement write
    throw UnimplementedError();
  }
}
