import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/component/timeline_item.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';

class TimelineContPage extends StatelessWidget{
  const TimelineContPage({super.key});

  @override
  Widget build(BuildContext context) {
    Timeline timeline = Timeline.create("测试内容测试内容");
    return TimelineItem(timeline);
  }

}
