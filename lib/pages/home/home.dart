/* /*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2024-08-17 00:54:54
 * @FilePath: \vvibe\lib\pages\home\home_view.dart
 * @Description:
 * @qmj
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fvp/mdk.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/epg/epg_alert_dialog.dart';
import 'package:vvibe/components/player/fvp_videoframe.dart';
import 'package:vvibe/components/player/player_context_menu.dart';
import 'package:vvibe/components/playlist/playlist_widgets.dart';
import 'package:vvibe/components/playlist/video_playlist.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_info.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/danmaku/danmaku_service.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:vvibe/services/hackchat/hackchat.dart';
import 'package:vvibe/utils/LogFile.dart';
import 'package:vvibe/utils/color_util.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/utils.dart';
import 'package:vvibe/window/window.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  late final player = Player();

  bool playListShowed = false;
  int playerId = 0;

  final barrageWallController = BarrageWallController();
  PlayListItem? playingUrl;

  bool danmakuManualShow = true;
  String tip = ''; //左上角的单个文字提示，如成功、失败
  List<String> msgs = []; //左上角的文字提示列表，如 媒体信息
  bool msgsShowed = false;
  Map<String, String> extraMetaInfo = {}; //额外的元数据
  Hackchat? hc;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // initHackchat();
    playerConfig();
    eventBus.on('play-last-video', (e) {
      final lastPlayUrl = LoacalStorage().getJSON(LAST_PLAY_VIDEO_URL);
      if (lastPlayUrl != null && lastPlayUrl['url'] != null) {
        if (Global.isRelease) {
          startPlay(PlayListItem.fromJson(lastPlayUrl));
        }
      }
    });
  }

  playerConfig() async {
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    final fullFfmpeg = settings['fullFfmpeg'] == 'true';
    player.setProperty('http_persistent', '0');
    player.setDecoders(MediaType.video, [
      "MFT:d3d=11${fullFfmpeg ? ':copy=1' : ''}",
      "hap",
      "D3D11",
      "DXVA",
      "CUDA",
      "FFmpeg",
      "dav1d"
    ]);
    if (fullFfmpeg) {
      player.setProperty('video.avfilter', 'yadif');
    }
    player.setProperty('avio.user_agent', settings?['ua'] ?? DEF_REQ_UA);
    player.setProperty('video.reconnect', '1');
    player.setProperty('video.reconnect_delay_max', '3');
    player.setProperty('demux.buffer.range', '7');
    player.setProperty('buffer', '2000+600000');
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

    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    final fontSize =
        settings != null ? settings['dmFSize'].toDouble() ?? 20.0 : 20.0;
    barrageWallController.send([
      Bullet(
          child:
              DanmakuRender(data, fontSize: fontSize, isHackchat: isHackchat))
    ]);
  }

  //显示、隐藏弹幕
  void toggleDanmakuVisible() {
    if (barrageWallController.isEnabled) {
      barrageWallController.disable();
      setState(() {
        danmakuManualShow = false;
      });
      stopDanmakuSocket();
    } else {
      barrageWallController.enable();
      setState(() {
        danmakuManualShow = true;
      });
      if (playingUrl != null) startDanmakuSocket(playingUrl!);
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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return EpgAlertDialog(
            urlItem: playingUrl!,
            doPlayback: doPlayback,
          );
        });
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) async {
    stopDanmakuSocket();
    if (!danmakuManualShow) {
      return;
    }
    barrageWallController.enable();
    DanmakuService().start(item, renderDanmaku);
  }

//断开所有弹幕连接
  void stopDanmakuSocket() {
    barrageWallController.clear();
    barrageWallController.disable();
    DanmakuService().stop();
  }

  void startPlay(PlayListItem item, {bool? first, playback = false}) async {
    try {
      player.state = PlaybackState.stopped;
      player.waitFor(PlaybackState.stopped);
      MyLogger.info('start play ${item.toJson()}');

      final url = item.ext?['playUrl'] ?? item.url;
      if (!(url != null && url!.isNotEmpty)) {
        EasyLoading.showError('播放地址错误');

        return;
      }
      setState(() {
        tip = '正在打开 ${item.name ?? ''}';
      });

      playerConfig();
      player.media = url;
      player.state = PlaybackState.playing;

      player.updateTexture();
      if (!playback) {
        setState(() {
          playingUrl = item;
        });
        LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, item.toJson());
      }

      player.onStateChanged((PlaybackState oldState, PlaybackState state) {
        MyLogger.info("fvp player state改变 $state");
      });
      player.onMediaStatus((MediaStatus oldStatus, MediaStatus status) {
        final s = status.toString();
        MyLogger.info("fvp player  media status改变 $status");
        switch (s) {
          case 'MediaStatus(+invalid)':
            stopPlayer();
            setState(() {
              tip = '${item.name} 播放失败';
            });
            break;
          case 'MediaStatus(+buffering)':
            break;
          case 'MediaStatus(+loaded)':
            break;
          case 'MediaStatus(+playing)':
            break;
          case 'MediaStatus(+paused)':
            break;
        }

        return false;
      });
      player.onEvent((MediaEvent e) {
        MyLogger.info(
            "fvp player event  ${e.category} ,detail: ${e.detail} ，error: ${e.error}");
        final value = e.error.toInt();
        extraMetaInfo[e.category] = e.detail;
        switch (e.category) {
          case 'reader.buffering':
            setState(() {
              tip = value < 100 ? '缓冲 $value%' : '';
            });
            break;
          case 'render.video':
            if (value > 0) {
              startDanmakuSocket(item);
              updateWindowTitle(item);
              toggleMediaInfo(msgsShowed);
            }
            break;
          default:
            break;
        }
      });
      /*   player.onRenderCallback((msg) {
        // MyLogger.info('======render cb log $msg');
      });
      player.setLogHandler((msg) async {
        MyLogger.info('【log】 $msg');
      }); */
    } catch (e) {
      MyLogger.error('[error logs] ${e.toString()}');
    }
  }

  //停止播放、销毁实例
  Future<int> stopPlayer() async {
    MyLogger.info('set playback to stopped');
    player.state = PlaybackState.stopped;
    player.waitFor(PlaybackState.stopped);
    EasyLoading.dismiss();
    setState(() {
      playingUrl = null;
    });
    stopDanmakuSocket();
    VWindow().setWindowTitle('vvibe');
    player.updateTexture(width: -1, height: -1);
    return 1;
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item,
      {Map<String, dynamic>? subConfig, PlayListInfo? playlistInfo}) async {
    if (item.url == null) return;
    stopPlayer();

    final _item = await PlaylistUtil().parseSingleUrlAsync(item.url!);
    item.ext = _item.ext ?? {};
    startPlay(item);
  }

  void updateWindowTitle(PlayListItem item) {
    final info = player.mediaInfo;
    MyLogger.info(info.toString());
    final ratio =
        '${info.video?[0].codec.width}x${info.video?[0].codec.height}';
    final title = '${item.name} [${ratio}]';
    VWindow().setWindowTitle(title, item.tvgLogo);
  }

