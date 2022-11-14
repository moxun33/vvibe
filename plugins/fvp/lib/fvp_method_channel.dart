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
  Future<int> setMedia(String url) async {
    final v = await methodChannel.invokeMethod('setMedia', {'url': url});
    return v as int;
  }
}
