import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/component/desktop_navigation.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/navi_rail_dest_data.dart';
import 'package:timeline/cn/wendx/model/theme_provider.dart';
// import 'package:timeline/cn/wendx/component/desktop_navigation.dart';

class TestPage extends StatelessWidget {
  static final List<MaterialColor> supportColors = List.unmodifiable([
    Colors.blue,
    Colors.deepPurple,
    Colors.indigo,
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.blueGrey,
    Colors.grey
  ]);

   int colorIndex = 0;


  Widget build(BuildContext context) {
    var desktopNavigation = DesktopNavigation([
      NaviRailDestData.create("key1", Icons.view_timeline_outlined, "时间线",
          sort: 3),
      NaviRailDestData.create("key2", Icons.dashboard, "看板"),
      NaviRailDestData.create("key3", Icons.calendar_view_day_outlined, "日程",
          areaIn: Const.desktopNaviArea.trailing),
      NaviRailDestData.create("key4", Icons.settings, "设置",
          areaIn: Const.desktopNaviArea.trailing,
          destinationSelected: (index, buildContext) {
        Logger().i("设置按钮被点击");
        SmartDialog.showToast("is always $index in trailing");
        var themeProvider = Provider.of<ThemeProvider>(buildContext,listen: false);
        colorIndex = colorIndex+1;
        colorIndex = colorIndex>= supportColors.length?0:colorIndex;
        themeProvider.refreshTheme(ThemeData(primarySwatch:supportColors[colorIndex]));

      }),
    ], (int index, NaviRailDestData selectedData, BuildContext context) {
      SmartDialog.showToast("$index is ${selectedData.label}");
    });

    return Row(
      children: [desktopNavigation, Expanded(child: cexpAndCont(context))],
    );
  }

  Widget cexpAndCont(BuildContext context) {
    return Column(
      children: [

        Expanded(
            child: Row(
          children: [exploer(context), Expanded(child: content())],
        )),
        Container(
          padding: EdgeInsets.only(right: 10, left: 10),
          constraints: BoxConstraints(
            minHeight: 24,
            maxHeight: 24,
          ),
          child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Text(
                    "当前位置：timeline -> 搜索结果 ",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    "最后操作：2023-07-08 22:27:12 字数：9999 行数：9999",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget exploer(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      padding: EdgeInsets.only(left: 5, right: 5, top: 5),
      child: Card(
        color: Theme.of(context).primaryColorDark,
      ),
    );
  }

  Widget content() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(right: 5, top: 5),
      child: Card(
        color: Colors.white54,
      ),
    );
  }
}
