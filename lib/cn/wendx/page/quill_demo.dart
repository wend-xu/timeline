import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class QuillDemo extends StatelessWidget{
  final _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('de'),
        ),
      ),
      child: Column(
        children: [
          const QuillToolbar(),
          Expanded(
            child: QuillEditor.basic(
              configurations: const QuillEditorConfigurations(
                readOnly: false,
              ),
            ),
          )
        ],
      ),
    );
  }

}