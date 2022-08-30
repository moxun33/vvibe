import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class HomeController extends GetxController {
  Player? player;
  dynamic? media;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    player = Player(id: 69420, commandlineArguments: [], registerTexture: true);
  }

  @override
  void onReady() {
    media = Media.network('http://27.47.71.53:808/hls/1/index.m3u8');
    player?.open(media, autoStart: true);
  }

  @override
  void onClose() {
    player?.dispose();
  }
}
