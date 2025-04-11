import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:fvp/fvp.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:video_player/video_player.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/common/values/storage.dart';
import 'package:vvibe/components/player/epg/epg_alert_dialog.dart';
import 'package:vvibe/components/player/player_context_menu.dart';
import 'package:vvibe/components/player/vplayer_controls.dart';
import 'package:vvibe/components/playlist/playlist_widgets.dart';
import 'package:vvibe/components/playlist/video_playlist.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_info.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/danmaku/danmaku_service.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:vvibe/utils/common.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';
import 'package:vvibe/utils/screen_device.dart';
import 'package:vvibe/window/window.dart';
import 'package:window_manager/window_manager.dart';

class Vplayer extends StatefulWidget {
  const Vplayer({Key? key}) : super(key: key);

  @override
  _VplayerState createState() => _VplayerState();
}

class _VplayerState extends State<Vplayer> with WindowListener {
  VideoPlayerController? _controller;
  bool playListShowed = false;

  final barrageWallController = BarrageWallController();
  PlayListItem? playingUrl;

  bool danmakuManualShow = true;
  String tip = ''; //左上角的单个文字提示，如成功、失败
  List<String> msgs = []; //左上角的文字提示列表，如 媒体信息
  bool msgsShowed = false;
  PlayListInfo? playListInfo; // 当前订阅的信息
  Map<String, dynamic> subConf = {}; //当前远程订阅、文件的独立播放配置
  int bufferSpeed = 0; // 缓冲速度 (字节/秒)
  Duration lastBufferUpdateTime = Duration.zero;
  Duration lastBufferedPosition = Duration.zero;
  String cursor = '1';
  final _throttle = Throttler(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // startPlay(PlayListItem(url: 'http://live.metshop.top/douyu/1377142'));
    eventBus.on('play-last-video', (e) {
      initLastVideo();
    });
    eventBus.on('change-mouse-cursor', (e) {
      setState(() {
        cursor = e != null ? e.toString() : '1';
      });
    });
    initLastVideo();
    _listenLog();
  }

