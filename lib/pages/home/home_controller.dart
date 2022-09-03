import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:window_size/window_size.dart';

class HomeController extends GetxController {
  Player? player;
  bool playListShowed = true;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    player = Player(
        id: 1,
        commandlineArguments: [],
        registerTexture: !Global.useNativeView);
  }

  @override
  void onReady() {
    //final url = 'http://27.47.71.53:808/hls/1/index.m3u8';
    final url = 'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8';
    // startPlay(url);
  }

  void startPlay(PlayListItem item, {bool? first}) {
    if (player == null) return;
    EasyLoading.show(status: "拼命加载中");
    MediaSource media = Media.network(item.url, parse: true);
    player!.open(media, autoStart: true);

    onCurrentStream();
    onPlaybackStream();

    onPlayError();

    onVideoDemensionStream(item.url, item.name);
  }

//播放url改变
  void onPlayUrlChange(PlayListItem item) {
    if (item.url == null) return;
    startPlay(item);
  }

  void onCurrentStream() {
    player?.currentStream.listen((CurrentState state) {
      print(state.media);
      print(' current stream');
    });
  }

  void onPlaybackStream() {
    player?.playbackStream.listen((PlaybackState state) {
      if (state.isPlaying) {
        EasyLoading.dismiss();
      }
    });
  }

  void onPlayError() {
    player?.errorStream.listen((e) {
      EasyLoading.showError('加载失败');
      EasyLoading.dismiss();
    });
  }

  void onVideoDemensionStream(String? url, String? title) {
    final name =
        player?.current.media?.metas['title'] ?? title ?? url ?? 'vvibe';
    player?.videoDimensionsStream.listen((videoDimensions) {
      final ratio = videoDimensions.width.toString() +
          'x' +
          videoDimensions.height.toString();
      final title = '${name} [${ratio}]';
      setWindowTitle(title);
    });
  }

  void updateWIndowTitle() {}
  void togglePlayList() {
    playListShowed = !playListShowed;
    update();
  }

  @override
  void onClose() {}

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
    setWindowTitle('vvibe');
  }
}
