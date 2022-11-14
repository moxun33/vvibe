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
    final tex = await methodChannel.invokeMethod('CreateRT',
        'https://d1--cn-gotcha208.bilivideo.com/live-bvc/275726/live_456924462_14930225/index.m3u8?expires=1653485915&len=0&oi=456067383&pt=h5&qn=10000&trid=1007d528083591d249e6b95f4954355021c0&sigparams=cdn,expires,len,oi,pt,qn,trid??cdn=cn-gotcha208&sign=3b287b4888ed2eb135e9c69b73d1ce7a&sk=fc56af96f7ffed4f53ff8d86c37dc191&p2p_type=0&src=852096&sl=3&free_type=0&flowtype=1&machinezone=jd&pp=rtmp&source=onetier&order=1&site=bdc4320b31f7a355f6e0708ad76f570b');
    return tex;
  }
}
