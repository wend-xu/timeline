import 'package:timeline/cn/wendx/model/timeline.dart';

abstract class TimelineRepository{

  Future<void> write(String line,DateTime date);

  /// read one day date,must set a day which want filter
  Future<TimelineResp<TimelineLimitOneDay>> readOneDay(TimelineLimitOneDay limit);

  Future<TimelineResp<TimelineLimitSearch>> read(TimelineLimitSearch search);

  Future<int> count(TimelineLimitSearch search);

  Future<String> readByDataTime(DateTime dateTime);

  Future<bool> updateByDateTime(DateTime dateTime,String content);

  Future<bool> deleteByDateTime(DateTime dateTime);

  /// the first record create dateTime
  Future<DateTime> firstRecordDateTime();

  Future closeSources();
}