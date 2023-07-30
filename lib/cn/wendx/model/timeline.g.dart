// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timeline _$TimelineFromJson(Map<String, dynamic> json) => Timeline(
      id: json['id'] as int,
      createTime:
          const DateTimeEpochConverter().fromJson(json['createTime'] as int),
      modifyTime:
          const DateTimeEpochConverter().fromJson(json['modifyTime'] as int),
      contentRich: json['contentRich'] as String,
      contentText: json['contentText'] as String,
      contentNormalize: json['contentNormalize'] as String,
      version: json['version'] as int,
      delStatus: json['delStatus'] as int,
    );

Map<String, dynamic> _$TimelineToJson(Timeline instance) => <String, dynamic>{
      'id': instance.id,
      'createTime': const DateTimeEpochConverter().toJson(instance.createTime),
      'modifyTime': const DateTimeEpochConverter().toJson(instance.modifyTime),
      'contentRich': instance.contentRich,
      'contentText': instance.contentText,
      'contentNormalize': instance.contentNormalize,
      'version': instance.version,
      'delStatus': instance.delStatus,
    };
