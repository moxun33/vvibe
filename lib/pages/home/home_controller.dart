import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/init.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/danmaku/bilibili_danmaku_service.dart';
import 'package:vvibe/services/danmaku/huya_danmaku_service.dart';
import 'package:window_size/window_size.dart';
import 'package:vvibe/services/danmaku/douyu_danmaku_service.dart';

class HomeController extends GetxController {
  Player? player;
  bool playListShowed = false;

  final playListBarWidth = 200.0;

  final barrageWallController = BarrageWallController();
  DouyuDnamakuService? dyDanmakuService;
  BilibiliDanmakuService? blDanmakuService;
  HuyaDanmakuService? hyDanmakuService;
  @override
  void onInit() {
    super.onInit();
    initPlayer(1);
  }

  @override
  void onReady() {
    //final url = 'http://27.47.71.53:808/hls/1/index.m3u8';
    final url = 'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8';
    // startPlay(url);
  }

//发送弹幕道屏幕
  void sendDanmakuBullet(LiveDanmakuItem? data) {
    if (data?.msg != null)
      barrageWallController.send([
        new Bullet(
            child: Tooltip(
          message: data?.name ?? '',
          child: Text(
            data?.msg ?? '',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ))
      ]);
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) {
    stopDanmakuSocket();
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
    dyDanmakuService = null;
    blDanmakuService?.displose();
    blDanmakuService = null;
    hyDanmakuService?.displose();
    hyDanmakuService = null;
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
    onCurrentStream(item);
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

  void onCurrentStream(PlayListItem? item) {
    player?.currentStream.listen((CurrentState state) {
      debugPrint(' current stream ${jsonEncode(item)}');
      if (item != null) startDanmakuSocket(item);
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

  //获取当前弹幕区域尺寸
  Size getDanmakuSize() => Size(
      playListShowed ? Get.width - playListBarWidth : Get.width, Get.height);
  void togglePlayList() {
    playListShowed = !playListShowed;

    update();
  }

  @override
  void onClose() {}

  @override
  void dispose() {
    stopPlayer(dispose: Global.isRelease);
    super.dispose();
    setWindowTitle('vvibe');
    stopDanmakuSocket();
  }
}
