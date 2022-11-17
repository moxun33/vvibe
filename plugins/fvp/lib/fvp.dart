import 'dart:ffi';

import 'package:fvp/fvp_utils.dart';

import 'fvp_platform_interface.dart';
export 'fvp_utils.dart';

class Fvp {
  Future<String?> getPlatformVersion() {
    return FvpPlatform.instance.getPlatformVersion();
  }

  Future<int> createTexture() {
    return FvpPlatform.instance.createTexture();
  }

  Future<int> setMedia(String url) {
    return FvpPlatform.instance.setMedia(url.trim());
  }

  Future<int> playOrPause() {
    return FvpPlatform.instance.playOrPause();
  }

//{audio: {codec: {bit_rate: 327680, block_align: 0, channels: 2, codec: aac, frame_rate: 0.0, frame_size: 1024, level: -99, profile: 1, raw_sample_size: 4}, duration: -9223372036854775807, frames: 0, index: 0, metadata: {}, start_time: 76378666}, bit_rate: 44025, duration: 19631, metadata: {}, size: 0, start_time: 76378666, streams: 2, video: {codec: {bit_rate: 6144000, codec: h264, format: 43, format_name: yuv420p, frame_rate: 30.0, height: 1080, level: 40, profile: 100, width: 1920}, duration: -9223372036854775807, frames: 0, index: 1, metadata: {}, rotation: 0, start_time: 76378729}}
  Future<Map<String, dynamic>?> getMediaInfo() async {
    return FvpPlatform.instance.getMediaInfo();
  }

  Future<int> setVolume(double v) {
    return FvpPlatform.instance.setVolume(v);
  }

  Future<int> setMute(bool v) {
    return FvpPlatform.instance.setMute(v);
  }

  Future<int> setTimeout(int v) {
    return FvpPlatform.instance.setTimeout(v);
  }

/* enum   State : int {
    NotRunning,
    Stopped = NotRunning,
    Running,
    Playing = Running, /// start/resume to play
    Paused,
}; */
  Future<int> getState() async {
    return FvpPlatform.instance.getState();
  }

/* enum MediaStatus
{
    NoMedia = 0, // initial status, not invalid. // what if set an empty url and closed?
    Unloaded = 1, // unloaded // (TODO: or when a source(url) is set?)
    Loading = 1<<1, // opening and parsing the media
    Loaded = 1<<2, // media is loaded and parsed. player is stopped state. mediaInfo() is available now
    Prepared = 1<<8, // all tracks are buffered and ready to decode frames. tracks failed to open decoder are ignored
    Stalled = 1<<3, // insufficient buffering or other interruptions (timeout, user interrupt)
    Buffering = 1<<4, // when buffering starts
    Buffered = 1<<5, // when buffering ends
    End = 1<<6, // reached the end of the current media, no more data to read
    Seeking = 1<<7,
    Invalid = 1<<31, // failed to load media because of unsupport format or invalid media source
}; */
  Future<int> getStatus() {
    return FvpPlatform.instance.getStatus();
  }

  Future<String?> snapshot() {
    return FvpPlatform.instance.snapshot();
  }

  Future<double> volume() {
    return FvpPlatform.instance.volume();
  }

  Future<int> stop() {
    return FvpPlatform.instance.stop();
  }

  Future<int> setUserAgent(String? ua) {
    return FvpPlatform.instance.setUserAgent(ua);
  }

  void onStateChanged(void Function(String state)? cb) {
    return FvpPlatform.instance.onStateChanged(cb);
  }

  void onMediaStatusChanged(void Function(String status)? cb) {
    return FvpPlatform.instance.onMediaStatusChanged(cb);
  }

  void onEvent(void Function(Map<String, dynamic> data)? cb) {
    return FvpPlatform.instance.onEvent(cb);
  }
}
