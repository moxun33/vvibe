/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2024-07-29 20:57:13
 * @FilePath: \vvibe\lib\pages\home\home_controller.dart
 * @Description: 
 * @qmj
 */

import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fvp/mdk.dart';
import 'package:get/get.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/epg/epg_alert_dialog.dart';
import 'package:vvibe/components/widgets.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/danmaku/danmaku_service.dart';
import 'package:vvibe/services/services.dart';
import 'package:vvibe/utils/color_util.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/utils.dart';
import 'package:vvibe/window/window.dart';
import 'package:window_manager/window_manager.dart';

class HomeController extends GetxController with WindowListener {
  late final player = Player();

  int? textureId; //fvp播放时的渲染id
  bool playListShowed = false;
  int playerId = 0;

  final barrageWallController = BarrageWallController();
  PlayListItem? playingUrl;

  bool danmakuManualShow = true;
  String tip = ''; //左上角的文字提示
  Hackchat? hc;
  @override
  void onInit() {
    windowManager.addListener(this);

    super.onInit();
  }

  @override
  void onReady() {
    final lastPlayUrl = LoacalStorage().getJSON(LAST_PLAY_VIDEO_URL);
    if (lastPlayUrl != null && lastPlayUrl['url'] != null) {
      if (Global.isRelease) startPlay(PlayListItem.fromJson(lastPlayUrl));
    }
    initHackchat();
    playerConfig();
  }

  void playerConfig() async {
    player.setProperty('http_persistent', '0');
  }

//hack chat init
  initHackchat() {
    final _ws = Hackchat(
        nickname: genRandomStr(),
        onChat: onHackchatMsg,
        onClose: onHackchatClose);
    hc = _ws;
    _ws.init();
  }

  void onHackchatClose() {
    initHackchat();
  }

