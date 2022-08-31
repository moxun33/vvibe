import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ip2region_ffi_method_channel.dart';

abstract class Ip2regionFfiPlatform extends PlatformInterface {
  /// Constructs a Ip2regionFfiPlatform.
  Ip2regionFfiPlatform() : super(token: _token);

  static final Object _token = Object();

  static Ip2regionFfiPlatform _instance = MethodChannelIp2regionFfi();

  /// The default instance of [Ip2regionFfiPlatform] to use.
  ///
  /// Defaults to [MethodChannelIp2regionFfi].
  static Ip2regionFfiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Ip2regionFfiPlatform] when
  /// they register themselves.
  static set instance(Ip2regionFfiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getIpInfo(String ip, String dbPath) {
    throw UnimplementedError('getIpInfo() has not been implemented.');
  }
}
