import 'dart:ffi';

import 'dart:io';
import 'package:vvibe/bridge_generated.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'package:vvibe/bridge_generated.dart';

const _base = 'native';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.
final _dylib = Platform.isWindows ? '$_base.dll' : 'lib$_base.so';

final Native api = NativeImpl(Platform.isIOS || Platform.isMacOS
    ? DynamicLibrary.executable()
    : DynamicLibrary.open(_dylib));

class FfiUtil {
  static FfiUtil _instance = new FfiUtil._();
  factory FfiUtil() => _instance;

  FfiUtil._();

  Future<String?> getIpInfo(String ip) async {
    String addr =
        await api.getIpInfo(ip: ip, dbPath: File('assets/ip2region.xdb').path);
    return addr.replaceAll('0|', '');
  }

//获取url的媒体元数据
  Future<String?> getMediaInfo(String url) async {
    String info =
        await api.getMediaInfo(url: url, ffprobeDir: Directory('assets/').path);
    print(info);
    return info;
  }
}
