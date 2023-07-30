import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';

abstract class TimelineRepositoryV2{

  Future<void> write(Timeline timeline);

  /// read one day date,must set a day which want filter
  Future<TimelineResp<TimelineLimitOneDay>> readOneDay(TimelineLimitOneDay limit);

  Future<TimelineResp<TimelineLimitSearch>> read(TimelineLimitSearch search);

  Future<int> count(TimelineLimitSearch search);

  Future<String> readByDataTime(DateTime dateTime);

  Future<bool> updateByDateTime(DateTime dateTime,String content);

  Future<bool> deleteByDateTime(DateTime dateTime);

  /// the first record create dateTime
  Future<DateTime> firstRecordDateTime();

}