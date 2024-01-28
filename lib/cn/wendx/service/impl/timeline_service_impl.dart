import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/repo/hi_timeline_repository.dart';
import 'package:timeline/cn/wendx/repo/timeline_repository.dart';
import 'package:timeline/cn/wendx/service/timeline_service.dart';

class TimelineServiceImpl extends TimelineService
    with IocRegister<TimelineService> {
  TimelineRepository timelineRepository;

  HiTimelineRepository hiTimelineRepository;

  TimelineServiceImpl._(this.timelineRepository, this.hiTimelineRepository);

  static Future<TimelineService> instanceAsync() async {
    var getIt = GetIt.instance;
    TimelineRepository timelineRepository =
        getIt.get<TimelineRepository>();
    HiTimelineRepository hiTimelineRepository =
        getIt.get<HiTimelineRepository>();
    return TimelineServiceImpl._(timelineRepository, hiTimelineRepository);
  }

  @override
  Future<int> count(TimelineLimitSearch search) {
    return timelineRepository.count(search);
  }

  @override
  Future<bool> deleteByDateTime(DateTime dateTime) {
    return timelineRepository.deleteByDateTime(dateTime);
  }

  @override
  Future<DateTime> firstRecordDateTime() {
    return timelineRepository.firstRecordDateTime();
  }

  @override
  Future<TimelineResp<TimelineLimitSearch>> read(TimelineLimitSearch search) {
    return timelineRepository.read(search);
  }

  @override
  Future<Timeline> readByDataTime(DateTime dateTime) {
    return timelineRepository.readByCreateTime(dateTime);
  }

  @override
  Future<TimelineResp<TimelineLimitOneDay>> readOneDay(
      TimelineLimitOneDay limit) {
    return timelineRepository.readOneDay(limit);
  }

  @override
  Future<Timeline> update(Timeline timeline) async {
    Timeline timelineInDB= await timelineRepository.readByCreateTime(timeline.createTime);
    if(timelineInDB.exist()){
      hiTimelineRepository.write(timelineInDB);
      return await timelineRepository.updateByDateTime(timelineInDB.updateMerge(timeline));
    }
    return await timelineRepository.write(timeline);
  }

  @override
  Future<Timeline> write(Timeline timeline) {
    return timelineRepository.write(timeline);
  }

  @override
  void register(TimelineService instance) {
    GetIt.instance.registerSingleton<TimelineService>(instance);
  }
}
