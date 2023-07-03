import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeline/cn/wendx/config/json_converter.dart';
import 'package:timeline/cn/wendx/config/sys_constant.dart';
import 'package:timeline/cn/wendx/model/base_model.dart';
import 'package:timeline/cn/wendx/util/snow_flake.dart';

part 'sys_config.g.dart';

@JsonSerializable()
@DateTimeEpochConverter()
class SysConfig with BaseJsonModel<SysConfig>, BaseDbModel {
  int id;
  String key;
  String value;
  int pid;

  int level;

  int sort;

  String extras;

  String description;

  DateTime createTime;

  DateTime modifyTime;

  int delStatus;

  SysConfig(
      this.id,
      this.key,
      this.value,
      this.pid,
      this.level,
      this.sort,
      this.extras,
      this.description,
      this.createTime,
      this.modifyTime,
      this.delStatus);

  factory SysConfig.formJson(Map<String, dynamic> json) {
    return _$SysConfigFromJson(json);
  }

  SysConfig.create(this.key, this.value,
      {int? id,
      this.pid = 0,
      this.level = 1,
      this.sort = 0,
      this.extras = "{}",
      this.description = "",
      DateTime? createTime,
      DateTime? modifyTime,
      this.delStatus = Const.notDel})
      : id = id ?? Snowflake.id(),
        createTime = createTime ?? DateTime.now(),
        modifyTime = modifyTime ?? DateTime.now();

  factory SysConfig.notExist(String key) {
    var sysConfig = SysConfig.create(key, "");
    sysConfig.exist(exist: false);
    return sysConfig;
  }

  @override
  SysConfig fromJSon(Map<String, dynamic> json) {
    return _$SysConfigFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$SysConfigToJson(this);
  }

  SysConfig doUpdate(SysConfig newValue) {
    value = newValue.value;
    extras = newValue.extras;

    pid = newValue.pid;
    sort = newValue.sort;
    level = newValue.level;
    modifyTime = DateTime.now();
    return this;
  }

  SysConfig child(key, value,
      {sort = 0,
      extras = "{}",
      description = "",
      DateTime? createTime,
      DateTime? modifyTime,
      delStatus = Const.notDel}) {
    return SysConfig.create(key, value,
        pid: id,
        level: level + 1,
        sort: sort,
        extras: extras,
        description: description);
  }

  SysConfig copy(){
    return SysConfig.formJson(toJson());
  }
}