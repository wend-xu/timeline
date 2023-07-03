import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/model/sys_config.dart';
import 'package:timeline/cn/wendx/repo/sys_config_repository.dart';
import 'package:timeline/cn/wendx/service/sys_config_service.dart';

/// 由于使用了内存缓存，所以所有的操作
class SysConfigServiceImpl extends SysConfigService with IocRegister {
  SysConfigRepository sysConfigRepository;

  List<SysConfig> _allConfigCache = [];

  Map<String, SysConfig?> _allConfigMapCache = {};

  SysConfigServiceImpl._(this.sysConfigRepository);

  Future _asyncInit() async {
    _allConfigCache = await sysConfigRepository.readAll();
    _allConfigMapCache = _allConfigCache.fold({}, (map, element) {
      map[element.key] = element;
      return map;
    });
  }

  static Future<SysConfigService> instance({bool init = true}) async {
    var configRepository = GetIt.instance.get<SysConfigRepository>();
    var sysConfigServiceImpl = SysConfigServiceImpl._(configRepository);
    if (init) {
      await sysConfigServiceImpl._asyncInit();
    }
    return sysConfigServiceImpl;
  }

  @override
  void register(instance) {
    GetIt.instance.registerSingleton<SysConfigService>(instance);
  }

  @override
  Future<SysConfig> read(String key) async {
    SysConfig? sysConfig = _allConfigMapCache[key];
    if (sysConfig == null) {
      sysConfig = await sysConfigRepository.read(key);
      _diffAndCoherencyCache([sysConfig]);
    }
    return sysConfig.copy();
  }

  // 使用深拷贝返回
  @override
  Future<Map<String, SysConfig>> readAllAsMap() async {
    Map<String, SysConfig> fold = _allConfigCache.fold({}, (map, element) {
      SysConfig copy = element.copy();
      map[copy.key] = copy;
      return map;
    });
    return fold;
  }

  @override
  Future<List<SysConfig>> readAll() async {
    List<SysConfig> copyList = _allConfigCache.fold([], (copy, element) {
      copy.add(element.copy());
      return copy;
    });
    return copyList;
  }

  @override
  Future<SysConfig> write(SysConfig sysConfig) async {
    sysConfig = await sysConfigRepository.write(sysConfig);
    _diffAndCoherencyCache([sysConfig]);
    return sysConfig;
  }

  @override
  Future<List<SysConfig>> writeBatch(List<SysConfig> configList) async {
    List<SysConfig> sysConfigList =
        await sysConfigRepository.writeBatch(configList);
    _diffAndCoherencyCache(sysConfigList);
    return sysConfigList;
  }

  void _diffAndCoherencyCache(List<SysConfig> sysConfigList) {
    for (SysConfig sysConfig in sysConfigList) {
      if (sysConfig.exist()) {
        _allConfigMapCache[sysConfig.key] = sysConfig;
      }
    }
    _allConfigCache = _allConfigMapCache.values.whereType<SysConfig>().toList();
  }
}