/*
 * @Author: Moxx 
 * @Date: 2022-09-02 16:32:03 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-02 17:08:04
 */
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'global.dart';

void init() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMaxSize(const Size(3840, 2160));
    setWindowMinSize(const Size(1280, 720));
  }
  DartVLC.initialize(
      useFlutterNativeView: Global.isRelease && Platform.isWindows);
/*   BrnInitializer.register(
      allThemeConfig: BrnAllThemeConfig(
    // 全局配置
    commonConfig: BrnCommonConfig(brandPrimary: Color(0xFF7866ff)),
  )); */
}
