/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-04 21:20:44
 * @FilePath: \vvibe\lib\pages\home\home_controller.dart
 * @Description: 
 * @qmj
 */

import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fvp/fvp.dart';
import 'package:get/get.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/epg/epg_alert_dialog.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/services/services.dart';
import 'package:vvibe/window/window.dart';

class HomeController extends GetxController {
  Fvp player = Fvp();

  int? textureId; //fvp播放时的渲染id
  bool playListShowed = false;
  int playerId = 0;

  final barrageWallController = BarrageWallController();
  PlayListItem? playingUrl;
  DouyuDnamakuService? dyDanmakuService;
  BilibiliDanmakuService? blDanmakuService;
  HuyaDanmakuService? hyDanmakuService;
  bool danmakuManualShow = true;
  String tip = ''; //左上角的文字提示
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
      if (Global.isRelease) startPlay(PlayListItem.fromJson(lastPlayUrl));
    }
    //  _tt();
  }

  _tt() async {}

//发送弹幕到屏幕
  void sendDanmakuBullet(LiveDanmakuItem? data) async {
    if (!danmakuManualShow) return;
    if (data?.msg != null && !barrageWallController.isEnabled) {
      barrageWallController.enable();
    }
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    barrageWallController.send([
      new Bullet(
          child: Tooltip(
        message: data?.name ?? '',
        child: Text(
          data?.msg ?? '',
          style: TextStyle(
              color: data?.color ?? Colors.white,
              fontSize:
                  settings != null ? settings['dmFSize'].toDouble() ?? 20 : 20),
        ),
      ))
    ]);
  }

  //显示、隐藏弹幕
  void toggleDanmakuVisible() {
    if (barrageWallController.isEnabled) {
      barrageWallController.disable();
      danmakuManualShow = false;
    } else {
      barrageWallController.enable();
      danmakuManualShow = true;
    }
  }

  //显示、隐藏节目单
  void toggleEpgDialog() {
    if (playingUrl == null) return;
    Get.dialog(EpgAlertDialog(urlItem: playingUrl!));
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) async {
    stopDanmakuSocket();
    if (barrageWallController.isEnabled) {
      barrageWallController.disable();
    }
    if (!(item.tvgId != null && item.tvgId!.isNotEmpty)) return;
    final String rid = item.tvgId!;
    debugPrint('登录弹幕 ${item.group}');
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

  void initPlayer() async {
    await updateTexture();
    update();
  }

  Future<int> updateTexture() async {
    if (textureId != null) {
      await stopPlayer();
    }
    int ttId = await player.createTexture();

    print('textureId: $ttId');

    textureId = ttId;

    update();
    return ttId;
  }

  void startPlay(PlayListItem item, {bool? first}) async {
    await updateTexture();
    stopDanmakuSocket();
    if (!(item.url != null && item.url!.isNotEmpty)) {
      EasyLoading.showError('播放地址错误');
      stopPlayer();

      return;
    }
    tip = '正在打开';
    update();
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    if (settings != null) {
      await player.setUserAgent(settings['ua'] ?? DEF_REQ_UA);
    }
    await player.setMedia(item.url!);

    playingUrl = item;
    update();
    LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, item.toJson());
    player.onStateChanged((String state) {
      print("-------------------接收到state改变 $state");
    });
    player.onMediaStatusChanged((String status) {
      print("============接收到media status改变 $status");
      if (status == '-2147483648') {
        tip = '播放失败';
        update();
      }
    });
    player.onEvent((Map<String, dynamic> data) {
      print("******接收到event改变 ${data}");
      final value = data['error'].toInt();
      switch (data['category']) {
        case 'reader.buffering':
          tip = value < 100 ? '缓冲 $value%' : '';
          update();
          break;
        case 'render.video':
          if (value > 0) {
            startDanmakuSocket(item);
            updateWindowTitle(item);
          }
          break;
        default:
          break;
      }
    });
  }

  //停止播放、销毁实例
  Future<int> stopPlayer({bool dispose = false}) async {
    EasyLoading.dismiss();
    textureId = null;
    playingUrl = null;
    stopDanmakuSocket();
    barrageWallController.disable();
    update();
    VWindow().setWindowTitle('vvibe');
    return player.stop();
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item) {
    if (item.url == null) return;
    startPlay(item);
  }

  void updateWindowTitle(PlayListItem item) async {
    final info = await player.getMediaInfo();
    if (info == null) return;

    final ratio = info['video']['codec']['width'].toString() +
        'x' +
        info['video']['codec']['height'].toString();
    final title = '${item.name} [${ratio}]';
    VWindow().setWindowTitle(title);
  }

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
    VWindow().setWindowTitle('vvibe');

    super.dispose();
  }
}
