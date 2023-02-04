/*
 * @Author: Moxx
 * @Date: 2022-09-15 15:59:57
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-04 18:12:30
 * @FilePath: \vvibe\lib\utils\ffi_util.dart
 * @Description: 
 * @qmj
 */
import 'dart:convert';
import 'dart:ffi';

import 'dart:io';
import 'package:vvibe/bridge_generated.dart';
import 'package:vvibe/models/media_info.dart';

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
  Future<MediaInfo?> getMediaInfo(String url) async {
    try {
      String raw = await api.getMediaInfo(
          url: url, ffprobeDir: '${Directory('assets').path}/ffprobe.exe');
      MediaInfo info = MediaInfo.fromJson(jsonDecode(raw));
      return info;
    } catch (e) {
      return null;
    }
  }
}
