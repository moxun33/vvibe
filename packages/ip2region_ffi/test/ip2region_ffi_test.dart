import 'package:flutter_test/flutter_test.dart';
import 'package:ip2region_ffi/ip2region_ffi.dart';
import 'package:ip2region_ffi/ip2region_ffi_platform_interface.dart';
import 'package:ip2region_ffi/ip2region_ffi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIp2regionFfiPlatform
    with MockPlatformInterfaceMixin
    implements Ip2regionFfiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getIpInfo(String ip, String dbPath) => Future.value('2');
}

void main() {
  final Ip2regionFfiPlatform initialPlatform = Ip2regionFfiPlatform.instance;

  test('$MethodChannelIp2regionFfi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIp2regionFfi>());
  });

  test('getPlatformVersion', () async {
    Ip2regionFfi ip2regionFfiPlugin = Ip2regionFfi();
    MockIp2regionFfiPlatform fakePlatform = MockIp2regionFfiPlatform();
    Ip2regionFfiPlatform.instance = fakePlatform;

    expect(await ip2regionFfiPlugin.getPlatformVersion(), '42');
  });

  test('getIpInfo', () async {
    Ip2regionFfi ip2regionFfiPlugin = Ip2regionFfi();
    MockIp2regionFfiPlatform fakePlatform = MockIp2regionFfiPlatform();
    Ip2regionFfiPlatform.instance = fakePlatform;

    expect(await ip2regionFfiPlugin.getIpInfo('10.40.39.33', 'ip.xdb'), '2');
  });
}
