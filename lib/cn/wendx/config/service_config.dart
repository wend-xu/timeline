
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:timeline/cn/wendx/config/get_it_helper.dart';
import 'package:timeline/cn/wendx/repo/impl/sys_config_repository_impl.dart';
import 'package:timeline/cn/wendx/repo/sys_config_repository.dart';
import 'package:timeline/cn/wendx/service/base_service.dart';
import 'package:timeline/cn/wendx/service/impl/sys_config_service_impl.dart';

Future registerService() async {
  var serviceInitHelper = ServiceInitHelper([
    await SysConfigServiceImpl.instance()
  ]);

  serviceInitHelper.registerToIoc();
}

class ServiceInitHelper with IocRegisterHelper {

  List<BaseService> serviceList ;

  ServiceInitHelper(this.serviceList);
  @override
  List registerList() => serviceList;
}