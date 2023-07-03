import 'package:logger/logger.dart';

/// 避免无谓的创建 Logger 对象
class StaticLogger{
  static final Logger _logger = Logger();

  static void i (dynamic message, [dynamic error, StackTrace? stackTrace]){
    _logger.i(message,error,stackTrace);
  }
}