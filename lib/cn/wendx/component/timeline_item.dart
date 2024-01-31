import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';

/// 拆分为三个widget实现
/// item 展示时间 修改次数， 双击事件可以不在这里实现
class TimelineItem extends StatelessWidget {
  final Timeline item;

  TimelineItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(item.createTime.toString()),
                const Spacer(),
                Text("编辑:${item.version}")
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: viewUseQuill(item),
          ),
          const Divider(
            height: 10,
          ),
        ],
      ),
    );
  }

  SelectableText viewUseNormalText(Timeline timeline){
    return SelectableText(timeline.contentText);
  }

  QuillProvider viewUseQuill(Timeline timeline){
    var quillController = QuillController.basic();
    quillController.document = Document.fromJson(jsonDecode(timeline.contentRich));
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: quillController,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('zh'),
        ),
      ),
      child: QuillEditor.basic(
        configurations: const QuillEditorConfigurations(readOnly: true),
      ),
    );
  }
}
