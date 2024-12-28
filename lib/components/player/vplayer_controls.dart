import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fvp/fvp.dart';
import 'package:fvp/mdk.dart';
import 'package:video_player/video_player.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:vvibe/window/window.dart';
import 'package:window_manager/window_manager.dart';

class VplayerControls extends StatefulWidget {
  VplayerControls(this.controller,
      {Key? key,
      required this.togglePlayList,
      required this.toggleDanmaku,
      required this.toggleEpgDialog,
      required this.toggleMediaInfo,
      required this.stopPlayer,
      required this.setTipMsg,
      this.sendDanmaku,
      this.playingUrl})
      : super(key: key);
  final VideoPlayerController controller;
  final Function togglePlayList;
  final Function toggleMediaInfo;
  final Function toggleDanmaku;
  final Function toggleEpgDialog;
  final Function stopPlayer;
  final Function setTipMsg;
  final Function? sendDanmaku;
  PlayListItem? playingUrl;
  @override
  _VplayerControlsState createState() => _VplayerControlsState();
}

class _VplayerControlsState extends State<VplayerControls>
    with SingleTickerProviderStateMixin {
  bool _hideControls = true;
  bool showDanmaku = true;
  bool _displayTapped = false;
  Timer? _hideTimer;
  bool isPlaying = true;
  int? textureId;
  bool mediaInfoShowed = false;
  TextEditingController danmakuCtrl = new TextEditingController();

  //late StreamSubscription<FvpPlayState>? playPauseStream;
  late AnimationController playPauseController;

  late FocusNode textFocusNode = new FocusNode();
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool _isFullScreen = false;
  String message = 'ddss';
  @override
  void initState() {
    super.initState();
    init();
  }

  VideoPlayerController? get player => widget.controller;

  void init() async {
    /* playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
      playPauseStream = player?.playbackStream
        .listen((event) => setPlaybackMode(event.isPlaying));
    int state = await _fvp.getState();
    if (FvpPlayState.playing == state) playPauseController.forward(); */
    eventBus.on('show-vplayer-controls', (e) {
      _cancelAndRestartTimer();
    });
  }

  void stop() async {
    widget.stopPlayer();
  }

  @override
  void dispose() {
    // playPauseStream?.cancel();
    //  playPauseController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  // 切换全屏状态
  void _toggleFullScreen() async {
    final nowFull = await windowManager.isFullScreen();
    windowManager.setFullScreen(!nowFull);
    VWindow().showTitleBar(nowFull);

    setState(() {
      _isFullScreen = !nowFull;
    });
  }

  void reload() {
    player?.play();
  }

  void playOrPuase() async {
    bool toPause = player?.value.isPlaying == true;
    if (toPause) {
      player?.pause();
    } else {
      player?.play();
    }

    /* if (FvpPlayState.playing == state) {
      playPauseController.reverse();
    } else {
      playPauseController.forward();
    } */
    setState(() {
      isPlaying = !toPause;
    });
  }

  void _getMetaInfo() async {
    widget.toggleMediaInfo(!mediaInfoShowed);
    setState(() {
      mediaInfoShowed = !mediaInfoShowed;
    });
  }

  void _toggleDanmakuShow() {
    setState(() {
      showDanmaku = !showDanmaku;
    });
    widget.toggleDanmaku();
  }

  void _toggleEpgDialog() {
    widget.toggleEpgDialog();
  }

  void _sendDanmaku({String? value}) {
    final text = value ?? danmakuCtrl.text;
    if (widget.sendDanmaku == null || text.isEmpty) return;
    widget.sendDanmaku!(danmakuCtrl.text);
    danmakuCtrl.text = '';
  }

  void onTextFocusChange(v) {
    if (v) {
      _hideTimer?.cancel();
    } else {
      _startHideTimer();
    }
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    if (mounted) {
      _startHideTimer();

      setState(() {
        _hideControls = false;
        _displayTapped = true;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _hideControls = true;
        });
      }
    });
  }

  bool isLive() {
    return widget.controller.isLive();
  }

  String _parsePosition() {
    final v = parseDuration(player!.value.position);
    if (v.isEmpty) {
      return parseDuration(player!.value.duration);
    }
    return v;
  }

  String parseDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    if (duration.inDays >= 106751991) {
      return '';
    }
    // 如果有小时，显示为小时:分钟:秒
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    // 如果没有小时，显示为分钟:秒
    else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    // 如果没有小时和分钟，显示为秒
    else {
      return '00:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // 处理键盘事件
  void _onKey(RawKeyEvent event) {
    final key = event.logicalKey;
    if (event.runtimeType.toString() == 'RawKeyUpEvent') {
      if (key == LogicalKeyboardKey.space) {
        playOrPuase();
      }

      if (key == LogicalKeyboardKey.escape) {
        _toggleFullScreen();
      }

      if (key == LogicalKeyboardKey.enter) {
        _toggleFullScreen();
      }
    }
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (key == LogicalKeyboardKey.arrowUp) {
        _setVolume(true);
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _setVolume();
      }
    }
  }

  _setVolume([bool up = false]) async {
    final v = ((await player?.value.volume ?? 0) + (up ? 0.05 : -0.05))
        .clamp(0.0, 1.0);
    widget.setTipMsg('音量:${(v * 100).toInt()}%');
    player?.setVolume(v);
    _clearMessageDelay();
  }

  _clearMessageDelay() {
    Future.delayed(Duration(seconds: 3), () {
      widget.setTipMsg('');
    });
  }

  bool hasAudioTracks() {
    final list = player?.getActiveAudioTracks();
    return list != null && list.length > 0;
  }

  bool hasSubsTracks() {
    final list = player?.getActiveSubtitleTracks();
    return list != null && list.length > 0;
  }

  void _onScroll(PointerScrollEvent event) {
    _setVolume(event.scrollDelta.dy < 0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) => RawKeyboardListener(
            autofocus: true,
            focusNode:
                FocusNode(), // 为了使 RawKeyboardListener 响应事件，需要有一个 FocusNode
            onKey: _onKey, // 监听键盘事件
            child: GestureDetector(
                onTap: () {
                  if (isPlaying == true) {
                    if (_displayTapped) {
                      setState(() => _hideControls = true);
                    } else {
                      _cancelAndRestartTimer();
                    }
                  } else {
                    setState(() => _hideControls = true);
                  }
                },
                child: MouseRegion(
                  onHover: (_) {
                    _cancelAndRestartTimer();
                  },
                  child: AbsorbPointer(
                      absorbing: false,
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: _hideControls ? 0.0 : 1.0,
                            child: Stack(fit: StackFit.expand, children: [
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xCC000000),
                                      Color(0x00000000),
                                      Color(0x00000000),
                                      Color(0x00000000),
                                      Color(0x00000000),
                                      Color(0x00000000),
                                      Color(0xCC000000),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  left: 10,
                                  right: 0,
                                  bottom: 18,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        color: Colors.white,
                                        splashRadius: 12,
                                        iconSize: 28,
                                        tooltip:
                                            isPlaying == true ? '正在播放' : '已暂停',
                                        icon: Icon(isPlaying == true
                                            ? Icons.pause
                                            : Icons.play_arrow),
                                        onPressed: () {
                                          playOrPuase();
                                        },
                                      ),

                                      /* IconButton(
                                tooltip: '重新加载',
                                color: Colors.white,
                                icon: Icon(Icons.rotate_right_outlined),
                                onPressed: () {
                                  reload();
                                },
                              ), */

                                      IconButton(
                                        tooltip: '停止',
                                        color: Colors.white,
                                        icon: Icon(Icons.stop_sharp),
                                        onPressed: () {
                                          stop();
                                        },
                                      ),
                                      AudioTackControl(controller: player),
                                      SubtitleTackControl(controller: player),

                                      /*     Focus(
                                  focusNode: textFocusNode,
                                  onFocusChange: onTextFocusChange,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 150),
                                    width: 220,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 180,
                                          child: TextField(
                                              style: TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: '发个弹幕吧',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[500]),
                                              ),
                                              controller: danmakuCtrl,
                                              onSubmitted: (v) =>
                                                  _sendDanmaku(value: v)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Tooltip(
                                            message: '发弹幕',
                                            child: IconButton(
                                                onPressed: _sendDanmaku,
                                                icon: Icon(Icons.send_sharp)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )), */
                                      const Expanded(
                                          flex: 9, child: SizedBox(width: 8)),
                                    ],
                                  )),
                              Positioned(
                                  right: 220,
                                  bottom: 22,
                                  child: VolumeControl(
                                    widget.controller,
                                    thumbColor: Colors.white70,
                                  )),
                              Positioned(
                                  right: 20,
                                  bottom: 22,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        tooltip:
                                            '点击${showDanmaku ? '关闭' : '显示'}弹幕',
                                        color: Colors.white,
                                        iconSize: 20,
                                        icon: Icon(showDanmaku
                                            ? Icons.subtitles_outlined
                                            : Icons.subtitles_off_sharp),
                                        onPressed: () {
                                          _toggleDanmakuShow();
                                        },
                                      ),
                                      IconButton(
                                        tooltip: '元数据',
                                        color: Colors.white,
                                        iconSize: 20,
                                        icon: Icon(Icons.info_outline),
                                        onPressed: () {
                                          _getMetaInfo();
                                        },
                                      ),
                                      IconButton(
                                        tooltip: '节目单',
                                        color: Colors.white,
                                        iconSize: 18,
                                        icon: Icon(Icons.event_repeat_sharp),
                                        onPressed: () {
                                          _toggleEpgDialog();
                                        },
                                      ),
                                      IconButton(
                                        tooltip: '全屏',
                                        color: Colors.white,
                                        icon: Icon(_isFullScreen
                                            ? Icons.fullscreen_exit
                                            : Icons.fullscreen),
                                        onPressed: () {
                                          _toggleFullScreen();
                                        },
                                      ),
                                      IconButton(
                                        tooltip: '播放列表',
                                        color: Colors.white,
                                        icon: Icon(Icons.menu_sharp),
                                        onPressed: () {
                                          widget.togglePlayList();
                                        },
                                      ),
                                    ],
                                  )),
                              Positioned(
                                left: 10,
                                right: 30,
                                bottom: 5,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 130,
                                        child: Text(
                                          '${_parsePosition()} / ${parseDuration(isLive() ? value.buffered.last.end : value.duration)}',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    Expanded(
                                        child: VideoProgressIndicator(
                                      widget.controller,
                                      colors: VideoProgressColors(
                                        playedColor: AppColors.primaryColor,
                                      ),
                                      allowScrubbing: !isLive(),
                                    )),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          /*     _isFullScreen
                              ? Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 18,
                                  child: IconButton(
                                    tooltip: '退出全屏',
                                    onPressed: () {
                                      _toggleFullScreen();
                                    },
                                    icon: Icon(
                                      Icons.fullscreen_exit,
                                      size: 30,
                                    ),
                                    color: Colors.white,
                                  ))
                              : SizedBox() */
                        ],
                      )),
                ))));
  }
}

