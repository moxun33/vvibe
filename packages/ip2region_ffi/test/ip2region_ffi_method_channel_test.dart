import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ip2region_ffi/ip2region_ffi_method_channel.dart';

void main() {
  MethodChannelIp2regionFfi platform = MethodChannelIp2regionFfi();
  const MethodChannel channel = MethodChannel('ip2region_ffi');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
