import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ip2region_ffi_platform_interface.dart';

/// An implementation of [Ip2regionFfiPlatform] that uses method channels.
class MethodChannelIp2regionFfi extends Ip2regionFfiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ip2region_ffi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
