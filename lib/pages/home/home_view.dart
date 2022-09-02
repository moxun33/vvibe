import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vvibe/global.dart';

import 'package:vvibe/pages/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:vvibe/components/videoframe.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nativeVideo = Global.isRelease && Platform.isWindows
        ? NativeVideo(player: controller.player!, showControls: false)
        : Video(player: controller.player!, showControls: false);
    final videoFrame = LiveVideoFrame(
      videoWidget: nativeVideo,
      player: controller.player!,
      togglePlayList: controller.togglePlayList,
    );
    return Scaffold(
      body: GetBuilder<HomeController>(builder: (_) {
        return Container(
            child: controller.playListShowed
                ? Row(
                    children: <Widget>[
                      Expanded(flex: 4, child: videoFrame),
                      Expanded(flex: 1, child: Container()),
                    ],
                  )
                : videoFrame);
      }),
    );
  }
}
