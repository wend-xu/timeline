// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sys_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SysConfig _$SysConfigFromJson(Map<String, dynamic> json) => SysConfig(
      id: json['id'] as int,
      key: json['key'] as String,
      value: json['value'] as String,
      pid: json['pid'] as int,
      level: json['level'] as int,
      sort: json['sort'] as int,
      extras: json['extras'] as String,
      description: json['description'] as String,
      createTime:
          const DateTimeEpochConverter().fromJson(json['createTime'] as int),
      modifyTime:
          const DateTimeEpochConverter().fromJson(json['modifyTime'] as int),
      delStatus: json['delStatus'] as int,
    );

Map<String, dynamic> _$SysConfigToJson(SysConfig instance) => <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'pid': instance.pid,
      'level': instance.level,
      'sort': instance.sort,
      'extras': instance.extras,
      'description': instance.description,
      'createTime': const DateTimeEpochConverter().toJson(instance.createTime),
      'modifyTime': const DateTimeEpochConverter().toJson(instance.modifyTime),
      'delStatus': instance.delStatus,
    };