class VolumeControl extends StatefulWidget {
  final VideoPlayerController? controller;
  final Color? thumbColor;

  const VolumeControl(
    this.controller, {
    required this.thumbColor,
    Key? key,
  }) : super(key: key);

  @override
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double volume = 1.0;
  double unmutedVolume = 1.0;
  bool _showVolume = false;

  VideoPlayerController? get player => widget.controller;
  void _onScroll(PointerScrollEvent event) {
    final _volume = volume + (event.scrollDelta.dy < 0 ? 0.05 : -0.05);
    print('mytest ${_volume}');
    _setVolume(_volume);
  }

  _setVolume(double v) {
    player?.setVolume(v.clamp(0.0, 1.0));
    setState(() {
      volume = v.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller!,
        builder: (context, value, child) => Column(
              children: [
                /* AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showVolume ? 1 : 0,
          child: AbsorbPointer(
            absorbing: !_showVolume,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _showVolume = true);
              },
              onExit: (_) {
                Future.delayed(Duration(milliseconds: 5000), () {
                  setState(() => _showVolume = false);
                });
              },
              child: SizedBox(
                width: 50,
                height: 150,
                child: Card(
                  color: const Color(0xff424242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryColor,
                        thumbColor: widget.thumbColor,
                      ),
                      child: Slider.adaptive(
                        label: (volume * 1 * 100).roundToDouble().toString(),
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        value: volume.roundToDouble(),
                        autofocus: true,
                        onChanged: _setVolume,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ), */
                Listener(
                    onPointerSignal: (event) {
                      if (event is PointerScrollEvent) {
                        _onScroll(event);
                      }
                    },
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() => _showVolume = true);
                      },
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () => muteUnmute(),
                        icon: Tooltip(
                          message: (value.volume * 1 * 100).toInt().toString(),
                          child: Icon(getIcon()),
                        ),
                      ),
                    )),
              ],
            ));
  }

  IconData getIcon() {
    if (volume > .5) {
      return Icons.volume_up_sharp;
    } else if (volume > 0) {
      return Icons.volume_down_sharp;
    } else {
      return Icons.volume_off_sharp;
    }
  }

  void muteUnmute() async {
    final v = volume;
    if (v > 0) {
      unmutedVolume = v;
      player?.setVolume(0);
      setState(() {
        volume = 0;
      });
    } else {
      player?.setVolume(unmutedVolume);

      setState(() {
        volume = unmutedVolume;
      });
    }
  }
}

