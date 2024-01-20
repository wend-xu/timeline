import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/provider/hot_key/send_action_provider.dart';

typedef InputSubmitListen = void Function(String input, DateTime date);

typedef InputChangeListen = void Function(String input, DateTime date);

class TimelineInput extends StatefulWidget {
  final TextEditingController _inputController;

  final InputSubmitListen? _submitListen;

  final InputChangeListen? _changeListen;

  TimelineInput(
      {super.key,
      InputSubmitListen? submitListen,
      InputChangeListen? changeListen,
      TextEditingController? inputController})
      : _submitListen = submitListen,
        _inputController = inputController ?? TextEditingController(),
        _changeListen = changeListen;

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

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _inputController = widget._inputController;
    _submitListen = widget._submitListen;
    _changeListen = widget._changeListen;
    Provider.of<SendActionProvider>(context,listen: false).register((sendEvent) {
      if(SendEvent.send == sendEvent){
        sendInputContent();
      }else{
        newLine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
              flex: 7,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextField(
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: " Enter发送 ,Shift+Enter换行",
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.none,
                  maxLines: null,
                ),
              )),
          // )
        ],
      ),
    );
  }

  void newLine() {
    // 在TextField的controller中插入一个换行符
    // _inputController.value = _inputController.value.copyWith(
    //   text: _inputController.text + '\n',
    //   selection:
    //       TextSelection.collapsed(offset: _inputController.text.length + 1),
    //   composing: TextRange.empty,
    // );
   //  _focusNode.requestFocus();
  }

  void sendInputContent() {
    var text = _inputController.text;
    if (text.isEmpty || text == "\n") {
      SmartDialog.showToast("未输入内容");
      return;
    }
    if (_submitListen != null) {
      _submitListen!(_inputController.text, DateTime.now());
    }
    _inputController.clear();
    _focusNode.requestFocus();
  }
}