  _listenLog() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (record.loggerName != 'mdk') return;
      try {
        final df = DateFormat("HH:mm:ss.SSS");
        final msg = record.message;
        final content =
            '${record.loggerName}.${record.level.name}: ${df.format(record.time)}: ${msg}';
        print('$content  mdk日志《=》2382389329823898932');
        //if (IS_RELEASE) LogFile.log(content + '\n');
        if (msg.contains('reader.buffering')) {
          final num = int.parse(msg.split('-').last.trim());
          setState(() {
            tip = num > 0 && num < 100 ? '缓冲中 ${num}%' : '';
          });
        }
      } catch (e) {}
    });
  }

  initLastVideo() {
    final lastPlayUrl = LoacalStorage().getJSON(LAST_PLAY_VIDEO_URL);
    if (lastPlayUrl != null && lastPlayUrl['url'] != null) {
      setState(() {
        subConf = lastPlayUrl['subConf'] ?? {};
      });
      if (Global.isRelease) {
        startPlay(PlayListItem.fromJson(lastPlayUrl));
      }
    }
  }

  List<String> getVideoDecoders(bool fullFfmpeg) {
    final bp = '${fullFfmpeg ? ':copy=1' : ''}';
    switch (Platform.operatingSystem) {
      case 'windows':
        return [
          "MFT:d3d=11${bp}",
          "D3D11${bp}",
          "DXVA${bp}",
          "hap${bp}",
          "CUDA${bp}",
          "FFmpeg${bp}",
          "dav1d"
        ];
      case 'linux':
        return [
          "hap${bp}",
          "VAAPI${bp}",
          "CUDA${bp}",
          "VDPAU",
          "FFmpeg",
          "dav1d"
        ];
      case 'macos':
      case 'ios':
        return ["VT${bp}", "hap${bp}", "FFmpeg${bp}", "dav1d}"];
      case 'android':
      case 'fuchsia':
        return ["AMediaCodec${bp}", "FFmpeg${bp}", "dav1d"];
      default:
        return ["FFmpeg${bp}", "dav1d"];
    }
  }

  Future<bool> _isDeinterlace() async {
    if (subConf['deinterlace'] == null) {
      final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS) ?? {};
      return PlaylistUtil().isBoolValid(settings['deinterlace'], false);
    }
    return PlaylistUtil().isBoolValid(subConf['deinterlace'], false);
  }

  Future<String> _getUA() async {
    if (PlaylistUtil().isStrValid(subConf['ua'])) {
      return subConf['ua'];
    }
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS) ?? {};
    return settings['ua'] ?? DEF_REQ_UA;
  }

  playerConfig() async {
    final Map<String, String> playerProps = {
      "avformat.extension_picky": "0",
      //'demux.buffer.ranges': '1',
      //'buffer': '2000+10000'
    };
    final _deinterlace = await _isDeinterlace();
    if (_deinterlace) {
      playerProps['video.avfilter'] = 'yadif';
    }

    registerWith(options: {
      'video.decoders': getVideoDecoders(_deinterlace),
      'player': playerProps
    });
  }

  startPlay(PlayListItem? item, {bool playback = false}) async {
    if (item == null) return;
    playerConfig();
    if (_controller?.value.isInitialized == true) {
      stopPlayer();
    }
    _controller?.dispose();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(item.url), httpHeaders: {
      // 'User-Agent': await _getUA(),
    });
    item.catchup = playListInfo?.catchup;
    item.catchupSource = playListInfo?.catchupSource;
    setState(() {
      playingUrl = item;
      tip = '正在打开 ${item.name}';
    });
    _controller?.addListener(() {
      videoPlayerListener(item);
    });
    _controller
        ?.initialize()
        .then((_) => setState(() {
              if (!playback) {
                setState(() {
                  tip = '';
                  playingUrl = item;
                  cursor = '1';
                });
                final itemJson = item.toJson();
                itemJson['subConf'] = subConf;
                LoacalStorage().setJSON(LAST_PLAY_VIDEO_URL, itemJson);
              }
              startDanmakuSocket(item);
              updateWindowTitle(item);
              toggleMediaInfo(msgsShowed);
            }))
        .catchError((e) {
      setState(() {
        tip = '${item.name} 播放失败';
        playingUrl = null;
      });
      print('play error: ${e.toString()}');
      stopPlayer();
    });
    _controller?.play();
  }

  void updateWindowTitle(PlayListItem item, [String extra = '']) {
    final size = _controller?.value.size;
    final ratio = '${size!.width.toInt()}x${size.height.toInt()}';
    final title = '${item.name} [${ratio}] ' + ' ${extra}';
    VWindow().setWindowTitle(title, showLogo ? item.tvgLogo : null);
  }

