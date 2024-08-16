import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart';
import 'package:vvibe/models/playlist_item.dart';

// ignore: must_be_immutable
class FvpVideoFrame extends StatefulWidget {
  FvpVideoFrame(
      {Key? key,
      required this.videoWidget,
      required this.fvp,
      //required this.isFullscreen,
      required this.togglePlayList,
      required this.toggleDanmaku,
      required this.stopPlayer,
      required this.toggleEpgDialog,
      required this.toggleMediaInfo,
      this.sendDanmaku,
      this.playingUrl})
      : super(key: key);

  final Widget videoWidget;
  final Player fvp;
  //final bool isFullscreen;
  final Function togglePlayList;
  final Function toggleMediaInfo;
  final Function toggleDanmaku;
  final Function stopPlayer;
  final Function toggleEpgDialog;
  final Function? sendDanmaku;
  PlayListItem? playingUrl;

  @override
  State<FvpVideoFrame> createState() => _FvpVideoFrameState();
}

class _FvpVideoFrameState extends State<FvpVideoFrame>
    with SingleTickerProviderStateMixin {
  bool _hideControls = true;
  bool showDanmaku = true;
  bool _displayTapped = false;
  Timer? _hideTimer;
  bool isPlaying = true;
  Player get _fvp => widget.fvp;
  int? textureId;
  bool mediaInfoShowed = false;
  TextEditingController danmakuCtrl = new TextEditingController();

  //late StreamSubscription<FvpPlayState>? playPauseStream;
  late AnimationController playPauseController;

  late FocusNode textFocusNode = new FocusNode();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    /* playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
      playPauseStream = player?.playbackStream
        .listen((event) => setPlaybackMode(event.isPlaying)); 
    int state = await _fvp.getState();
    if (FvpPlayState.playing == state) playPauseController.forward(); */
  }

  void stop() async {
    setState(() {
      textureId = null;
    });
    widget.stopPlayer();
    _fvp.state = PlaybackState.stopped;
  }

  @override
  void dispose() {
    // playPauseStream?.cancel();
    //  playPauseController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  void reload() {
    _fvp.state = PlaybackState.stopped;
  }

  void playOrPuase() async {
    bool toPause = PlaybackState.paused == _fvp.state;
    /* if (FvpPlayState.playing == state) {
      playPauseController.reverse();
    } else {
      playPauseController.forward();
    } */
    setState(() {
      isPlaying = toPause;
    });
    print(
        ' ${PlaybackState.playing} ${_fvp.state} ${PlaybackState.playing == _fvp.state} fvp state');
    _fvp.state = _fvp.state == PlaybackState.playing
        ? PlaybackState.paused
        : PlaybackState.playing;
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
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hideControls = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              absorbing: _hideControls,
              child: Stack(
                children: [
                  widget.videoWidget,
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _hideControls ? 0.0 : 1.0,
                    child: Stack(fit: StackFit.expand, children: [
                      //widget.videoWidget,
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
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  color: Colors.white,
                                  splashRadius: 12,
                                  iconSize: 28,
                                  tooltip: isPlaying == true ? '正在播放' : '已暂停',
                                  icon: Icon(isPlaying == true
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    playOrPuase();
                                  },
                                ),
                              ),
                              /* IconButton(
                                tooltip: '重新加载',
                                color: Colors.white,
                                icon: Icon(Icons.rotate_right_outlined),
                                onPressed: () {
                                  reload();
                                },
                              ), */
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                tooltip: '停止',
                                color: Colors.white,
                                icon: Icon(Icons.stop_sharp),
                                onPressed: () {
                                  stop();
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),

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
                          bottom: 10,
                          child: IconButton(
                            tooltip: '点击${showDanmaku ? '关闭' : '显示'}弹幕',
                            color: Colors.white,
                            iconSize: 20,
                            icon: Icon(showDanmaku
                                ? Icons.subtitles_outlined
                                : Icons.subtitles_off_sharp),
                            onPressed: () {
                              _toggleDanmakuShow();
                            },
                          )),
                      Positioned(
                        right: 160,
                        bottom: 10,
                        child: VolumeControl(
                          player: _fvp,
                          thumbColor: Colors.white70,
                        ),
                      ),
                      Positioned(
                          right: 110,
                          bottom: 10,
                          child: IconButton(
                            tooltip: '元数据',
                            color: Colors.white,
                            iconSize: 20,
                            icon: Icon(Icons.info_outline),
                            onPressed: () {
                              _getMetaInfo();
                            },
                          )),

                      Positioned(
                        right: 60,
                        bottom: 10,
                        child: IconButton(
                          tooltip: '节目单',
                          color: Colors.white,
                          icon: Icon(Icons.event_repeat_sharp),
                          onPressed: () {
                            _toggleEpgDialog();
                          },
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: IconButton(
                          tooltip: '播放列表',
                          color: Colors.white,
                          icon: Icon(Icons.menu_sharp),
                          onPressed: () {
                            widget.togglePlayList();
                          },
                        ),
                      )
                    ]),
                  ),
                ],
              )),
        ));
  }
}

class VolumeControl extends StatefulWidget {
  final Player? player;
  final Color? thumbColor;

  const VolumeControl({
    required this.player,
    required this.thumbColor,
    Key? key,
  }) : super(key: key);

  @override
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double volume = 1.0;
  bool _showVolume = false;
  double unmutedVolume = 1.0;

  Player? get player => widget.player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showVolume ? 0.8 : 0,
          child: AbsorbPointer(
            absorbing: !_showVolume,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _showVolume = true);
              },
              onExit: (_) {
                setState(() => _showVolume = false);
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
                        thumbColor: widget.thumbColor,
                      ),
                      child: Slider.adaptive(
                        label: (volume * 1 * 100).roundToDouble().toString(),
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        value: volume.roundToDouble(),
                        onChanged: (v) {
                          print('volume $v');
                          player?.volume = (v);
                          setState(() {
                            volume = v;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) {
            setState(() => _showVolume = true);
          },
          onExit: (_) {
            setState(() => _showVolume = false);
          },
          child: IconButton(
            color: Colors.white,
            onPressed: () => muteUnmute(),
            icon: Icon(getIcon()),
          ),
        ),
      ],
    );
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
      player?.mute = (true);
      setState(() {
        volume = 0;
      });
    } else {
      player?.mute = (false);
      player?.volume = (unmutedVolume);

      setState(() {
        volume = unmutedVolume;
      });
    }
  }
}
