import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/component/desktop_navigation.dart';
import 'package:timeline/cn/wendx/component/function_area.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/page/test_page.dart';
import 'package:timeline/cn/wendx/provider/func_area_provider.dart';
import 'package:timeline/cn/wendx/provider/navi_provider.dart';

/// 标准布局页面
class LayoutPage extends StatelessWidget {
  static final Logger _log = Logger();

  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout1(
      navigationBuilder: _navigationBuilder,
      funcAreaBuilder: _funcAreaBuilder,
      contentAreaBuilder: _contentAreaBuilder,
      tipBarBuilder: _tipBarBuilder,
    );
  }

  Consumer<NaviProvider> _navigationBuilder(BuildContext buildContext) {
    return Consumer<NaviProvider>(builder:
        (BuildContext consumerContext, NaviProvider provider, Widget? child) {
      _log.i("开始构建导航条,导航数据： ${jsonEncode(provider.naviRailDestDataList)}");
      return DesktopNavigation(provider.naviRailDestDataList,
          (index, selectedData, buildContextNavi) {
        FuncAreaProvider funcAreaProvider =
            Provider.of<FuncAreaProvider>(consumerContext, listen: false);
        funcAreaProvider.doNavi(selectedData.key);
      });
    });
  }

  Widget _funcAreaBuilder(BuildContext buildContext) {
    return FuncAreaWidget([
      FuncAreaContWrapper(
          indexKey: Const.naviTimeline,
          builder: (buildContext) {
            return const Text(Const.naviTimeline);
          }),
      FuncAreaContWrapper(
          indexKey: Const.naviSetting,
          builder: (buildContext) {
            return const Text(Const.naviSetting);
          })
    ]);
  }

  Widget _contentAreaBuilder(BuildContext buildContext) {
    return TestContentWidget();
  }

  Widget _tipBarBuilder(BuildContext buildContext) {
    return TestBottomBarWidget();
  }
}

class Layout1 extends StatelessWidget {
  WidgetBuilder navigationBuilder;
  WidgetBuilder funcAreaBuilder;
  WidgetBuilder contentAreaBuilder;
  WidgetBuilder tipBarBuilder;

  Layout1({
    super.key,
    required this.navigationBuilder,
    required this.funcAreaBuilder,
    required this.contentAreaBuilder,
    required this.tipBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        navigationBuilder(context),
        Expanded(
            child: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                funcAreaBuilder(context),
                Expanded(child: contentAreaBuilder(context))
              ],
            )),
            tipBarBuilder(context)
          ],
        ))
      ],
    );
  }
}
