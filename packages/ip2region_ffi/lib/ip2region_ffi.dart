// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'ip2region_ffi_platform_interface.dart';
import 'dart:ffi';

import 'bridge_generated.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'bridge_generated.dart';
import 'dart:io' as io;

const _base = 'native';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.
final _dylib = io.Platform.isWindows ? '$_base.dll' : 'lib$_base.so';

final Native api = NativeImpl(io.Platform.isIOS || io.Platform.isMacOS
    ? DynamicLibrary.executable()
    : DynamicLibrary.open(_dylib));

class Ip2regionFfi {
  Future<String?> getPlatformVersion() {
    return Ip2regionFfiPlatform.instance.getPlatformVersion();
  }

  Future<String?> getIpInfo(String ip, String dbPath) {
    return api.getIpInfo(ip: ip, dbPath: dbPath);
  }
}
