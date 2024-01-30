import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/component/refresh_list_view.dart';
import 'package:timeline/cn/wendx/component/timeline_input.dart';
import 'package:timeline/cn/wendx/component/timeline_item.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/input_state.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/model/timeline_search.dart';
import 'package:timeline/cn/wendx/provider/hot_key/send_action_provider.dart';
import 'package:timeline/cn/wendx/provider/input_state_provider.dart';
import 'package:timeline/cn/wendx/service/timeline_service.dart';

class TimelineContPage extends StatelessWidget {
  late TimelineService timelineService;

  late RefreshListViewController<Timeline> _listController;

  late TimelineInputController _inputController;

  late InputState _initInputState;

  late Key _timelineInputKey;

  TimelineContPage({
    super.key,
  }) {
    timelineService = GetIt.instance.get<TimelineService>();
    _listController = RefreshListViewController();
    _inputController = TimelineInputController();
    _initInputState = InputState(
      inputType: InputType.normal,
      inputComp: "timeline/cn/wendx/component/timeline_input",
      inputCompMode: TimelineInput.singleLineMode,
    );
    _timelineInputKey = Key("${DateTime.now().millisecondsSinceEpoch}");
  }

  @override
  Widget build(BuildContext context) {
    sendStateInit(context);
    registerSendActionCallback(context);
    // 修改输入状态为当前组件的信息
    return Consumer<InputStateProvider>(
        builder: (contextConsumer, inputStateProvider, child) {
      focusInput();
      return Column(
        children: [contArea(context), inputArea(context, inputStateProvider)],
      );
    });
  }

  Widget contArea(BuildContext context) {
    var background = Theme.of(context).colorScheme.background;
    return Expanded(
      child: Card(
        color: background,
        child: RefreshListView<Timeline>(
            controller: _listController,
            itemBuilder: (Timeline tl, int index) {
              return TimelineItem(tl);
            },
            itemLoader: (int offset, int limit) async {
              TimelineResp<TimelineLimitSearch> timelineRespV2 =
                  await timelineService
                      .read(TimelineLimitSearch(limit: limit, offset: offset));
              return LoadResp<Timeline>(
                  offset: timelineRespV2.limit.offset,
                  limit: timelineRespV2.limit.limit,
                  total: timelineRespV2.limit.total,
                  dataList: timelineRespV2.data);
            }),
      ),
    );
  }

  Widget inputArea(
      BuildContext context, InputStateProvider inputStateProvider) {
    var inputState = inputStateProvider.inputState;
    var background = Theme.of(context).colorScheme.background;
    return SizedBox(
      height: inputState.inputCompMode ==
              TimelineInput.singleLineMode
          ? 80
          : 240,
      child: Card(
        color: background,
        child: TimelineInput(
          // key: _timelineInputKey,
          inputController: _inputController,
          mode: inputState.inputCompMode,
        ),
      ),
    );
  }

  void registerSendActionCallback(BuildContext context) {
    Provider.of<SendActionProvider>(context, listen: false)
        .register(_initInputState.inputComp, (sendEvent) {
      if (sendEvent == SendEvent.send) {
        whenSend(context);
      } else if (sendEvent == SendEvent.newline) {
        whenNewline(context);
      }
    });
  }

  void whenSend(BuildContext context) {
    _inputController.unfocus();
    if (_inputController.getPlainText().replaceAll("\n", "").trim().isEmpty) {
      SmartDialog.showToast("未输入内容");
      return;
    }

    SmartDialog.showLoading(msg: "写入中");
    var plainText = _inputController.getPlainText();
    var richText = _inputController.getRichText();

    var timeline = Timeline.create(plainText,
        createTime: DateTime.timestamp(), contentRich: richText);

    timelineService.write(timeline).then((writeInDb) {
      _listController.send(writeInDb, refresh: true);
      _inputController.doClear();
      _inputController.focus();
      Provider.of<InputStateProvider>(context, listen: false)
          .changeWith(inputCompMode: TimelineInput.singleLineMode);
      SmartDialog.dismiss();
    });
  }

  void whenNewline(BuildContext context) {
    _inputController.unfocus();
    var inputStateProvider =
        Provider.of<InputStateProvider>(context, listen: false);
    var inputState = inputStateProvider.inputState;
    if (TimelineInput.singleLineMode == inputState.inputCompMode) {
      inputStateProvider.changeWith(inputCompMode: TimelineInput.multiLineMode);
    }
    _inputController.focus();
  }

  void sendStateInit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var inputStateProvider =
          Provider.of<InputStateProvider>(context, listen: false);
      if (inputStateProvider.inputState
          .compMismatch(_initInputState.inputComp)) {
        inputStateProvider.change(_initInputState);
        _listController.load();
      }
    });
  }

  void focusInput() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _inputController.focus();
    });
  }
}
