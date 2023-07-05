import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/service/base_service.dart';

abstract class SysConfigService extends BaseService{
  Future<SysConfig> read(String key);

  Future<List<SysConfig>> readByParent(String parentKey);

  Future<List<SysConfig>> readAll();

  Future<Map<String,SysConfig>> readAllAsMap();

  Future<SysConfig> write(SysConfig sysConfig);

  Future<List<SysConfig>> writeBatch(List<SysConfig> configList);

  Future refresh();
}