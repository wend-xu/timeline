import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 会在future执行完后自动关闭
Function loading = (BuildContext context, Future future ,{String? tip}) {
  showDialog(
    context: context,
    barrierDismissible: false, // 是否允许用户点击对话框外部关闭
    builder: (dialogContext) {
      future.then((value){
        Navigator.of(dialogContext).pop();
      });
      return Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // 加载指示器
              SizedBox(height: 10),
              Text(tip ?? 'biu~biubiu～\n加载中～～～'),
            ],
          ),
        ),
      );
    },
  );
};