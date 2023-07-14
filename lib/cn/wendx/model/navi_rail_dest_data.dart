import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeline/cn/wendx/config/json_converter.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/base_model.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';

part 'navi_rail_dest_data.g.dart';

/// 构建 [NavigationRailDestination] 的配置数据
@JsonSerializable()
@IconDataConverter()
class NaviRailDestData with BaseJsonModel<NaviRailDestData> {
  String key;

  DesktopNaviArea areaIn;

  Able able;

  IconData iconData;

  int sort;

  String label;

  IconData? selectedIcon;

  String? selectedLabel;

  @JsonKey(includeFromJson: false, includeToJson: false)
  ValueChanged<int>? destinationSelected;

  @override
  Map<String, dynamic> toJson() {
    return _$NaviRailDestDataToJson(this);
  }

  factory NaviRailDestData.fromJson(Map<String, dynamic> json) {
    return _$NaviRailDestDataFromJson(json);
  }

  factory NaviRailDestData.fromConfig(SysConfig config) {
    return NaviRailDestData.fromJson(config.mapValue());
  }

  SysConfig toConfig(){
    return SysConfig.createWithMapValue(key,toJson(),sort: sort);
  }

  NaviRailDestData.create(this.key,this.iconData,this.label,{
    this.areaIn = DesktopNaviArea.destination,
    this.able = Const.enable,
    this.sort = 0,
    this.selectedIcon,
    this.selectedLabel,
    this.destinationSelected,
  });

  NaviRailDestData({
    required this.key,
    required this.areaIn,
    required this.able,
    required this.iconData,
    required this.sort,
    required this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.destinationSelected,
  });

  NaviRailDestData copyWith({
    String? key,
    DesktopNaviArea? areaIn,
    Able? able,
    IconData? iconData,
    int? sort,
    String? label,
    IconData? selectedIcon,
    String? selectedLabel,
    ValueChanged<int>? destinationSelected,
  }) {
    return NaviRailDestData(
      key: key ?? this.key,
      areaIn: areaIn ?? this.areaIn,
      able: able ?? this.able,
      iconData: iconData ?? this.iconData,
      sort: sort ?? this.sort,
      label: label ?? this.label,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      destinationSelected: destinationSelected ?? this.destinationSelected,
    );
  }
}
