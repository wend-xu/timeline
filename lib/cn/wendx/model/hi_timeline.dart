import 'package:timeline/cn/wendx/model/base_model.dart';

class Timeline with BaseDbModel{
  int id;

  DateTime createTime;

  DateTime modifyTime;

  String contentRich;

  String contentText;

  String contentNormalize;

  int version;

  int delStatus;

  Timeline({
    required this.id,
    required this.createTime,
    required this.modifyTime,
    required this.contentRich,
    required this.contentText,
    required this.contentNormalize,
    required this.version,
    required this.delStatus,
  });

  Timeline copyWith({
    int? id,
    DateTime? createTime,
    DateTime? modifyTime,
    String? contentRich,
    String? contentText,
    String? contentNormalize,
    int? version,
    int? delStatus,
  }) {
    return Timeline(
      id: id ?? this.id,
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
