import 'dart:ffi';

import 'fvp_platform_interface.dart';

class Fvp {
  Future<String?> getPlatformVersion() {
    return FvpPlatform.instance.getPlatformVersion();
  }

  Future<int> createTexture() {
    return FvpPlatform.instance.createTexture();
  }

  Future<int> setMedia(String url) {
    return FvpPlatform.instance.setMedia(url);
  }

  Future<int> playOrPause() {
    return FvpPlatform.instance.playOrPause();
  }

//{audio: {codec: {bit_rate: 327680, block_align: 0, channels: 2, codec: aac, frame_rate: 0.0, frame_size: 1024, level: -99, profile: 1, raw_sample_size: 4}, duration: -9223372036854775807, frames: 0, index: 0, metadata: {}, start_time: 76378666}, bit_rate: 44025, duration: 19631, metadata: {}, size: 0, start_time: 76378666, streams: 2, video: {codec: {bit_rate: 6144000, codec: h264, format: 43, format_name: yuv420p, frame_rate: 30.0, height: 1080, level: 40, profile: 100, width: 1920}, duration: -9223372036854775807, frames: 0, index: 1, metadata: {}, rotation: 0, start_time: 76378729}}
  Future<Map<String, dynamic>> getMediaInfo() async {
    return FvpPlatform.instance.getMediaInfo();
  }

  Future<int> setValume(double v) {
    return FvpPlatform.instance.setVolume(v);
  }

  Future<int> setMute(bool v) {
    return FvpPlatform.instance.setMute(v);
  }
}
