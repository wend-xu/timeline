// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sys_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SysConfig _$SysConfigFromJson(Map<String, dynamic> json) => SysConfig(
      json['id'] as int,
      json['key'] as String,
      json['value'] as String,
      json['pid'] as int,
      json['level'] as int,
      json['sort'] as int,
      json['extras'] as String,
      json['description'] as String,
      const DateTimeEpochConverter().fromJson(json['createTime'] as int),
      const DateTimeEpochConverter().fromJson(json['modifyTime'] as int),
      json['delStatus'] as int,
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
