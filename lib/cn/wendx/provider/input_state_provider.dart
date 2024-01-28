import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/input_state.dart';

class InputStateProvider extends ChangeNotifier {
  InputState _inputState;

  InputStateProvider({
    InputState? inputState,
  }) : _inputState = inputState ?? InputState();

  change(InputState inputState) {
    this._inputState = inputState;
    notifyListeners();
  }

  changeWith({
    InputType? inputType,
    String? inputComp,
    String? inputCompMode,
    DateTime? lastOperationTime,
    int? inputLineCount,
    int? inputLength,
    String? content,
  }) {
    _inputState = _inputState.copyWith(
      inputType: inputType,
      inputComp: inputComp,
      inputCompMode: inputCompMode,
      lastOperationTime: lastOperationTime,
      inputLineCount: inputLineCount,
      inputLength: inputLength,
      content: content
    );
    notifyListeners();
  }

  InputState get inputState => _inputState;
}
