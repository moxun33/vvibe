import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/init.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:window_size/window_size.dart';

class HomeController extends GetxController {
  Player? player;
  bool playListShowed = true;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initPlayer(1);
  }

  @override
  void onReady() {
    //final url = 'http://27.47.71.53:808/hls/1/index.m3u8';
    final url = 'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8';
    // startPlay(url);
  }

  void initPlayer(int id) {
    player = Player(
        id: id,
        commandlineArguments: [],
        registerTexture: !Global.useNativeView);
  }

  void startPlay(PlayListItem item, {bool? first}) {
    if (player == null) {
      initPlayer(new DateTime.now().millisecondsSinceEpoch);
    }

    EasyLoading.show(status: "拼命加载中");
    MediaSource media = Media.network(item.url, parse: true);
    player!.open(media, autoStart: true);
    player!.setUserAgent('Windows ZTE');
    onCurrentStream();
    onPlaybackStream();
    onPlayError();
    onVideoDemensionStream(item.url, item.name);
    player!.playOrPause();
  }

  //停止播放器、销毁实例
  void stopPlayer({bool dispose = false}) {
    if (player == null) return;
    player!.stop();
    player!.dispose();
    if (dispose) player = null;
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
    stopPlayer(dispose: true);
    super.dispose();
    setWindowTitle('vvibe');
  }
}
