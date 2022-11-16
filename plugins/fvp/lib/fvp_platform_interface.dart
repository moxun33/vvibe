import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fvp_method_channel.dart';

abstract class FvpPlatform extends PlatformInterface {
  /// Constructs a FvpPlatform.
  FvpPlatform() : super(token: _token);

  static final Object _token = Object();

  static FvpPlatform _instance = MethodChannelFvp();

  /// The default instance of [FvpPlatform] to use.
  ///
  /// Defaults to [MethodChannelFvp].
  static FvpPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FvpPlatform] when
  /// they register themselves.
  static set instance(FvpPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> createTexture() {
    throw UnimplementedError('createTexture() has not been implemented.');
  }

  Future<int> setMedia(String url) {
    throw UnimplementedError('setMedia() has not been implemented.');
  }

  Future<int> playOrPause() {
    throw UnimplementedError('playOrPause() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getMediaInfo() {
    throw UnimplementedError('getMediaInfo() has not been implemented.');
  }

  Future<int> setVolume(double v) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  Future<int> setMute(bool v) {
    throw UnimplementedError('setMute() has not been implemented.');
  }

  Future<int> setTimeout(int v) {
    throw UnimplementedError('setTimeout() has not been implemented.');
  }

  Future<int> getState() {
    throw UnimplementedError('getState() has not been implemented.');
  }

  Future<int> getStatus() {
    throw UnimplementedError('getStatus() has not been implemented.');
  }

  Future<String?> snapshot() {
    throw UnimplementedError('snapshot() has not been implemented.');
  }

  Future<int> setUserAgent(String? ua) {
    throw UnimplementedError('setUserAgent() has not been implemented.');
  }

  void onStateChanged(void Function(String state)? cb) {
    throw UnimplementedError('onStateChanged() has not been implemented.');
  }

  void onMediaStatusChanged(void Function(String status)? cb) {
    throw UnimplementedError(
        'onMediaStatusChanged() has not been implemented.');
  }

  void onEvent(void Function(Map<String, dynamic> data)? cb) {
    throw UnimplementedError(
        'onMediaStatusChanged() has not been implemented.');
  }
}
