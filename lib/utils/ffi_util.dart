import 'dart:io';

import 'package:ip2region_ffi/ip2region_ffi.dart';

class FfiUtil {
  static FfiUtil _instance = new FfiUtil._();
  factory FfiUtil() => _instance;

  FfiUtil._();

  final _ip2regionFfiPlugin = Ip2regionFfi();

  Future<String?> getIpInfo(String ip) {
    return _ip2regionFfiPlugin.getIpInfo(ip, File('assets/ip2region.xdb').path);
  }
}
