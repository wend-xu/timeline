import 'package:logger/logger.dart';

mixin IocRegister<T> {
  void register(T instance);
}

mixin IocRegisterHelper {
  final Logger _l = Logger();

  List registerList();

  void registerToIoc() {
    for (var register in registerList()) {
      var isIocReg = register is IocRegister;
      _l.i(
          "准备注册 【${register.runtimeType.toString()}】到IOC容器，是否为IocRegister： $isIocReg ");
      if (isIocReg) {
        (register as IocRegister).register(register);
      }
    }
  }
}
