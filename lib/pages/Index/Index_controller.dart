import 'package:get/get.dart';
import 'package:fvp/fvp.dart';

class IndexController extends GetxController {
  final _fvpPlugin = Fvp();
  int? textureId;
  // 是否展示欢迎页
  var isloadWelcomePage = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    // startCountdownTimer();
    initPlatformState();
  }

  @override
  void onClose() {}
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    int ttId = await _fvpPlugin.createTexture();

    print('textureId: $ttId');

    textureId = ttId;
    update();
    _fvpPlugin.setMedia(
        'https://cn-jlcc-cu-03-05.bilivideo.com/live-bvc/879488/live_230437990_1763665/index.m3u8');
  }

  // 展示欢迎页，倒计时.5秒之后进入应用
  Future startCountdownTimer() async {
    await Future.delayed(Duration(milliseconds: 500), () {
      isloadWelcomePage.value = false;
    });
  }
}
