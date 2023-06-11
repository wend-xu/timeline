import 'package:flutter/material.dart';

typedef InputListen = void Function(String key, DateTime date);

class InputAreaComp extends StatefulWidget {
  final TextEditingController _inputController;

  final InputListen? _listen;

  InputAreaComp({super.key, InputListen? listen,TextEditingController? inputController})
      : _listen = listen,_inputController = inputController??TextEditingController();

  @override
  State<StatefulWidget> createState() {
    return InputAreaState();
  }
}

class InputAreaState extends State<InputAreaComp> {
  late final TextEditingController _inputController;
  late final InputListen? _listen;

  @override
  void initState() {
    _inputController = widget._inputController;
    _listen = widget._listen;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 15.0,right: 15,bottom: 20),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0,right: 15,top: 5,bottom: 5),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextField(
                  autofocus: true,
                  controller: _inputController,
                  //keyboardType: TextInputType.multiline,
                  //maxLines: 8,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                    hintText: "请输入你的想法,回车 biubiu～ 发送",
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    sendInputContent();
                  },
                ),
              )
            ),
            // Expanded(
            //   flex: 1,
            //   child: ElevatedButton(
            //     onPressed: sendInputContent,
            //     child: Text("biubiu~发送"),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void sendInputContent(){
    var text = _inputController.text;
    if(text.isEmpty || text == "\n"){
      tip("您没有输入biubiubiu的内容呢～");
      return;
    }
    if (_listen != null) {
      _listen!(_inputController.text, DateTime.now());
    }
    _inputController.clear();
  }

  void tip(String tip){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("有点小问题"),
            content: Text(tip),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("点我"))
            ],
          );
        });
  }
}
