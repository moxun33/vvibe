import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fvp_platform_interface.dart';

/// An implementation of [FvpPlatform] that uses method channels.
class MethodChannelFvp extends FvpPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fvp');

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
  Future<dynamic> getMediaInfo() async {
    return methodChannel.invokeMethod('getMediaInfo');
  }
}