class AudioTackControl extends StatefulWidget {
  const AudioTackControl({Key? key, required this.controller})
      : super(key: key);
  final VideoPlayerController? controller;

  @override
  _AudioTackControlState createState() => _AudioTackControlState();
}

class _AudioTackControlState extends State<AudioTackControl> {
  VideoPlayerController? get player => widget.controller;
  AudioStreamInfo? currentAudio;
  int currentAudioIndex = 0;
  @override
  void initState() {
    super.initState();
    setCurrentAudio();
  }

  List<AudioStreamInfo> getAudios() {
    final list = player?.getMediaInfo()?.audio;
    return list != null ? list : [];
  }

  setCurrentAudio([int index = 0]) {
    if (getAudios().length < 1) return;
    final tracks = player?.getActiveAudioTracks();
    if (tracks == null) return;
    final list = player?.getMediaInfo()?.audio ?? [];
    final _index = (index >= 0 && index < list.length ? index : 0)
        .clamp(0, list.length - 1);
    final audio = list[_index];
    setState(() {
      currentAudio = audio;
      currentAudioIndex = _index;
    });
    player?.setAudioTracks([_index]);
  }

  setNextAudio([int n = 0]) {
    setCurrentAudio(n);
  }

  get currentAudioName {
    return currentAudio?.metadata['language'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return getAudios().length > 1
        ? Container(
            child: IconButton(
              tooltip:
                  '声道: [${currentAudioIndex + 1} / ${getAudios().length}] $currentAudioName',
              color: Colors.white,
              icon: Icon(Icons.audiotrack_sharp),
              onPressed: () {
                setNextAudio(currentAudioIndex + 1);
              },
            ),
          )
        : SizedBox();
  }
}

class SubtitleTackControl extends StatefulWidget {
  const SubtitleTackControl({Key? key, required this.controller})
      : super(key: key);
  final VideoPlayerController? controller;

