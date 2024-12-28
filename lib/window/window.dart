import 'package:flutter/material.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:window_manager/window_manager.dart';

/* 自定义窗口外观 */
class VWindow {
  static VWindow _instance = new VWindow._();
  factory VWindow() => _instance;

  VWindow._();
  initWindow() async {
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setAsFrameless();
      await windowManager.setMinimumSize(const Size(1280, 750));
      await windowManager.setBackgroundColor(Colors.black12);
      await windowManager.setBrightness(Brightness.dark);
      // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.center();
      await windowManager.show();
    });
  }

//设置window title
  void setWindowTitle([String? title, String? icon]) {
    eventBus.emit('set-window-title', title ?? APP_NAME);
    setWindowIcon(icon);
  }

//设置window icon
  void setWindowIcon(
    String? icon,
  ) {
    eventBus.emit('set-window-icon', icon ?? '');
  }

  // 显示隐藏标题栏
  void showTitleBar([bool show = false]) {
    eventBus.emit('show-title-bar', show);
  }
}
