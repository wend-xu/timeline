import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/navi_rail_dest_data.dart';

class test {
  late final bool a;

  void aHasInit() {
    if (a == null || a == false) {
      a = true;
    }
  }
}

void main() {
  var naviRailDestData1 = NaviRailDestData(
      key: "key1",
      areaIn: DesktopNaviArea.destination,
      iconData: Icons.add,
      label: "key1",
      sort: 1,
      able: Able.enable);
  var naviRailDestData2 = NaviRailDestData(
      key: "key2",
      areaIn: DesktopNaviArea.destination,
      iconData: Icons.add,
      label: "key2",
      sort: 2,
      able: Able.enable);
  var naviRailDestData3 = NaviRailDestData(
      key: "key3",
      areaIn: DesktopNaviArea.destination,
      iconData: Icons.add,
      label: "key3",
      sort: 3,
      able: Able.enable);
  var naviRailDestData4 = NaviRailDestData(
      key: "key4",
      areaIn: DesktopNaviArea.destination,
      iconData: Icons.add,
      label: "key4",
      sort: 4,
      able: Able.enable);
  var naviRailDestData5 = NaviRailDestData(
      key: "key5",
      areaIn: DesktopNaviArea.destination,
      iconData: Icons.add,
      label: "key5",
      sort: 5,
      able: Able.enable);

  List<NaviRailDestData> list = [
    naviRailDestData1,
    naviRailDestData2,
    naviRailDestData3,
    naviRailDestData4,
    naviRailDestData5
  ];

  // 小到大
  list.sort((e1,e2) => e1.sort.compareTo(e2.sort));

  list.sort((e1,e2) => e2.sort.compareTo(e1.sort));
}
