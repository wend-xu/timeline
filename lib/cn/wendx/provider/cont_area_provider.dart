import 'package:flutter/cupertino.dart';

class ContAreaProvider extends ChangeNotifier {
  List<ContAreaNaviInfo> _naviStack = [];
  ContAreaProvider(String defaultNaviKey,
      {Map<String, dynamic>? defaultNaviParam}) {
      replace(defaultNaviKey,naviParam: defaultNaviParam);
  }

  void replace(String key, {Map<String, dynamic>? naviParam}){
    _naviStack.clear();
    _naviStack.add(ContAreaNaviInfo(naviKey: key,naviParam: naviParam));
    notifyListeners();
  }

  void push(String key, {Map<String, dynamic>? naviParam}){
    _naviStack.add(ContAreaNaviInfo(naviKey: key,naviParam: naviParam));
    notifyListeners();
  }

  void pop(){
    _naviStack.removeLast();
    notifyListeners();
  }

  ContAreaNaviInfo top(){
    return _naviStack.last;
  }
}

class ContAreaNaviInfo{
  String naviKey;

  Map<String,dynamic>? naviParam;

  ContAreaNaviInfo({
    required this.naviKey,
    this.naviParam,
  });

}
