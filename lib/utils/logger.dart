import 'package:logging/logging.dart';

class MyLogger {
  static MyLogger _instance = new MyLogger._();
  factory MyLogger() => _instance;

  MyLogger._();
  static final log = Logger('VVibe');

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
