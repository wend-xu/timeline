// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navi_rail_dest_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaviRailDestData _$NaviRailDestDataFromJson(Map<String, dynamic> json) =>
    NaviRailDestData(
      key: json['key'] as String,
      areaIn: $enumDecode(_$DesktopNaviAreaEnumMap, json['areaIn']),
      able: $enumDecode(_$AbleEnumMap, json['able']),
      iconData: const IconDataConverter()
          .fromJson(json['iconData'] as Map<String, dynamic>),
      sort: json['sort'] as int,
      label: json['label'] as String,
      selectedIcon: _$JsonConverterFromJson<Map<String, dynamic>, IconData>(
          json['selectedIcon'], const IconDataConverter().fromJson),
      selectedLabel: json['selectedLabel'] as String?,
    );

Map<String, dynamic> _$NaviRailDestDataToJson(NaviRailDestData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'areaIn': _$DesktopNaviAreaEnumMap[instance.areaIn]!,
      'able': _$AbleEnumMap[instance.able]!,
      'iconData': const IconDataConverter().toJson(instance.iconData),
      'sort': instance.sort,
      'label': instance.label,
      'selectedIcon': _$JsonConverterToJson<Map<String, dynamic>, IconData>(
          instance.selectedIcon, const IconDataConverter().toJson),
      'selectedLabel': instance.selectedLabel,
    };

const _$DesktopNaviAreaEnumMap = {
  DesktopNaviArea.destination: 'destination',
  DesktopNaviArea.trailing: 'trailing',
};

const _$AbleEnumMap = {
  Able.enable: 'enable',
  Able.disable: 'disable',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
