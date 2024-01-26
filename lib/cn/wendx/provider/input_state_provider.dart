import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/model/input_state.dart';

class InputStateProvider extends ChangeNotifier{
  InputState _inputState;

  InputStateProvider({
    InputState? inputState,
  }) : _inputState = inputState??InputState();

  change(InputState inputState){
    this._inputState = inputState;
    notifyListeners();
  }

  InputState get inputState => _inputState;
}