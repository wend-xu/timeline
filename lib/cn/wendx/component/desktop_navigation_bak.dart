import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/navi_rail_dest_data.dart';
import 'package:timeline/cn/wendx/provider/theme_provider.dart';

/// 适用于桌面的侧边导航，基于[NavigationRail]
/// destination 区域: 按钮提供 点击选择
/// trailing 区域： 底部按钮只是 点击 无选择 操作
///
///  [DestinationBuilder]  将 NaviRailDestData  转换为 NavigationRailDestination
///   提供默认实现，用于修改样式
///
/// [TrailingBuilder] 将 NaviRailDestData  转换为 , 用于构建底部按钮样式
///   原生 NavigationRail 的底部按钮不支持多个，组件进行了扩展已支持多个底部按钮
///   提供默认实现
///
/// [ DestinationSelectedCommon ]  destination 区域发生点击选择时触发该逻辑，提供选择的 NaviRailDestData 和索引i
///   如需要对按钮指定特殊回调，需要在 [ NaviRailDestData.destinationSelected ] 指定
///
/// [ DesktopNavigationController ] 用于上级组件对导航区做局部修改操作
///   - 禁用特定功能
///   - 启用/增加特定功能
///   - 修改特定回调
///   - 获取当前选择的index
///   - 获取当前选择的data
///
/// [DesktopNavigation]: 导航组件
///
///  [DesktopNavigationState ]： 导航组件的状态

typedef DestinationBuilder = NavigationRailDestination Function(
    NaviRailDestData destData, BuildContext buildContextNavi);

typedef TrailingBuilder = Widget Function(
    NaviRailDestData destData, BuildContext buildContextNavi);

typedef DestinationSelectedCommon = void Function(
    int index, NaviRailDestData selectedData, BuildContext buildContextNavi);

class DesktopNavigationController {
  DesktopNavigationState? _state;

  DesktopNavigationController();

  void binding(DesktopNavigationState state) => _state = state;

  int selectedIndex() {
    assert(_state != null, "未绑定状态");
    return _state!._selectIndex;
  }
}

class DesktopNavigation extends StatefulWidget {
  final List<NaviRailDestData> _destinationDataList;

  final DestinationBuilder _destinationBuilder;

  final TrailingBuilder _trailingBuilder;

  final DestinationSelectedCommon _onDestinationSelected;

  final int _selectIndex;

  final DesktopNavigationController? _controller;

  DesktopNavigation(this._destinationDataList, this._onDestinationSelected,
      {super.key,
      int selectIndex = 0,
      DestinationBuilder? destinationBuilder,
      TrailingBuilder? trailingBuilder,
      DesktopNavigationController? controller})
      : _selectIndex = selectIndex,
        _destinationBuilder = destinationBuilder ?? defaultDestinationBuilder,
        _trailingBuilder = trailingBuilder ?? defaultTrailingBuilder,
        _controller = controller;

  @override
  State<StatefulWidget> createState() {
    return DesktopNavigationState();
  }
}

class DesktopNavigationState extends State<DesktopNavigation> {
  final List<NaviRailDestData> _destList = [];
  final List<NaviRailDestData> _trailingList = [];

  late DestinationBuilder _destinationBuilder;
  late TrailingBuilder _trailingBuilder;

  late DestinationSelectedCommon _onDestinationSelectedCommon;

  int _selectIndex = 0;
  NavigationRail? _navigationRail;
  DesktopNavigationController? _controller;

  final double _width = 72;

  @override
  void initState() {
    super.initState();
    _selectIndex = widget._selectIndex;
    _destinationBuilder = widget._destinationBuilder;
    _trailingBuilder = widget._trailingBuilder;
    _onDestinationSelectedCommon = widget._onDestinationSelected;
    _controller = widget._controller;
    _controller?.binding(this);
     _classify(widget._destinationDataList);
  }


