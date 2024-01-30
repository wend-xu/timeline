import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logger/logger.dart';

typedef InputChangeListen = void Function(
    String plainText, String richText, DateTime date);

class TimelineInput extends StatefulWidget {
  static const String multiLineMode = "multiLineMode";
  static const String singleLineMode = "singleLineMode";

  final InputChangeListen? _changeListen;

  final String _mode;

  final TimelineInputController? _controller;

  TimelineInput(
      {super.key,
      InputChangeListen? changeListen,
      TimelineInputController? inputController,
      String? mode})
      : _changeListen = changeListen,
        _controller = inputController ?? TimelineInputController(),
        _mode = mode ?? singleLineMode;

  @override
  State<StatefulWidget> createState() {
    return TimelineInputState();
  }
}

class TimelineInputState extends State<TimelineInput> {
  static final Logger _log = Logger();

  late InputChangeListen? _changeListen;

  late final QuillController _quillController;

  late TimelineInputController? _controller;

  late String _mode;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    widgetFieldBind();
    _quillController = QuillController.basic();
  }


  @override
  void didUpdateWidget(TimelineInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    widgetFieldBind();
  }

  void widgetFieldBind(){
    _changeListen = widget._changeListen;
    _mode = widget._mode;
    _controller = widget._controller;
    _controller?.bind(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
              flex: 7,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _inputUseQuill(_quillController, _mode))),
        ],
      ),
    );
  }

  QuillProvider _inputUseQuill(QuillController controller, String state) {
    const QuillToolbarConfigurations toolbarConfigurations =
        QuillToolbarConfigurations(
            toolbarIconAlignment: WrapAlignment.start,
            toolbarIconCrossAlignment: WrapCrossAlignment.start,
            showFontFamily: false,
            showFontSize: false,
            showHeaderStyle: false,
            showIndent: false,
            showDirection: false,
            showSearchButton: false,
            showSubscript: false,
            showSuperscript: false,
            showUndo: false,
            showRedo: false);

    const QuillEditorConfigurations editorConfigurations =
        QuillEditorConfigurations(
      placeholder: "Enter发送，Shift+Enter换行",
      readOnly: false,
    );

    List<Widget> inputWidget = [];
    if (TimelineInput.multiLineMode == state) {
      var quillToolbar = const QuillToolbar(
        configurations: toolbarConfigurations,
      );
      inputWidget.add(quillToolbar);
    }

    var editor = Expanded(
      child: QuillEditor.basic(
        configurations: editorConfigurations,
        focusNode: _focusNode,
      ),
    );
    inputWidget.add(editor);

    return QuillProvider(
      configurations: QuillConfigurations(
        controller: controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('zh'),
        ),
      ),
      child: Column(children: inputWidget),
    );
  }
}

class TimelineInputController {
  TimelineInputState? _state;

  void bind(TimelineInputState timelineInputState) {
    _state = timelineInputState;
  }

  bool hasBind() {
    return _state != null;
  }

  void focus() {
    hasBindCheck();
    _state!._focusNode.requestFocus();
  }

  void unfocus() {
    hasBindCheck();
    _state!._focusNode.unfocus();
  }

  void newline() {}

  bool isEmpty() {
    hasBindCheck();
    return _state!._quillController.document.isEmpty();
  }

  String getPlainText() {
    hasBindCheck();
    return _state!._quillController.document.toPlainText();
  }

  String getRichText() {
    hasBindCheck();
    return jsonEncode(_state!._quillController.document.toDelta().toJson());
  }

  void registerChangeLister() {}

  void doClear() {
    hasBindCheck();
    _state!._quillController.clear();
  }

  void singleLineMode() {
    _changeMode(TimelineInput.singleLineMode);
  }

  void multiLineMode() {
    _changeMode(TimelineInput.multiLineMode);
  }

  void _changeMode(String mode) {
    hasBindCheck();
    _state!.setState(() {
      _state!._mode = mode;
    });
  }

  void hasBindCheck() {
    if (_state == null) {
      throw Exception("TimelineInputController 未绑定至 TimelineState");
    }
  }
}
