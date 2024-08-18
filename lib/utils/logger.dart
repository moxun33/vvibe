import 'dart:io';
import 'package:logging/logging.dart';

class MyLogger {
  static MyLogger _instance = new MyLogger._();
  factory MyLogger() => _instance;

  MyLogger._();
  static final log = Logger('MyLogger');

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
    /* final dir = await _createDir();
      await initLogger(
      dir.path,
    ); */
  }

  static info(String message) {
    log.info(message);
  }

  static error(String message) {
    log.fine(message);
  }

  static debug(String message) {
    log.shout(message);
  }

  static verbose(String message) {
    log.severe(message);
  }

  static warn(String message) {
    log.warning(message);
  }
}
