import 'package:json_annotation/json_annotation.dart';
import 'package:timeline/cn/wendx/config/json_converter.dart';
import 'package:timeline/cn/wendx/model/base_model.dart';
import 'package:timeline/cn/wendx/util/id_generator.dart';

import '../config/sys_constant.dart';

part 'timeline.g.dart';

@JsonSerializable()
@DateTimeEpochConverter()
class Timeline
    with BaseDbModel<Timeline>, BaseJsonModel<Timeline> {
  int id;

  DateTime createTime;

  DateTime modifyTime;

  String contentRich;

  String contentText;

  String contentNormalize;

  int version;

  int delStatus;

  factory Timeline.fromJson(Map<String, dynamic> json){
    return _$TimelineFromJson(json);
  }

  factory Timeline.create(String contentText, {int? id, String? contentRich}){
    return Timeline(id: id ?? IdGen.id(),
        createTime: DateTime.now(),
        modifyTime: DateTime.now(),
        contentRich: contentRich??contentText,
        contentText: contentText,
        contentNormalize:contentText,
        version:1,
        delStatus:Const.notDel);
  }

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

  @override
  Map<String, dynamic> toJson() => _$TimelineToJson(this);

  Timeline updateMerge(Timeline timeline, {bool versionChange = true}){
    if(versionChange){
      version = version + 1;
    }
    contentRich = timeline.contentRich;
    contentText = timeline.contentRich;
    contentNormalize = timeline.contentNormalize;
    return this;
  }
}
