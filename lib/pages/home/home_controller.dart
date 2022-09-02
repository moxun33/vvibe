import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/global.dart';

class HomeController extends GetxController {
  Player? player;
  bool playListShowed = false;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    player = Player(
        id: 1,
        commandlineArguments: [],
        registerTexture: !(Global.isRelease && Platform.isWindows));
  }

  @override
  void onReady() {
    //final url = 'http://27.47.71.53:808/hls/1/index.m3u8';
    final url = 'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8';
    startPlay(url);
  }

  void startPlay(String url) {
    EasyLoading.show();
    MediaSource media = Media.network(url, parse: true);
    player?.open(media, autoStart: true);
    onPlayStream();
    player?.playbackStream.listen((PlaybackState state) {
      if (state.isPlaying) {
        EasyLoading.dismiss();
      }
    });
    onPlayError();
  }

  void onPlayStream() {
    player?.currentStream.listen((CurrentState state) {
      print(state.media);
    });
  }

  void onPlayError() {
    player?.errorStream.listen((e) {
      EasyLoading.showError(player?.error ?? '加载失败');
      EasyLoading.dismiss();
    });
  }

  void togglePlayList() {
    playListShowed = !playListShowed;
    update();
  }

  @override
  void onClose() {
    player?.dispose();
  }
}