// 显隐媒体元数据
  void toggleMediaInfo([show = false]) {
    setState(() {
      msgsShowed = show;
    });
    if (show) {
      final info = player.mediaInfo;
      final vc = info.video?[0].codec;
      final ac = info.audio?[0].codec;
      final _msgs = [
        'Video: ${vc?.codec}/ ${info.format}',
        '   Frame Rate: ${vc?.frameRate} fps',
        '   Resolution: ${vc?.width} x ${vc?.height}',
        '   Format: ${vc?.formatName}',
        '   Bitrate: ${(vc?.bitRate ?? 0) / 1000} kbps',
        '   ',
        'Audio: ${ac?.codec}  ',
        '   Channels: ${ac?.channels}',
        '   Sample Rate: ${ac?.sampleRate} Hz',
        '   Bitrate: ${(ac?.bitRate ?? 0) / 1000} kbps',
      ];
      setState(() {
        msgs = _msgs;
      });

      MyLogger.info(info.toString());
    } else {
      setState(() {
        msgs = [];
      });
    }
  }

  //获取当前弹幕区域尺寸
  Size getDanmakuSize() => Size(
      playListShowed
          ? getDeviceWidth(context) - PLAYLIST_BAR_WIDTH
          : getDeviceWidth(context),
      getDeviceHeight(context));

  //播放列表菜单显示
  void togglePlayList() {
    setState(() {
      playListShowed = !playListShowed;
    });
    LogFile.log('app log');
  }

//打开单个播放url
  void onOpenOneUrl(String url) async {
    MyLogger.info('打开链接 $url');
    if (url.isEmpty) return;
    final item = await PlaylistUtil().parseSingleUrlAsync(url);
    startPlay(item);
  }

  @override
  void dispose() async {
    await stopPlayer();
    windowManager.removeListener(this);
    hc?.close();
    player.dispose();
    super.dispose();
  }

  // 信息展示
  Widget OsdMsg() {
    final _msgs = [tip] + msgs;
    return Container(
        padding: const EdgeInsets.all(10),
        width: getDanmakuSize().width,
        height: getDanmakuSize().height - 100,
        color: Colors.transparent,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _msgs.map((txt) {
              return Text(
                txt,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis),
              );
            }).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            child: Row(
          children: <Widget>[
            Expanded(
                flex: 4,
                child: Container(
                  child: ValueListenableBuilder<int?>(
                      valueListenable: player.textureId,
                      builder: (context, id, _) => id == null ||
                              playingUrl == null
                          ? GestureDetector(
                              onTap: () {
                                togglePlayList();
                              },
                              child: Container(
                                color: Colors.black,
                                child: Center(
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 50,
                                    children: [
                                      SizedBox(
                                          width: 200,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            imageUrl: playingUrl?.tvgLogo ?? '',
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset('assets/logo.png'),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : BarrageWall(
                              debug: false, //!Global.isRelease,
                              safeBottomHeight:
                                  getDeviceHeight(context) ~/ 4 * 3,
                              speed: 10,
                              massiveMode: false,
                              speedCorrectionInMilliseconds: 10000,
                              bullets: [],
                              controller: barrageWallController,
                              child: Container(
                                  color: Colors.black,
                                  child: FvpVideoFrame(
                                    toggleMediaInfo: toggleMediaInfo,
                                    toggleDanmaku: toggleDanmakuVisible,
                                    toggleEpgDialog: toggleEpgDialog,
                                    playingUrl: playingUrl,
                                    videoWidget: Center(
                                        child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Texture(
                                        textureId: id,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    )),
                                    fvp: player,
                                    togglePlayList: togglePlayList,
                                    stopPlayer: stopPlayer,
                                    sendDanmaku: sendDanmaku,
                                  )),
                            )),
                )),
            Container(
                width: playListShowed ? PLAYLIST_BAR_WIDTH : 0,
                child: VideoPlaylist(
                  visible: playListShowed,
                  onUrlTap: onPlayUrlChange,
                )),
          ],
        )),
        GestureDetector(
            onDoubleTap: () => togglePlayList(),
            child: PlayerContextMenu(
                onOpenUrl: onOpenOneUrl,
                showPlaylist: togglePlayList,
                playListShowed: playListShowed,
                child: OsdMsg())),
      ],
    ));
  }

  @override
  void onWindowClose() async {
    await stopPlayer();
    hc?.close();
    player.dispose();
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }
}
 */
