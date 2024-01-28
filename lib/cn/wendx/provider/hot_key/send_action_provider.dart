import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';

class SendActionProvider extends ChangeNotifier{

  final Map<String,SendActionCallBack> _callbackMap = {};

  register(String key,SendActionCallBack sendActionCallBack){
    _callbackMap[key] = sendActionCallBack;
  }

  send(){
    _callbackMap.forEach((key, value) {
      value(SendEvent.send);
    });
    notifyListeners();
  }

  newline(){
    _callbackMap.forEach((key, value) {
      value(SendEvent.newline);
    });
    notifyListeners();
  }
}



typedef SendActionCallBack = Function(SendEvent sendEvent);