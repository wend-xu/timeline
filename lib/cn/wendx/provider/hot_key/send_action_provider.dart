import 'package:flutter/material.dart';

class SendActionProvider extends ChangeNotifier{

  List<SendActionCallBack> _callbackList = [];

  register(SendActionCallBack sendActionCallBack){
    _callbackList.add(sendActionCallBack);
  }

  send(){
    for(SendActionCallBack callback in _callbackList){
      callback(SendEvent.send);
    }
    notifyListeners();
  }

  newline(){
    for(SendActionCallBack callBack in _callbackList){
      callBack(SendEvent.newline);
    }
    notifyListeners();
  }
}

enum SendEvent { send , newline }

typedef SendActionCallBack = Function(SendEvent sendEvent);