import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/input_state.dart';
import 'package:timeline/cn/wendx/provider/hot_key/send_action_provider.dart';
import 'package:timeline/cn/wendx/provider/input_state_provider.dart';

typedef InputSubmitListen = void Function(String input, DateTime date);

typedef InputChangeListen = void Function(String input, DateTime date);

/// 暂时没办法让 TextField 不对输入做响应
///
/// 当前只是将 send 的动作交由 hotkeyManager 来触发
/// 而 TextField 本身依旧在响应 enter
///
/// 即按下 shift+enter 对TextField 来说没有意义，响应的只是enter，没有shift，
/// 只是这个enter不是 hotkeyManager触发的所以不会调用 send 的逻辑
///
/// 这种实现是有缺陷的，只是刚好实现了回车换行的效果
/// 且在mac可用，windows上可能就变成了切换输入法了
class TimelineInput extends StatefulWidget {
  static const String multiLineMode = "multiLineMode";
  static const String singleLineMode = "singleLineMode";

  final TextEditingController _inputController;

  final InputSubmitListen? _submitListen;

  final InputChangeListen? _changeListen;

  final String _mode;

  TimelineInput(
      {super.key,
      InputSubmitListen? submitListen,
      InputChangeListen? changeListen,
      TextEditingController? inputController,
      String? mode})
      : _submitListen = submitListen,
        _inputController = inputController ?? TextEditingController(),
        _changeListen = changeListen,
        _mode = mode ?? singleLineMode;

  @override
  State<StatefulWidget> createState() {
    return TimelineInputState();
  }
}

class TimelineInputState extends State<TimelineInput> {
  static final Logger _log = Logger();

  late final TextEditingController _inputController;

  late final InputSubmitListen? _submitListen;

  late final InputChangeListen? _changeListen;

  late String _mode;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _inputController = widget._inputController;
    _submitListen = widget._submitListen;
    _changeListen = widget._changeListen;
    _mode = widget._mode;

    Provider.of<SendActionProvider>(context, listen: false)
        .register((sendEvent) {
      if (SendEvent.send == sendEvent) {
        sendInputContent(context);
      } else if (SendEvent.newline == sendEvent) {
        /// do nothing,让他自己换行
        newLine(context);
      }
    });

    // 修改输入状态为当前组件的信息
    Provider.of<InputStateProvider>(context, listen: false).change(InputState(
      inputType: InputType.normal,
      inputComp: "timeline/cn/wendx/component/timeline_input",
      inputCompMode: _mode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var secondary = Theme.of(context).cardColor;
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
              flex: 7,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Consumer<InputStateProvider>(
                    builder: (_, inputStateProvider, child) {
                      var inputCompState =
                          inputStateProvider.inputState.inputCompMode;
                      return TextField(
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: " Enter发送 ,Shift+Enter换行",
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: TimelineInput.singleLineMode == inputCompState
                            ? 1
                            : 10,
                      );
                    },
                  ))),
        ],
      ),
    );
  }

  void sendInputContent(BuildContext context) {
    var text = _inputController.text;
    if (text.isEmpty || text == "\n") {
      SmartDialog.showToast("未输入内容");
      return;
    }
    if (_submitListen != null) {
      _submitListen!(_inputController.text, DateTime.now());
    }
    _inputController.clear();
    _changeMode(context, TimelineInput.singleLineMode);
    _focusNode.requestFocus();
  }

  void newLine(BuildContext context) {
    if (_changeMode(context, TimelineInput.multiLineMode)) {
      _inputController.text = "${_inputController.text}\n";
    }
    _focusNode.requestFocus();
  }

  bool _changeMode(BuildContext context, String mode) {
    var inputStateProvider =
        Provider.of<InputStateProvider>(context, listen: false);
    var inputState = inputStateProvider.inputState;
    if (inputState.inputCompMode != mode) {
      inputStateProvider.change(inputState.copyWith(inputCompMode: mode));
      return true;
    }
    return false;
  }
}
