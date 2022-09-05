import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:vvibe/global.dart';

import 'package:vvibe/pages/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
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
    final videoFrame = LiveVideoFrame(
      videoWidget: nativeVideo,
      player: controller.player!,
      togglePlayList: controller.togglePlayList,
      stopPlayer: controller.stopPlayer,
    );
    return Scaffold(
      body: GetBuilder<HomeController>(builder: (_) {
        return Container(
            child: controller.playListShowed
                ? Row(
                    children: <Widget>[
                      //  PlayerContextMenu(),
                      Expanded(
                          flex: 4,
                          child: ContextMenuOverlay(
                            child: ContextMenuRegion(
                              contextMenu: PlayerContextMenu(),
                              child: videoFrame,
                            ),
                          )),
                      SizedBox(
                          width: 200,
                          child: VideoPlaylist(
                            onUrlTap: controller.onPlayUrlChange,
                          )),
                    ],
                  )
                : videoFrame);
      }),
    );
  }
}
