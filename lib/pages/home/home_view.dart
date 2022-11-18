/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2022-11-18 20:02:51
 * @FilePath: \vvibe\lib\pages\home\home_view.dart
 * @Description: 
 * @qmj
 */
import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/fvp_videoframe.dart';

import 'package:vvibe/pages/home/home_controller.dart';
import 'package:get/get.dart';
//import 'package:dart_vlc/dart_vlc.dart';
//import 'package:vvibe/components/player/vlc_videoframe.dart';
import 'package:vvibe/components/playlist/video_playlist.dart';

import 'package:vvibe/components/player/player_context_menu.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(builder: (_) {
        return Stack(
          children: [
            Container(
                child: Row(
              children: <Widget>[
                //  PlayerContextMenu(),

                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onDoubleTap: () => controller.togglePlayList(),
                    child: Container(
                      child: PlayerContextMenu(
                        onOpenUrl: controller.onOpenOneUrl,
                        showPlaylist: controller.togglePlayList,
                        playListShowed: controller.playListShowed,
                        child: BarrageWall(
                            debug: false, //!Global.isRelease,
                            safeBottomHeight: Get.height ~/
                                4 *
                                3, // do not send bullets to the safe area
                            speed: 10,
                            massiveMode: true,
                            speedCorrectionInMilliseconds: 10000,
                            bullets: [],
                            child: controller.textureId != null
                                ? Container(
                                    color: Colors.black,
                                    child: FvpVideoFrame(
                                      toggleDanmaku:
                                          controller.toggleDanmakuVisible,
                                      playingUrl: controller.playingUrl,
                                      videoWidget: Center(
                                          child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Texture(
                                          textureId: controller.textureId!,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      )),
                                      fvp: controller.player,
                                      togglePlayList: controller.togglePlayList,
                                      stopPlayer: controller.stopPlayer,
                                    ))
                                : GestureDetector(
                                    onTap: () {
                                      controller.togglePlayList();
                                    },
                                    child: Container(
                                      color: Colors.black,
                                      child: Center(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 50,
                                          /*          children: [
                                        SizedBox(
                                            width: 200,
                                            child:
                                                Image.asset('assets/logo.png')),
                                        Text('这里空空如也😊',
                                            style: TextStyle(
                                                color: Colors.purple[300],
                                                fontSize: 40))
                                      ], */
                                        ),
                                      ),
                                    ),
                                  ),
                            controller: controller.barrageWallController),
                      ),
                    ),
                  ),
                ),
                Container(
                    width: controller.playListShowed ? PLAYLIST_BAR_WIDTH : 0,
                    child: VideoPlaylist(
                      visible: controller.playListShowed,
                      onUrlTap: controller.onPlayUrlChange,
                    )),
              ],
            )),
            Container(
              padding: const EdgeInsets.all(10),
              width: 500,
              height: 100,
              color: Colors.transparent,
              child: Text(
                controller.tip,
                style: const TextStyle(color: Colors.amber),
              ),
            )
          ],
        );
      }),
    );
  }
}