  @override
  _SubtitleTackControlState createState() => _SubtitleTackControlState();
}

class _SubtitleTackControlState extends State<SubtitleTackControl> {
  VideoPlayerController? get player => widget.controller;

  SubtitleStreamInfo? currentSub;
  int currentSubIndex = 0;
  @override
  void initState() {
    super.initState();
    setCurrentSub();
  }

  List<SubtitleStreamInfo> getSubs() {
    final list = player?.getMediaInfo()?.subtitle;
    return list != null ? list : [];
  }

  setCurrentSub([int index = 0]) {
    if (getSubs().length < 1) return;
    final tracks = player?.getActiveSubtitleTracks();
    if (tracks == null) return;
    final list = player?.getMediaInfo()?.subtitle ?? [];
    final _index = (index >= 0 && index < list.length ? index : 0)
        .clamp(0, list.length - 1);
    final sub = list[_index];
    setState(() {
      currentSubIndex = _index;
      currentSub = sub;
    });
    player?.setSubtitleTracks([_index]);
  }

  setNextSub([int n = 0]) {
    setCurrentSub(n);
  }

  get currentSubName {
    return currentSub?.metadata['language'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return getSubs().length > 1
        ? Container(
            child: IconButton(
                tooltip:
                    '字幕: [${currentSubIndex + 1} / ${getSubs().length}] ${currentSubName}',
                color: Colors.white,
                icon: Icon(Icons.subtitles_sharp),
                onPressed: () {
                  setNextSub(currentSubIndex + 1);
                }),
          )
        : SizedBox();
  }
}
