import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/config/logger_helper.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/navi_rail_dest_data.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';

class NaviProvider extends ChangeNotifier {
  final NaviRailDestData _refreshDestData =
      NaviRailDestData.create(Const.naviRefresh, Icons.refresh, "点击刷新数据",
          destinationSelected: (index, buildContext) {
    Provider.of<NaviProvider>(buildContext, listen: false).doLoading();

  });

  final NaviRailDestData _nothingDestData = NaviRailDestData.create(
      Const.naviNothing, Icons.more_vert, "请稍作等待", sort: 1,
      destinationSelected: (index, buildContext) {
    SmartDialog.showToast("导航数据加载中");
  });

  late final List<NaviRailDestData> _refreshList = [
    _refreshDestData,
    _nothingDestData
  ];

  late List<NaviRailDestData> _naviRailDestDataList;

  late SysConfigService _configService;

  // [ _naviRailDestDataList ] 将在初始化完成后触发 notifyListeners
  // 触发完成前应该返回一个代表加载的 NaviRailDestData  让导航条显示加载图案
  NaviProvider() {
    _configService = GetIt.instance.get<SysConfigService>();
    doLoading();
  }

  List<NaviRailDestData> get naviRailDestDataList => _naviRailDestDataList;

  void doLoading() {
    SmartDialog.showLoading(msg: "加载导航数据");
    _naviRailDestDataList = _refreshList;
    _configService
        .readByParentWithConvert<NaviRailDestData>(Const.naviGroup,
            converter: (SysConfig config) =>
                NaviRailDestData.fromConfig(config))
        .then((navDataList) {
      SmartDialog.dismiss();
      _naviRailDestDataList =
          navDataList.isNotEmpty ? navDataList : _refreshList;
      if (navDataList.isEmpty) {
        SmartDialog.showNotify(msg: "加载导航数据为空 \n可点击左侧按钮重试", notifyType: NotifyType.error);
      }
      notifyListeners();
    });
  }
}
