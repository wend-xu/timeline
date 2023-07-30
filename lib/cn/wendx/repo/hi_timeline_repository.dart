import 'package:timeline/cn/wendx/model/hi_timeline.dart';

abstract class HiTimelineRepository{
  void write(Timeline);

  Future<List<HiTimeline>> readHistory(int tId);
}