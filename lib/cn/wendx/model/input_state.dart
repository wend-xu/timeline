import 'package:timeline/cn/wendx/config/sys_constant.dart';

class InputState {
  static const String DEFAULT = "default";

  InputType inputType;
  String inputComp;
  String inputCompMode;
  DateTime lastOperationTime;
  int inputLineCount;
  int inputLength;
  String content;

  InputState({
    this.inputType = InputType.normal,
    this.inputComp = DEFAULT ,
    this.inputCompMode = DEFAULT,
    lastOperationTime,
    this.inputLineCount = 0,
    this.inputLength = 0,
    this.content = "",
  }) : lastOperationTime =
            lastOperationTime ?? DateTime.fromMicrosecondsSinceEpoch(0);

  InputState copyWith({
    InputType? inputType,
    String? inputComp,
    String? inputCompMode,
    DateTime? lastOperationTime,
    int? inputLineCount,
    int? inputLength,
    String? content,
  }) {
    return InputState(
      inputType: inputType ?? this.inputType,
      inputComp: inputComp ?? this.inputComp,
      inputCompMode: inputCompMode ?? this.inputCompMode,
      lastOperationTime: lastOperationTime ?? this.lastOperationTime,
      inputLineCount: inputLineCount ?? this.inputLineCount,
      inputLength: inputLength ?? this.inputLength,
      content: content ?? this.content,
    );
  }
}
