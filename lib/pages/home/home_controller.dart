/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2022-09-14 21:13:21
 * @FilePath: \vvibe\lib\pages\home\home_controller.dart
 * @Description: 
 * @qmj
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:window_size/window_size.dart';
import 'package:vvibe/services/services.dart';

class HomeController extends GetxController {
  Player? player;
  bool playListShowed = false;
  int playerId = 0;

  final barrageWallController = BarrageWallController();
  PlayListItem? playingUrl;
  DouyuDnamakuService? dyDanmakuService;
  BilibiliDanmakuService? blDanmakuService;
  HuyaDanmakuService? hyDanmakuService;
  @override
  void onInit() {
    super.onInit();
    // initPlayer();
  }

  @override
  void onReady() {
    //final url = 'http://27.47.71.53:808/hls/1/index.m3u8';
    final url = 'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8';
    // startPlay(url);
    final lastPlayUrl = LoacalStorage().getJSON(LAST_PLAY_VIDEO_URL);
    if (lastPlayUrl != null && lastPlayUrl['url'] != null) {
      //     startPlay(PlayListItem.fromJson(lastPlayUrl));
    }
  }

//发送弹幕到屏幕
  void sendDanmakuBullet(LiveDanmakuItem? data) {
    if (data?.msg != null) if (!barrageWallController.isEnabled) {
      barrageWallController.enable();
    }
    barrageWallController.send([
      new Bullet(
          child: Tooltip(
        message: data?.name ?? '',
        child: Text(
          data?.msg ?? '',
          style: TextStyle(color: data?.color ?? Colors.white, fontSize: 20),
        ),
      ))
    ]);
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) async {
    stopDanmakuSocket();
    if (barrageWallController.isEnabled && player != null) {
      barrageWallController.disable();
    }
    if (!(item.tvgId != null && item.tvgId!.isNotEmpty)) return;
    final String rid = item.tvgId!;
    switch (item.group) {
      case '斗鱼':
      case 'douyu':
        dyDanmakuService = DouyuDnamakuService(
            roomId: rid,
            onDanmaku: (LiveDanmakuItem? node) {
              sendDanmakuBullet(node);
            });
        dyDanmakuService!.connect();
        break;
      case 'B站':
      case 'bilibili':
        blDanmakuService = BilibiliDanmakuService(
            roomId: rid,
            onDanmaku: (LiveDanmakuItem? node) {
              sendDanmakuBullet(node);
            });
        blDanmakuService?.connect();
        break;
      case '虎牙':
      case 'huya':
        hyDanmakuService = HuyaDanmakuService(
            roomId: rid,
            onDanmaku: (LiveDanmakuItem? node) {
              sendDanmakuBullet(node);
            });
        hyDanmakuService?.connect();
        break;
      default:
    }
  }

//断开所有弹幕连接
  void stopDanmakuSocket() {
    //barrageWallController.disable();

    dyDanmakuService?.dispose();

    blDanmakuService?.displose();

    hyDanmakuService?.displose();
  }

  void initPlayer() {
    playerId = playerId + 1;
    player = Player(
        id: playerId,
        commandlineArguments: [
          '--http-reconnect',
          '--sout-livehttp-caching',
        ],
        registerTexture: !Global.useNativeView);
    update();
  }

  void startPlay(PlayListItem item, {bool? first}) {
    if (player == null) {
      initPlayer();
    }
    EasyLoading.show(status: '正在打开');

    playingUrl = item;
    update();
    LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, item.toJson());

    MediaSource media = Media.network(
      item.url,
      parse: true,
      timeout: Duration(seconds: 10),
    );
    player?.open(media, autoStart: true);
    player?.setUserAgent('Windows ZTE');
    onCurrentStream();
    onPlaybackStream();
    onPlayError();
    onVideoDemensionStream();
    onProgressStream();
    player?.playOrPause();
  }

  //停止播放、销毁实例
  void stopPlayer({bool dispose = false}) {
    player?.dispose();
    player = null;
    playingUrl = null;
    stopDanmakuSocket();
    barrageWallController.disable();
    update();
    setWindowTitle('vvibe');
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item) {
    if (item.url == null) return;
    startPlay(item);
  }

  void onCurrentStream() {
    player?.currentStream.listen((CurrentState state) {
      debugPrint(' current stream ${jsonEncode(playingUrl)}');
    });
  }

  void onPlaybackStream() {
    player?.playbackStream.listen((PlaybackState state) {
      debugPrint(' playback stream ${state.isPlaying}');
    });
  }

  void onProgressStream() {
    player?.bufferingProgressStream.listen((double e) {
      final percent = e.toInt();

      if (percent >= 100) {
        EasyLoading.dismiss();
        if (playingUrl != null) {
          startDanmakuSocket(playingUrl!);
        }
      } else {
        print('缓冲进度 $percent% ');

        EasyLoading.show(status: "缓冲 ${percent}%");
      }
    });
  }

  void onPlayError() {
    player?.errorStream.listen((e) {
      EasyLoading.dismiss();
      EasyLoading.showError('播放失败了', duration: Duration(seconds: 10));

      debugPrint('播放异常： $e ');
      debugPrint('播放器错误： ${player?.error} ');
    });
  }

  void onVideoDemensionStream() {
    final name = player?.current.media?.metas['title'] ??
        playingUrl?.name ??
        playingUrl?.url ??
        'vvibe';
    player?.videoDimensionsStream.listen((videoDimensions) {
      final ratio = videoDimensions.width.toString() +
          'x' +
          videoDimensions.height.toString();
      final title = '${name} [${ratio}]';
      setWindowTitle(title);
    });
  }

  void updateWindowTitle() {}

  //获取当前弹幕区域尺寸
  Size getDanmakuSize() => Size(
      playListShowed ? Get.width - PLAYLIST_BAR_WIDTH : Get.width, Get.height);

  //播放列表菜单显示
  void togglePlayList() {
    playListShowed = !playListShowed;

    update();
  }

//打开单个播放url
  void onOpenOneUrl(String url) {
    debugPrint('打开链接 $url');
    if (url.isEmpty) return;
    final PlayListItem item =
        PlayListItem.fromJson({'url': url, 'name': 'vvibe'});
    startPlay(item);
  }

  @override
  void onClose() {}

  @override
  void dispose() {
    stopPlayer(dispose: Global.isRelease);
    setWindowTitle('vvibe');

    super.dispose();
  }
}
