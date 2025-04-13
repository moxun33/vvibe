import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

// Define a reusable function
String genRandomStr({int length = 20}) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_';
  final randomString = List.generate(length,
      (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

// 格式化文件大小
String formatFileSize(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }

  const List<String> units = ['KB', 'MB', 'GB', 'TB'];
  double size = bytes.toDouble();
  int unitIndex = 0;

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool isExecuted = false;

  Throttler({required this.milliseconds});

  void run(VoidCallback action) {
    if (isExecuted) {
      return;
    }

    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _timer?.cancel();
      isExecuted = false;
    });
    isExecuted = true;
    action();
  }

  void dispose() {
    _timer?.cancel();
  }
}

// 格式化网速
String formatNetworkSpeed(int speed, [isBits = false]) {
  // 将比特转换为字节
  double _speed = isBits ? speed / 8.0 : speed.toDouble();

  // 根据不同的范围格式化显示为 KB, MB, GB 等
  List<String> units = ['B/s', 'KB/s', 'MB/s', 'GB/s', 'TB/s'];
  int unitIndex = 0;

  // 根据速率大小调整单位
  while (_speed >= 1024 && unitIndex < units.length - 1) {
    _speed /= 1024;
    unitIndex++;
  }

  return '${_speed.toStringAsFixed(unitIndex > 1 ? 1 : 0)} ${units[unitIndex]}';
}
