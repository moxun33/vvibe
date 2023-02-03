//直播源扫描util
import 'package:dio/dio.dart';
import 'package:vvibe/common/values/values.dart';

class SniffUtil {
  static SniffUtil _instance = new SniffUtil._();
  factory SniffUtil() => _instance;

  SniffUtil._();

  final client = Dio(BaseOptions(headers: {'User-Agnet': DEF_REQ_UA}));
}
