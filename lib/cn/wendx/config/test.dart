import 'package:hotkey_manager/hotkey_manager.dart';

class test{
  late final bool a;

  void aHasInit(){
    if(a == null || a ==false){
      a = true;
    }
  }
}

void main(){
  String hotkey_multiline = '''
  {"btn_1":${KeyCode.shift.keyId} ,"brn_2":$KeyCode.enter.keyId }
  ''';
  print(hotkey_multiline);
}