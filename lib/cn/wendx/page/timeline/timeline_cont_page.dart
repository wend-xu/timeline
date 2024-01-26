import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/component/refresh_list_view_v3.dart';
import 'package:timeline/cn/wendx/component/timeline_input.dart';
import 'package:timeline/cn/wendx/component/timeline_item.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/provider/input_state_provider.dart';
import 'package:timeline/cn/wendx/service/timeline_service.dart';

class TimelineContPage extends StatelessWidget {
  late TimelineService timelineService;

  late RefreshListViewController<Timeline> listController;

  TimelineContPage({
    super.key,
  }) {
    timelineService = GetIt.instance.get<TimelineService>();
    listController = RefreshListViewController();
  }

  @override
  Widget build(BuildContext context) {
    var background = Theme.of(context).colorScheme.background;
    return Column(
      children: [
        Expanded(
          child: Card(
            child: contArea(context),
            color: background,
          ),
        ),
        Consumer<InputStateProvider>(builder: (_, inputState, child) {
          return SizedBox(
            height: inputState.inputState.inputCompMode == TimelineInput.singleLineMode?80: 240,
            child: Card(
              child: inputArea(),
              color: background,
            ),
          );
        }),

      ],
    );
  }

  Widget contArea(BuildContext context) {
    return RefreshListViewV3<Timeline>(
        controller: listController,
        itemBuilder: (Timeline tl, int index) {
          return TimelineItem(tl);
        },
        itemLoader: (int offset, int limit) async {
          TimelineRespV2<TimelineLimitSearch> timelineRespV2 =
          await timelineService
              .read(TimelineLimitSearch(limit: limit, offset: offset));
          return LoadResp<Timeline>(
              offset: timelineRespV2.limit.offset,
              limit: timelineRespV2.limit.limit,
              total: timelineRespV2.limit.total,
              dataList: timelineRespV2.data);
        });
  }

  void whenSubmit(String text, DateTime submitTime) {
    SmartDialog.showLoading(msg: "写入中");
    var timeline = Timeline.create(text, createTime: submitTime);
    timelineService.write(timeline).then((writeInDb) {
      listController.send(writeInDb, refresh: true);
      SmartDialog.dismiss();
    });
  }

  Widget inputArea() {
    return TimelineInput(
      submitListen: whenSubmit,
    );
  }
}
