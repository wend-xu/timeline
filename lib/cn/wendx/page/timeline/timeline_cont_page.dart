import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/component/refresh_list_view_v3.dart';
import 'package:timeline/cn/wendx/component/timeline_item.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/service/timeline_service.dart';

class TimelineContPage extends StatelessWidget {
  late TimelineService timelineService;

  TimelineContPage({super.key}) {
    timelineService = GetIt.instance.get<TimelineService>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            child: contArea(context),
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        SizedBox(
          height: 50,
          child: Card(
            child: inputArea(),
            color: Theme.of(context).colorScheme.background,
          ),
        )
      ],
    );
  }

  Widget contArea(BuildContext context) {
    Timeline timeline =
        Timeline.create("所以说我现在要改这个页面，两个block，一个是输入一个是展示，输入是在下面的");

    return RefreshListViewV3<Timeline>(itemBuilder: (Timeline tl, int index) {
      return TimelineItem(tl);
    }, itemLoader: (int offset, int limit) async {
      TimelineRespV2<TimelineLimitSearch> timelineRespV2 = await timelineService
          .read(TimelineLimitSearch(limit: limit, offset: offset));
      return LoadResp<Timeline>(
          offset: timelineRespV2.limit.offset,
          limit: timelineRespV2.limit.limit,
          total: timelineRespV2.limit.total,
          dataList: timelineRespV2.data);
    });
  }

  Widget inputArea() {
    return SizedBox(
      width: double.infinity,
      child: Text(""),
    ) ;
  }
}
