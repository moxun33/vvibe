import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/services/event_bus.dart';

/* 自定义窗口外观 */
class VWindow {
  static VWindow _instance = new VWindow._();
  factory VWindow() => _instance;

  VWindow._();

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
