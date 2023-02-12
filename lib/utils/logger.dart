import 'dart:io';

import 'package:mixin_logger/mixin_logger.dart';

class Logger {
  static Logger _instance = new Logger._();
  factory Logger() => _instance;

  Logger._();

  String _date() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  //创建目录（在应用根目录下）
  Future<Directory> _createDir() async {
    final dir = Directory('logs/' + _date());
    if (!await (dir.exists())) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  init() async {
    final dir = await _createDir();
    await initLogger(
      dir.path,
    );
  }

  static info(String message) {
    i(message);
  }

  static error(String message) {
    e(message);
  }

  static debug(String message) {
    d(message);
  }

  static verbose(String message) {
    v(message);
  }

  static warn(String message) {
    w(message);
  }
}