// 显隐媒体元数据
  void toggleMediaInfo([show = false]) {
    setState(() {
      msgsShowed = show;
    });
    if (show) {
      final info = _controller?.getMediaInfo();
      if (info == null) return;
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

  videoPlayerListener(PlayListItem? item) {
    if (item == null || _controller?.value.isInitialized != true) return;
    final _val = _controller?.value;
    if (_val == null) return;
    if (_val.hasError && !_val.isBuffering) {
      eventBus.emit('play-next-url');
      setState(() {
        tip = '${item.name} 播放失败 ${_val.errorDescription ?? ''}';
        playingUrl = null;
      });
      stopPlayer();
      return;
    }
    if (_val.isBuffering && !_val.isPlaying) {
      setState(() {
        tip = '${item.name} 缓冲中......';
      });
    } else {
      setState(() {
        tip = '';
      });
    }

    _throttle.run(() {
      _updateBufferSpeed();
    });
  }

  void _updateBufferSpeed() {
    /*  if (playListShowed != true) {
      updateWindowTitle(playingUrl!, '');
      return;
    } */
    final buffered = _controller?.value.buffered;

    // 获取最新的缓冲区
    if (buffered != null && buffered.isNotEmpty) {
      final newBufferEnd = buffered.last.end;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lastBufferUpdateTime != Duration.zero) {
        final elapsedTime = (now - lastBufferUpdateTime.inMilliseconds);
        final newBufferedBytes =
            newBufferEnd.inMilliseconds - lastBufferedPosition.inMilliseconds;
        final speed = (newBufferedBytes / (elapsedTime / 1000));
        final _speed = speed.isFinite ? speed.toInt() : 0;
        if (speed > 0 && playingUrl != null) {
          // print('cache $_speed KB/s');
          setState(() {
            bufferSpeed = _speed;
          });
          updateWindowTitle(playingUrl!, '$_speed KB/s');
        }
      }

      lastBufferedPosition = newBufferEnd;
      lastBufferUpdateTime = Duration(milliseconds: now);
    }
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item,
      {Map<String, dynamic>? subConfig, PlayListInfo? playlistInfo}) async {
    setState(() {
      subConf = (subConfig ?? {});
      playListInfo = playlistInfo;
    });

    startPlay(item);
  }

  //播放列表菜单显示
  void togglePlayList() {
    setState(() {
      playListShowed = !playListShowed;
    });
    // LogFile.log('app log');
  }

//打开单个播放url
  void onOpenOneUrl(String url) async {
    // MyLogger.info('打开链接 $url');
    if (url.isEmpty) return;
    final item = await PlaylistUtil().parseSingleUrlAsync(url);
    setState(() {
      subConf = {};
      playListInfo = null;
    });
    startPlay(item);
  }

  void _setTipMsg(String msg, [bool clear = false]) {
    if (msg.trim().split('\n').length > 1) {
      setState(() {
        msgs = msg.split('\n');
      });
      return;
    }
    setState(() {
      tip = clear ? '' : msg.trim();
      if (clear) {
        msgs = [];
      }
    });
  }

  void stopPlayer() {
    stopDanmakuSocket();
    _controller?.removeListener(() {
      videoPlayerListener(null);
    });
    _controller?.dispose();

    VWindow().setWindowTitle();
    setState(() {
      msgs = [];
      msgsShowed = false;
      playingUrl = null;
      _controller = null;
      cursor = '1';
    });
    windowManager.removeListener(this);
  }

//开始连接斗鱼、忽悠、b站的弹幕
  void startDanmakuSocket(PlayListItem item) async {
    stopDanmakuSocket();
    if (!danmakuManualShow) {
      return;
    }

    DanmakuService().start(item, renderDanmaku);
  }

//断开所有弹幕连接
  void stopDanmakuSocket() {
    if (barrageWallController.isEnabled) {
      barrageWallController.clear();
      //barrageWallController.disable();
    }
    DanmakuService().stop();
  }

//发送弹幕到屏幕
  void renderDanmaku(LiveDanmakuItem? data, {isHackchat = false}) async {
    if (!danmakuManualShow) return;

    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    final fontSize =
        settings != null ? settings['dmFSize'].toDouble() ?? 20.0 : 20.0;

    if (!barrageWallController.isEnabled) barrageWallController.enable();
    barrageWallController.send([
      Bullet(
          child:
              DanmakuRender(data, fontSize: fontSize, isHackchat: isHackchat))
    ]);
  }

  //显示、隐藏节目单
  void toggleEpgDialog() {
    if (playingUrl == null) return;
    final epgUrl =
        PlaylistUtil().pickStrVal(subConf['epg'], playListInfo?.tvgUrl);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return EpgAlertDialog(
            epgUrl: epgUrl,
            urlItem: playingUrl!,
            doPlayback: doPlayback,
          );
        });
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

