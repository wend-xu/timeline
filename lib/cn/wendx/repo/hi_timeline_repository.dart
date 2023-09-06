import 'package:timeline/cn/wendx/model/hi_timeline.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';

abstract class HiTimelineRepository{
  Future<void> write(Timeline timeline);

  Future<List<HiTimeline>> readHistory(int tId);
}