  @override
  Widget build(BuildContext context) {
    var destinations = _convertToDestination(_destList, context);
    _navigationRail = NavigationRail(
      destinations: destinations,
      selectedIndex: _selectIndex,
      onDestinationSelected: _onDestinationSelected,
      leading: const SizedBox(
        height: 26,
      ),
      trailing: _buildTrailingArea(_trailingList, context),

      /// 样式部分：
      minWidth: _width,
      backgroundColor: _bgColor(context),
      unselectedIconTheme: _unselectedIconTheme(context),
    );
    return _navigationRail!;
  }

  void _onDestinationSelected(index) {
    var destData = _destList[index];
    if (destData.destinationSelected != null) {
      destData.destinationSelected!(index, context);
    } else {
      _onDestinationSelectedCommon(index, _destList[index], context);
    }
    setState(() {
      _selectIndex = index;
    });
  }

  void _classify(List<NaviRailDestData> destinationDataList) {
    destinationDataList.sort((el, elNext) {
      var compareTo = el.sort.compareTo(elNext.sort);
      return compareTo == 0 ? el.key.compareTo(elNext.key) : compareTo;
    });
    for (var element in destinationDataList) {
      switch (element.areaIn) {
        case DesktopNaviArea.destination:
          _destList.add(element);
          break;
        case DesktopNaviArea.trailing:
          _trailingList.add(element);
          break;
      }
    }
  }

  List<NavigationRailDestination> _convertToDestination(
      List<NaviRailDestData> dataList, BuildContext buildContext) {
    List<NavigationRailDestination> destinationList = [];
    for (NaviRailDestData data in dataList) {
      if (Const.disable == data.able) {
        continue;
      }
      destinationList.add(_destinationBuilder(data, buildContext));
    }
    return destinationList;
  }

  Widget _buildTrailingArea(
      List<NaviRailDestData> dataList, BuildContext buildContext) {
    if (dataList.isEmpty) {
      return const Spacer();
    }
    return Expanded(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(children: [
          const Spacer(),
          _divider(buildContext),
          ..._convertToTrailing(_trailingList, buildContext)
        ]),
      ),
    ));
  }

  Widget _divider(BuildContext buildContext){
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: _width , minWidth: _width*0.9 , minHeight: 4, maxHeight: 6),
      child: Center(child: Divider(color: Theme.of(buildContext).dividerColor ,indent: 4,endIndent: 4,),)
    );
  }

  List<Widget> _convertToTrailing(
      List<NaviRailDestData> dataList, BuildContext buildContext) {
    List<Widget> trailing = [];
    for (NaviRailDestData data in dataList) {
      if (data.able == Const.disable) {
        continue;
      }
      trailing.add(_trailingBuilder(data, buildContext));
    }
    return trailing;
  }

  Color _bgColor(BuildContext buildContext) {
    ThemeData themeData = Theme.of(context);
    Color primaryColor = themeData.primaryColor;
    return (primaryColor is MaterialColor)
        ? primaryColor.shade900
        : themeData.colorScheme.secondary;
  }

  IconThemeData _unselectedIconTheme(BuildContext buildContext) {
    return IconThemeData(color: Theme.of(context).colorScheme.surface);
  }
}

DestinationBuilder defaultDestinationBuilder =
    (NaviRailDestData destData, BuildContext buildContextNavi) {
  var tooltipIcon = Tooltip(
    message: destData.label,
    child: Icon(destData.iconData),
  );
  return NavigationRailDestination(
      icon: tooltipIcon, label: Text(destData.label));
};

TrailingBuilder defaultTrailingBuilder =
    (NaviRailDestData destData, BuildContext buildContextNavi) {
  return Tooltip(
    message: destData.label,
    child: IconButton(
      onPressed: () {
        destData.destinationSelected?.call(-1, buildContextNavi);
      },
      icon: Icon(
        destData.iconData,
        color: Theme.of(buildContextNavi).colorScheme.surface,
      ),
    ),
  );

};