//获取当前弹幕区域尺寸
  Size getDanmakuSize() => Size(
      playListShowed
          ? getDeviceWidth(context) - PLAYLIST_BAR_WIDTH
          : getDeviceWidth(context),
      getDeviceHeight(context));

  @override
  void dispose() {
    super.dispose();
    _throttle.dispose();
    stopPlayer();
  }

  bool get showLogo {
    if (subConf['type'] == 'file' || subConf['showLogo'] == null) {
      return playListInfo?.showLogo != false;
    }
    return PlaylistUtil().isBoolValid(subConf['showLogo']);
  }

  Widget DefIconLogo() {
    return Image.asset('assets/logo.png');
  }

  Widget PlaceCover() {
    return GestureDetector(
        onTap: () {
          togglePlayList();
        },
        child: Container(
          color: Colors.black12,
          child: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 50,
              children: [
                SizedBox(
                    width: 200,
                    child: !showLogo
                        ? DefIconLogo()
                        : CachedNetworkImage(
                            fit: BoxFit.contain,
                            imageUrl: playingUrl?.tvgLogo ?? '',
                            errorWidget: (context, url, error) => DefIconLogo(),
                          ))
              ],
            ),
          ),
        ));
  }

  // 信息展示
  Widget OsdMsg() {
    final _msgs = tip.isNotEmpty ? [tip] + msgs : msgs;
    return Opacity(
        opacity: _msgs.length > 0 ? 1 : 0,
        child: Container(
            padding: const EdgeInsets.all(10),
            width: getDanmakuSize().width,
            height: getDanmakuSize().height - 90,
            color: msgs.isNotEmpty ? Colors.black38 : Colors.transparent,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _msgs.map((txt) {
                  return Text(
                    txt,
                    softWrap: true,
                    maxLines: 3,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList())));
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      playListShowed = false;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
  }

  @override
  void onWindowClose() {
    stopPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (event) {
          if (cursor == '0') {
            setState(() {
              cursor = '1';
            });
            Future.delayed(Duration(seconds: 5), () {
              setState(() {
                cursor = '0';
              });
            });
          }
        },
        onExit: (_) => {},
        cursor:
            cursor != '0' ? SystemMouseCursors.basic : SystemMouseCursors.none,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                    flex: 4,
                    child: _controller != null &&
                            _controller?.value.isInitialized == true
                        ? AbsorbPointer(
                            absorbing: _controller == null,
                            child: BarrageWall(
                                debug: false, //!Global.isRelease,
                                safeBottomHeight:
                                    getDeviceHeight(context) ~/ 4 * 3,
                                speed: 10,
                                massiveMode: false,
                                speedCorrectionInMilliseconds: 10000,
                                bullets: [],
                                controller: barrageWallController,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AspectRatio(
                                          aspectRatio:
                                              _controller!.value.aspectRatio,
                                          child: VideoPlayer(_controller!)),
                                      MouseRegion(
                                          onHover: (_) {
                                            // print('cachee hover');
                                          },
                                          child: VplayerControls(
                                            _controller!,
                                            togglePlayList: togglePlayList,
                                            sendDanmaku: () {},
                                            toggleMediaInfo: toggleMediaInfo,
                                            toggleDanmaku: toggleDanmakuVisible,
                                            toggleEpgDialog: toggleEpgDialog,
                                            stopPlayer: stopPlayer,
                                            setTipMsg: _setTipMsg,
                                            playingUrl: playingUrl,
                                          ))
                                    ])))
                        : PlaceCover()),
                Container(
                    width: playListShowed ? PLAYLIST_BAR_WIDTH : 0,
                    child: VideoPlaylist(
                      visible: playListShowed,
                      onUrlTap: onPlayUrlChange,
                    )),
              ]),
              GestureDetector(
                  onDoubleTap: () => togglePlayList(),
                  child: PlayerContextMenu(
                      onOpenUrl: onOpenOneUrl,
                      showPlaylist: togglePlayList,
                      playListShowed: playListShowed,
                      child: OsdMsg())),
            ],
          ),
        ));
  }
}
