import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/provider/func_area_provider.dart';
import 'package:timeline/cn/wendx/util/common_util.dart';

/// 功能区域面板
///
class FuncAreaWidget extends StatelessWidget {
  List<FuncAreaContWrapper> contentList;

  late Map<String, FuncAreaContWrapper> contentMap;

  late WidgetBuilder _undefinedBuilder;

  // final WidgetBuilder defaultBuilder = (BuildContext buildContext) =>
  //    Align(
  //     alignment: Alignment.center,
  //     child: Text(
  //       "不存在的功能面板\n请尝试切换其他功能",
  //       style: CommonUtil.textColorBaseBg(buildContext),
  //     ),
  //   );

  Widget defaultBuilder(BuildContext buildContext) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "不存在的功能面板\n请尝试切换其他功能",
        style: CommonUtil.textColorBaseBg(buildContext),
      ),
    );
  }

  FuncAreaWidget(this.contentList,
      {super.key, WidgetBuilder? undefinedBuilder}) {
    contentMap = {for (var el in contentList) el.indexKey: el};
    _undefinedBuilder = undefinedBuilder ?? defaultBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuncAreaProvider>(builder: (_, funcArea, child) {
      return funcAreaBgWrapper(context, contentMap[funcArea.indexKey]);
    });
  }

  Widget funcAreaBgWrapper(
      BuildContext buildContext, FuncAreaContWrapper? contentWidget) {
    WidgetBuilder builder =
        contentWidget != null ? contentWidget.builder : _undefinedBuilder;

    return Container(
      width: 280.0,
      height: double.infinity,
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      child: Card(
        color: Theme.of(buildContext).colorScheme.background,
        child: builder(buildContext),
      ),
    );
  }
}

class FuncAreaContWrapper extends StatelessWidget {
  final String indexKey;

  WidgetBuilder builder;

  FuncAreaContWrapper({
    super.key,
    required this.indexKey,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return build(context);
  }
}
