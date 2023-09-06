import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/component/function_area.dart';
import 'package:timeline/cn/wendx/provider/cont_area_provider.dart';

import '../util/common_util.dart';

typedef NaviBuilder = Widget Function(
    BuildContext buildContext, Map<String, dynamic>? naviParam);

/// 类似 [FuncAreaWidget] 的实现，但是提供一个 context 上下文对象
/// 需要考虑 context 对象如何处理切换的问题，或者说 provider 本身就是一个外置的带控制功能的上下文？
class ContAreaWidget extends StatelessWidget {
  List<ContAreaContWrapper> wrapperList;

  late Map<String, ContAreaContWrapper> wrapperMap;

  late NaviBuilder _undefinedBuilder;

  Widget defaultBuilder(
      BuildContext buildContext, Map<String, dynamic>? naviParam) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "不存在的内容面板\n请尝试切换其他功能",
        style: CommonUtil.textColorBaseBg(buildContext),
      ),
    );
  }

  ContAreaWidget(this.wrapperList, {super.key, NaviBuilder? undefinedBuilder}) {
    wrapperMap = {for (var el in wrapperList) el.naviKey: el};
    _undefinedBuilder = undefinedBuilder ?? defaultBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContAreaProvider>(builder: (_, contAreaProvider, child) {
      ContAreaNaviInfo top = contAreaProvider.top();
      return contAreaBgWrapper(context, wrapperMap[top.naviKey], top.naviParam);
    });
  }

  Widget contAreaBgWrapper(BuildContext buildContext,
      ContAreaContWrapper? contWrapper, Map<String, dynamic>? paramMap) {
    NaviBuilder naviBuilder = contWrapper?.builder ?? _undefinedBuilder;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.only(right: 5, top: 5),
      child: Card(
        color: Theme.of(buildContext).colorScheme.background,
        child: naviBuilder(buildContext,paramMap),
      ),
    );
  }
}

class ContAreaContWrapper extends StatelessWidget {
  NaviBuilder builder;

  String naviKey;

  ContAreaContWrapper({
    super.key,
    required this.builder,
    required this.naviKey,
  });

  @override
  Widget build(BuildContext context) {
    return const Text("只是个包装器不会被挂到widget树");
  }
}
