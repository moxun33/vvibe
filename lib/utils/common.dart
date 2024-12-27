import 'dart:math';
import 'dart:async';

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
