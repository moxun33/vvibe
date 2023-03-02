/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2023-03-02 15:17:55
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

class HomeController extends GetxController {
  Fvp player = Fvp();

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
    initHackchat();
    //_tt();
  }

  _tt() async {
    FfiUtil().getMediaInfo(
        'https://hdltctwk.douyucdn2.cn/live/4549169rYnH7POVF.m3u8');
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
        settings != null ? settings['dmFSize'].toDouble() ?? 20 : 20;
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
    //stopDanmakuSocket();
    if (barrageWallController.isEnabled) {
      barrageWallController.disable();
    }
    DanmakuService().start(item, renderDanmaku);
  }

//断开所有弹幕连接
  void stopDanmakuSocket() {
    //barrageWallController.disable();
    DanmakuService().stop();
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

  void startPlay(PlayListItem item, {bool? first, playback = false}) async {
    try {
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

      if (!playback) {
        playingUrl = item;
        update();
        LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, item.toJson());
      }

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
      // player.onRenderCallback((msg) {});
    } catch (e) {
      Logger.error(e.toString());
    }
  }

  //停止播放、销毁实例
  Future<int> stopPlayer() async {
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
  void onPlayUrlChange(PlayListItem item) async {
    if (item.url == null) return;

    if (item.ext?['platformHit'] == true) {
      final _item = await PlaylistUtil().parseSingleUrlAsync(item.url!);
      item.url = _item.url;
    }
    // print(item.toJson());
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
  void onOpenOneUrl(String url) async {
    debugPrint('打开链接 $url');
    if (url.isEmpty) return;
    final item = await PlaylistUtil().parseSingleUrlAsync(url);
    startPlay(item);
  }

  @override
  void onClose() {
    stopPlayer();
    VWindow().setWindowTitle('vvibe');
    hc?.close();
  }
}
