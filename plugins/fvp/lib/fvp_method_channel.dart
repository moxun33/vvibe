import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fvp_platform_interface.dart';

/// An implementation of [FvpPlatform] that uses method channels.
class MethodChannelFvp extends FvpPlatform {
  MethodChannelFvp._() {
    methodChannel.setMethodCallHandler(methodCallHandler);
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fvp');

  @override
  Future<void> methodCallHandler(MethodCall call) async {}

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int> createTexture() async {
    final tex = await methodChannel.invokeMethod('CreateRT');
    return tex;
  }

  @override
  Future<int> setMedia(String? url) async {
    if (!(url != null && url.isNotEmpty)) {
      return 0;
      // throw ArgumentError('url 不能为空');
    }
    return (await methodChannel.invokeMethod('setMedia', {'url': url})) as int;
  }

  @override
  Future<int> playOrPause() async {
    return (await methodChannel.invokeMethod('playOrPause')) as int;
  }

  @override
  Future<Map<String, dynamic>?> getMediaInfo() async {
    try {
      return Map<String, dynamic>.from(
          await methodChannel.invokeMethod('getMediaInfo'));
    } catch (e) {
      return null;
    }
  }

//v: 0 , 0.5,0.6, 1.0
  @override
  Future<int> setVolume(double v) async {
    return (await methodChannel.invokeMethod(
        'setVolume', {'volume': v > 0 && v <= 1 ? v : 1.0}) as int);
  }

  @override
  Future<int> setMute(bool? v) async {
    return (await methodChannel.invokeMethod('setMute', {'mute': v ?? true})
        as int);
  }

  //v： ms
  @override
  Future<int> setTimeout(int? v) async {
    return (await methodChannel.invokeMethod('setTimeout', {'time': v ?? 10000})
        as int);
  }

  @override
  Future<int> getState() async {
    return (await methodChannel.invokeMethod('getState') as int);
  }

  @override
  Future<int> getStatus() async {
    return (await methodChannel.invokeMethod('getStatus') as int);
  }

  @override
  Future<String?> snapshot() async {
    try {
      return methodChannel.invokeMethod('snapshot');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> setUserAgent(String? ua) async {
    return (await methodChannel
        .invokeMethod('setUserAgent', {'ua': ua ?? 'VVibe ZTE'}) as int);
  }
}
