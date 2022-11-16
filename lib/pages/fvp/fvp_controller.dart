import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:fvp/fvp.dart';

class FvpController extends GetxController {
  final count = 0.obs;
  final _fvpPlugin = Fvp();
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
  void onClose() {}

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initFvp() async {
    int ttId = await _fvpPlugin.createTexture();

    print('textureId: $ttId');

    textureId = ttId;
    update();
    _fvpPlugin.setMedia(
        'https://cn-jlcc-cu-03-08.bilivideo.com/live-bvc/352605/live_415611_4082642/index.m3u8');
    _fvpPlugin.onStateChanged((String state) {
      print("-------------------接收到state改变 $state");
    });
    _fvpPlugin.onMediaStatusChanged((String status) {
      print("============接收到media改变 $status");
    });
    _fvpPlugin.onEvent((Map<String, dynamic> data) {
      print("******接收到event改变 ${data}");
    });
  }

  void setMedia(String url) async {
    EasyLoading.show(status: '正在加载');
    await _fvpPlugin.setMedia(url);
    EasyLoading.dismiss();
  }

  void playOrPause() {
    _fvpPlugin.playOrPause();
    getMediaInfo();
  }

  void getMediaInfo() async {
    final res = await _fvpPlugin.getMediaInfo();
    print(res);

    //  _fvpPlugin.snapshot();
  }

  increment() => count.value++;
}
