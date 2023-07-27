import 'package:flutter/material.dart';

class FuncAreaProvider extends ChangeNotifier{
  String _indexKey;

  FuncAreaProvider(this._indexKey);

  void doNavi(String indexKey){
    _indexKey = indexKey;
    notifyListeners();
  }

  String get indexKey => _indexKey;
}