  onHackchatMsg(Map<String, dynamic> data) {
    final danmaku = LiveDanmakuItem.fromJson({
      'name': data['nick'],
      'uid': data['userid'].toString(),
      'msg': data['text']
    });
    danmaku.color = ColorUtil.fromHex('#ffffff');
    danmaku.ext = data;
    renderDanmaku(danmaku, isHackchat: true);
  }

//发送弹幕到远程
  void sendDanmaku(String text) {
    if (hc == null) return;
    /* if (hc!.readyState != 1) {
      Logger.error('${hc!.readyState} hackchat已断开，无法发送消息');
      initHackchat();
      return;
    } */
    hc!.sendMsg(text);
  }

//发送弹幕到屏幕
  void renderDanmaku(LiveDanmakuItem? data, {isHackchat = false}) async {
    if (!danmakuManualShow) return;
    if (data?.msg != null && !barrageWallController.isEnabled) {
      barrageWallController.enable();
    }
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    final fontSize =
        settings != null ? settings['dmFSize'].toDouble() ?? 20.0 : 20.0;
    barrageWallController.send([
      new Bullet(
          child: Tooltip(
        message: data?.name ?? '',
        child: isHackchat
            ? BorderText(text: data?.msg ?? '', fontSize: fontSize)
            : Text(
                data?.msg ?? '',
                style: TextStyle(
                    color: data?.color ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
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

//实现回看
  void doPlayback(String playseek) {
    if (playingUrl == null) return;
    final _urlItem = playingUrl!.toJson();
    var url = playingUrl?.url;
    if (url == null) return;
    Uri u = Uri.parse(url.trim());
    final haveQueries = u.queryParameters.length > 0;
    final _url = haveQueries
        ? '${url}&playseek=${playseek}'
        : '${url}${url.endsWith('?') ? '' : '?'}playseek=${playseek}';
    _urlItem['url'] = _url;
    startPlay(PlayListItem.fromJson(_urlItem), playback: true);
  }

  //显示、隐藏节目单
  void toggleEpgDialog() {
    if (playingUrl == null) return;
    Get.dialog(EpgAlertDialog(
      urlItem: playingUrl!,
      doPlayback: doPlayback,
    ));
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) async {
    // stopDanmakuSocket();
    if (barrageWallController.isEnabled) {
      barrageWallController.disable();
    }
    DanmakuService().start(item, renderDanmaku);
  }

//断开所有弹幕连接
  void stopDanmakuSocket() {
    barrageWallController.disable();
    DanmakuService().stop();
  }

  void initPlayer() async {
    await updateTexture();
    player.setDecoders(MediaType.video, ["MFT:d3d=11", "D3D11", "FFmpeg"]);
    update();
  }

  Future<int> updateTexture() async {
    if (textureId != null) {
      await stopPlayer();
    }
    int ttId = await player.updateTexture();

    print('textureId: $ttId');

    textureId = ttId;

    update();
    return ttId;
  }

  void startPlay(PlayListItem item, {bool? first, playback = false}) async {
    try {
      debugPrint('start play ${item.toJson()}');
      stopPlayer();
      if (textureId == null) {
        initPlayer();
      }
      final url = item.ext?['playUrl'] ?? item.url;
      if (!(url != null && url!.isNotEmpty)) {
        EasyLoading.showError('播放地址错误');

        return;
      }
      tip = '正在打开${item.name ?? ''}';
      update();
      final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
      if (settings != null) {
        player.setProperty('user-agent', settings['ua'] ?? DEF_REQ_UA);
      }
      player.media = url;
      player.state = PlaybackState.playing;

      if (!playback) {
        playingUrl = item;
        update();
        LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, item.toJson());
      }

      player.onStateChanged((PlaybackState oldState, PlaybackState state) {
        debugPrint("-------------------接收到state改变 $state");
      });
      player.onMediaStatus((MediaStatus oldStatus, MediaStatus status) {
        debugPrint("============接收到media status改变 $status");
        if (status.toString() == 'MediaStatus(+invalid)') {
          tip = '${item.name}播放失败';
          stopPlayer();
          update();
        }
        return true;
      });
      player.onEvent((MediaEvent e) {
        print("******接收到event改变 ${e.category} ${e.detail} ${e.error}");
        final value = e.error.toInt();
        switch (e.category) {
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
      /*   player.onRenderCallback((msg) {
        // debugPrint('======render cb log $msg');
      });
      player.setLogHandler((msg) async {
        debugPrint('【log】 $msg');
      }); */
    } catch (e) {
      Logger.error('[error logs] ${e.toString()}');
    }
  }

  //停止播放、销毁实例
  Future<int> stopPlayer() async {
    if (textureId == null) return 0;
    debugPrint('close player');
    player.state = PlaybackState.stopped;
    EasyLoading.dismiss();
    textureId = null;
    playingUrl = null;
    stopDanmakuSocket();
    barrageWallController.disable();
    update();
    VWindow().setWindowTitle('vvibe');
    //player.dispose();
    return 1;
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item) async {
    if (item.url == null) return;
    await stopPlayer();

    final _item = await PlaylistUtil().parseSingleUrlAsync(item.url!);
    item.ext = _item.ext ?? {};
    startPlay(item);
  }

  void updateWindowTitle(PlayListItem item) async {
    final info = await player.mediaInfo;
    debugPrint(info.toString());
    final ratio =
        '${info.video?[0].codec.width}x${info.video?[0].codec.height}';
    final title = '${item.name} [${ratio}]';
    VWindow().setWindowTitle(title, item.tvgLogo);
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
  void onOpenOneUrl(String url) async {
    debugPrint('打开链接 $url');
    if (url.isEmpty) return;
    await stopPlayer();
    final item = await PlaylistUtil().parseSingleUrlAsync(url);
    startPlay(item);
  }

  @override
  void onClose() async {
    super.onClose();
    await stopPlayer();
    windowManager.removeListener(this);

    hc?.close();
    player.dispose();
  }

  @override
  void onWindowClose() async {
    await stopPlayer();
    hc?.close();
    player.dispose();
  }
}
