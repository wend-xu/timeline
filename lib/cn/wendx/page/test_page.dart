import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:timeline/cn/wendx/component/desktop_navigation.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/navi_rail_dest_data.dart';
// import 'package:timeline/cn/wendx/component/desktop_navigation.dart';

class TestPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var desktopNavigation = DesktopNavigation([
      NaviRailDestData.create("key1", Icons.view_timeline_outlined,"时间线",sort: 3),
      NaviRailDestData.create("key2", Icons.dashboard,"看板"),
      NaviRailDestData.create("key3", Icons.calendar_view_day_outlined,"日程"),
      NaviRailDestData.create("key4", Icons.settings,"设置",areaIn: Const.desktopNaviArea.trailing,destinationSelected: (index){
        SmartDialog.showToast("is always $index in trailing");
      }),
    ], (int index, NaviRailDestData selectedData) {
      SmartDialog.showToast("$index is ${selectedData.label}");
    });

    return Row(
      children: [
        desktopNavigation,
        Expanded(child: cexpAndCont(context))
      ],
    );
  }

  Widget cexpAndCont(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   padding: EdgeInsets.only(right: 10, left: 10),
        //   constraints: BoxConstraints(
        //     minHeight: 24,
        //     maxHeight: 24,
        //   ),
        //   child: Align(
        //       alignment: Alignment.centerRight,
        //       child: Row(
        //         children: [
        //           Spacer(),
        //           IconButton(onPressed: (){}, icon: Icon(Icons.location_on),iconSize: 14,),
        //           IconButton(onPressed: (){}, icon: Icon(Icons.location_on),iconSize: 14,),
        //           IconButton(onPressed: (){}, icon: Icon(Icons.location_on),iconSize: 14,),
        //           IconButton(onPressed: (){}, icon: Icon(Icons.location_on),iconSize: 14,)
        //         ],
        //       )),
        // ),
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

class DesktopNavigationTest extends StatefulWidget {
  List<NavigationRailDestination> destinationList = const [
    NavigationRailDestination(
        icon: Tooltip(
          message: "时间线",
          child: Icon(Icons.timeline),
        ),
        label: Text("时间线")),
    NavigationRailDestination(
        icon: Icon(Icons.dashboard_customize), label: Text("看板")),
  ];
  int selectIndex = 0;

  List<Widget> trailingList = [
    Spacer(),
    IconButton(onPressed: () {}, icon: Icon(Icons.settings))
  ];

  DesktopNavigationTest({super.key});

  @override
  State<StatefulWidget> createState() {
    return DesktopNavigationStateTest();
  }
}

class DesktopNavigationStateTest extends State<DesktopNavigationTest> {
  static const Color textColor = Color(0xffcfd1d7);
  static const Color activeColor = Colors.blue;
  static const TextStyle labelStyle = TextStyle(color: textColor, fontSize: 11);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      // backgroundColor: Colors.black,
      backgroundColor: Theme.of(context).primaryColorDark,
      unselectedIconTheme: const IconThemeData(color: textColor),
      selectedIconTheme: const IconThemeData(color: activeColor),
      destinations: widget.destinationList,
      selectedIndex: widget.selectIndex,
      minWidth: 70,
      // labelType: NavigationRailLabelType.selected,
      leading: SizedBox(
        height: 26,
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: widget.trailingList,
              )),
        ),
      ),
    );
  }
}
