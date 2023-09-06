import 'package:flutter/material.dart';

class FuncAreaProvider extends ChangeNotifier{
  String _naviKey;

  FuncAreaProvider(this._naviKey);

  void doNavi(String naviKey){
    _naviKey = naviKey;
    notifyListeners();
  }

  String get naviKey => _naviKey;
}