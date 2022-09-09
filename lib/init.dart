/*
 * @Author: Moxx 
 * @Date: 2022-09-02 16:32:03 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-09 17:02:01
 */
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:vvibe/theme.dart';
import 'package:window_size/window_size.dart';

import 'global.dart';

Future<ThemeData> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMaxSize(const Size(3840, 2160));
    setWindowMinSize(const Size(1280, 720));
  }
  DartVLC.initialize(useFlutterNativeView: Global.useNativeView);

  return genTheme();
}
