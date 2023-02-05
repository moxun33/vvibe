/*
 * @Author: Moxx
 * @Date: 2022-09-15 15:59:57
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-05 17:23:36
 * @FilePath: \vvibe\lib\utils\ffi_util.dart
 * @Description: 
 * @qmj
 */
import 'dart:convert';
import 'dart:ffi';

import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/bridge_generated.dart';
import 'package:vvibe/common/values/values.dart';
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

//解析ip地址信息
  Future<String?> getIpInfo(String ip) async {
    try {
      String dir = Directory.current.path;
      print('app dir $dir');
      String addr = await api.getIpInfo(
          ip: ip, dbPath: File('${ASSETS_DIR}/ip2region.xdb').path);
      return addr.replaceAll('0|', '');
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

//获取url的媒体元数据
  Future<MediaInfo?> getMediaInfo(String url) async {
    try {
      String raw = await api.getMediaInfo(
          url: url, ffprobeDir: '${Directory(ASSETS_DIR).path}/ffprobe.exe');
      MediaInfo info = MediaInfo.fromJson(jsonDecode(raw));
      return info;
    } catch (e) {
      EasyLoading.showError(e.toString());
      return null;
    }
  }
}
