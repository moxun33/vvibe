import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/services/event_bus.dart';

class VWindow {
  static VWindow _instance = new VWindow._();
  factory VWindow() => _instance;

  VWindow._();
//初始化window熟悉
  void initWindow() async {
    doWhenWindowReady(() {
      final initialSize = Size(1280, 720 + CUS_WIN_TITLEBAR_HEIGHT);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = 'VVibe';
      appWindow.show();
    });
  }

  get size {
    return appWindow.size;
  }

//设置window title
  void setWindowTitle(String? title, [String? icon]) {
    final _title = title ?? 'VVibe';
    appWindow.title = _title;
    eventBus.emit('set-window-title', _title);
    setWindowIcon(icon);
  }

//设置window icon
  void setWindowIcon(
    String? icon,
  ) {
    eventBus.emit('set-window-icon', icon ?? '');
  }
}
