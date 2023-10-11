import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/model/hi_timeline.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/repo/hi_timeline_repository.dart';
import 'package:timeline/cn/wendx/repo/sqliite_repository.dart';

class HiTimelineRepositoryImpl extends HiTimelineRepository
    with SqliteRepository, IocRegister<HiTimelineRepository> {
  static const String _tableName = "hi_timeline";

  final Logger _log = Logger();

  @override
  void register(HiTimelineRepository instance) {
    GetIt.instance.registerSingleton<HiTimelineRepository>(instance);
  }

  @override
  void upgradeSqlScriptRegister(OnVersionSqlScriptHolder upgradeHolder) {
    upgradeHolder.onVersion(2, (db, oldVersion, newVersion) {
      db.execute('''
 CREATE TABLE $_tableName (	
	id INTEGER PRIMARY KEY,
	tId INTEGER ,
	createTime DATETIME,
	modifyTime DATETIME default (strftime('%s','now')*1000),
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
  Future<List<HiTimeline>> readHistory(int tId) async {
    List<Map<String,dynamic>> query = await database.query(_tableName,where: " tId = ? ",whereArgs: [tId]);
    return query.map((e) => HiTimeline.fromJson(e)).toList();
  }

  @override
  Future<void> write(Timeline timeline) async {
    database.insert(_tableName, HiTimeline.fromTimeline(timeline).toJson());
  }
}
