/*
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
  // 信息展示
  Widget OsdMsg() {
    final msgs = controller.msgs;
    return Container(
        padding: const EdgeInsets.all(10),
        width: controller.getDanmakuSize().width,
        height: controller.getDanmakuSize().height - 100,
        color: Colors.transparent,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: msgs.map((txt) {
              return Text(
                txt,
                style: TextStyle(color: Colors.amber[600], fontSize: 20),
              );
            }).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(builder: (_) {
        return GestureDetector(
            onDoubleTap: () => controller.togglePlayList(),
            child: Stack(
              children: [
                Container(
                    child: Row(
                  children: <Widget>[

                    Expanded(
                      flex: 4,
                      child: Container(
                        child: BarrageWall(
                            debug: false, //!Global.isRelease,
                            safeBottomHeight: Get.height ~/
                                4 *
                                3, // do not send bullets to the safe area
                            speed: 10,
                            massiveMode: true,
                            speedCorrectionInMilliseconds: 10000,
                            bullets: [],
                            child: ValueListenableBuilder<int?>(
                              valueListenable: controller.player.textureId,
                              builder: (context, id, _) => id == null
                                  ? GestureDetector(
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
                                            children: [
                                              SizedBox(
                                                  width: 200,
                                                  child: CachedNetworkImage(
                                                    imageUrl: controller
                                                            .playingUrl
                                                            ?.tvgLogo ??
                                                        '',
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(
                                                            'assets/logo.png'),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.black,
                                      child: FvpVideoFrame(
                                        toggleMediaInfo:
                                            controller.toggleMediaInfo,
                                        toggleDanmaku:
                                            controller.toggleDanmakuVisible,
                                        toggleEpgDialog:
                                            controller.toggleEpgDialog,
                                        playingUrl: controller.playingUrl,
                                        videoWidget: Center(
                                            child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Texture(
                                            textureId: id,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        )),
                                        fvp: controller.player,
                                        togglePlayList:
                                            controller.togglePlayList,
                                        stopPlayer: controller.stopPlayer,
                                        sendDanmaku: controller.sendDanmaku,
                                      )),
                            ),
                            controller: controller.barrageWallController),
                      ),
                    ),
                    Container(
                        width:
                            controller.playListShowed ? PLAYLIST_BAR_WIDTH : 0,
                        child: VideoPlaylist(
                          visible: controller.playListShowed,
                          onUrlTap: controller.onPlayUrlChange,
                        )),
                  ],
                )),
                PlayerContextMenu(
                    onOpenUrl: controller.onOpenOneUrl,
                    showPlaylist: controller.togglePlayList,
                    playListShowed: controller.playListShowed,
                    child: OsdMsg()),
              ],
            ));
      }),
    );
  }
}
