import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:vvibe/global.dart';

import 'package:vvibe/pages/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:vvibe/components/player/videoframe.dart';
import 'package:vvibe/components/playlist/video_playlist.dart';

import '../../components/player/player_context_menu.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nativeVideo = Global.useNativeView
        ? NativeVideo(
            player: controller.player!,
            showControls: false,
          )
        : Video(player: controller.player!, showControls: false);

    return Scaffold(
      body: GetBuilder<HomeController>(builder: (_) {
        return Container(
            child: Row(
          children: <Widget>[
            //  PlayerContextMenu(),

            Expanded(
              flex: 4,
              child: GestureDetector(
                onDoubleTap: () => controller.togglePlayList(),
                child: ContextMenuOverlay(
                  child: ContextMenuRegion(
                    contextMenu: PlayerContextMenu(),
                    child: BarrageWall(
                        debug: !Global.isRelease,
                        safeBottomHeight: Get.height ~/
                            4 *
                            3, // do not send bullets to the safe area
                        speed: 10,
                        massiveMode: true,
                        speedCorrectionInMilliseconds: 10000,
                        bullets: [],
                        child: LiveVideoFrame(
                          playingUrl: controller.playingUrl,
                          videoWidget: nativeVideo,
                          player: controller.player,
                          togglePlayList: controller.togglePlayList,
                          stopPlayer: controller.stopPlayer,
                        ),
                        controller: controller.barrageWallController),
                  ),
                ),
              ),
            ),
            Container(
                width:
                    controller.playListShowed ? controller.playListBarWidth : 0,
                child: VideoPlaylist(
                  visible: controller.playListShowed,
                  onUrlTap: controller.onPlayUrlChange,
                )),
          ],
        ));
      }),
    );
  }
}
