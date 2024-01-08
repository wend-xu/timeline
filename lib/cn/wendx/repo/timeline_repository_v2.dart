import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';

abstract class TimelineRepositoryV2{

  Future<Timeline> write(Timeline timeline);

  /// read one day date,must set a day which want filter
  Future<TimelineRespV2<TimelineLimitOneDay>> readOneDay(TimelineLimitOneDay limit);

  Future<TimelineRespV2<TimelineLimitSearch>> read(TimelineLimitSearch search);

  Future<int> count(TimelineLimitSearch search);

  Future<Timeline> readByCreateTime(DateTime dateTime);

  Future<Timeline> updateByDateTime(Timeline timeline);

  Future<bool> deleteByDateTime(DateTime dateTime);

  /// the first record create dateTime
  Future<DateTime> firstRecordDateTime();
}