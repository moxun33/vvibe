import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:fvp/mdk.dart';

class FvpController extends GetxController {
  final count = 0.obs;
  late final _fvpPlugin = Player();
  int? textureId;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    initFvp();
  }

  @override
  void onClose() {
    _fvpPlugin.dispose();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initFvp() async {
    await updateTexture();
    play(
        'https://cn-jlcc-cu-03-08.bilivideo.com/live-bvc/352605/live_415611_4082642/index.m3u8');
  }

  Future<int> updateTexture() async {
    if (textureId != null) {
      stop();
    }
    int ttId = await _fvpPlugin.updateTexture();

    print('textureId: $ttId');

    textureId = ttId;

    update();
    return ttId;
  }

  void play(url) async {
    EasyLoading.show(status: '正在加载');
    updateTexture();
    _fvpPlugin.media = (url);
    _fvpPlugin.onStateChanged((PlaybackState oState, PlaybackState state) {
      print("-------------------接收到state改变 $state");
    });
    _fvpPlugin.onMediaStatus((MediaStatus oldStatus, MediaStatus status) {
      print("============接收到media改变 $status");
      return true;
    });
    _fvpPlugin.onEvent((MediaEvent e) {
      print("******接收到event改变 ${e}");
      switch (e.category) {
        case 'reader.buffering':
          final percent = e.error.toInt();
          if (percent < 100) {
            EasyLoading.show(status: '缓冲 $percent%');
          } else {
            EasyLoading.dismiss();
          }
          break;
        default:
          break;
      }
    });
    EasyLoading.dismiss();
  }

  void playOrPause() {
    _fvpPlugin.state = _fvpPlugin.state == PlaybackState.playing
        ? PlaybackState.paused
        : PlaybackState.playing;
    getMediaInfo();
  }

  void stop() async {
    textureId = null;
    update();
    _fvpPlugin.state = PlaybackState.stopped;
  }

  void getMediaInfo() async {
    final res = await _fvpPlugin.mediaInfo;
    print('当前视频的mediainfo $res');
    // _fvpPlugin.snapshot();
  }

  increment() => count.value++;
}
