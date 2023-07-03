import 'package:timeline/cn/wendx/model/sys_config.dart';

abstract class SysConfigRepository{
  Future<SysConfig> read(String key);

  Future<List<SysConfig>> readAll();


  Future<SysConfig> write(SysConfig sysConfig);
  
  Future<List<SysConfig>> writeBatch(List<SysConfig> configList);
}