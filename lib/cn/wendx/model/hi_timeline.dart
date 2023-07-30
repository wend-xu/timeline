import 'package:json_annotation/json_annotation.dart';
import 'package:timeline/cn/wendx/model/base_model.dart';

import '../config/json_converter.dart';

part 'hi_timeline.g.dart';


@JsonSerializable()
@DateTimeEpochConverter()
class HiTimeline with BaseDbModel{
  int id;

  int tId;

  DateTime createTime;

  DateTime modifyTime;

  String contentRich;

  String contentText;

  String contentNormalize;

  int version;

  int delStatus;

  HiTimeline({
    required this.id,
    required this.tId,
    required this.createTime,
    required this.modifyTime,
    required this.contentRich,
    required this.contentText,
    required this.contentNormalize,
    required this.version,
    required this.delStatus,
  });

  HiTimeline copyWith({
    int? id,
    int? tId,
    DateTime? createTime,
    DateTime? modifyTime,
    String? contentRich,
    String? contentText,
    String? contentNormalize,
    int? version,
    int? delStatus,
  }) {
    return HiTimeline(
      id: id ?? this.id,
      tId: tId ?? this.tId,
      createTime: createTime ?? this.createTime,
      modifyTime: modifyTime ?? this.modifyTime,
      contentRich: contentRich ?? this.contentRich,
      contentText: contentText ?? this.contentText,
      contentNormalize: contentNormalize ?? this.contentNormalize,
      version: version ?? this.version,
      delStatus: delStatus ?? this.delStatus,
    );
  }
}
