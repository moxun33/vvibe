import 'dart:io';

import 'package:intl/intl.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/utils/logger.dart';

class LogFile {
  LogFile._() {
    createDirectory();
  }
  static LogFile? _instance;
  static LogFile get instance => _getOrCreateInstance();
  static LogFile _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    } else {
      _instance = LogFile._();
      return _instance!;
    }
  }

  File? currentFile;
  static bool isFirst = true;

  static log(String content) {
    if (isFirst) {
      isFirst = false;
      LogFile.instance
          .writeFile('-----------------app启动 日志开始-----------------------\n '
              '$content');
    } else {
      LogFile.instance.writeFile(content);
    }
  }

  // 写入一次 文件才会生成
  writeFile(String content) async {
    if (fileName.isNotEmpty) {
      try {
        // print('写入日志文件内容----> $content');
        IOSink sink = currentFile!.openWrite(mode: FileMode.append);
        sink.writeln(content);
        await sink.flush();
        await sink.close();
      } catch (e) {
        MyLogger.error('写入日志文件异常----> $e');
      }
    }
  }

  String fileType = '.txt';

  Future<String> readFile() async {
    try {
      bool exist = await File(fileName).exists();
      if (!exist) {
        print('文件${fileName}不存在');
        return '';
      }
      File file = File(fileName);
      String contents = await file.readAsString();
      print('read 内容----> $contents');
      return contents;
    } catch (e) {
      return '';
    }
  }

  String fileName = '';

  createFileName() {
    if (fileName.isNotEmpty) {
      return fileName;
    }
    var time = DateTime.now();
    // 一天创建一个日志文件 半个月前的日志文件删除
    String name = formatDateTime(time);
    fileName = '$currentDirectory/$name$fileType';
    currentFile = File(fileName);
    return fileName;
  }

  String formatDateTime(DateTime dateTime, [String format = 'yyyy-MM-dd']) {
    return DateFormat(format).format(dateTime);
  }

  String currentDirectory = '';
  //data目录（在应用根目录下）
  Future<Directory> createDir(
      {String dirName = IS_RELEASE ? 'data/logs' : 'assets/logs'}) async {
    final dir = Directory(dirName);
    currentDirectory = dir.path;
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  void createDirectory() async {
    // 创建Directory对象
    Directory dir = await createDir();

    // 检查目录是否存在，如果不存在，则创建目录
    if (!await dir.exists()) {
      // 设置recursive为true以确保创建任何必要的父目录
      await dir.create(recursive: true);
      print('logs Directory created successfully!');
    } else {
      print('logs Directory already exists.');
    }
    createFileName();
    deleteOldFiles();
  }

  showFileList() {}

  deleteAllFiles() {}

  deleteOldFiles() {
    /*
    FileTool.listFilesInDirectory(currentDirectory).then((List<String> value) {
      var nowTime = DateTime.now();
      value.mapIndex((index, element) {
        try {
          List<String> parts = element.split('/'); // 使用 '/' 分割路径
          // 获取最后一段路径
          String lastSegment = parts.isNotEmpty ? parts.last : '';
          if (lastSegment.endsWith(fileType)) {
            lastSegment = lastSegment.substring(0, lastSegment.length - 4);
          }
          // jdLog('获取的文件名字22------$lastSegment');
          DateTime? time = TimeTool.parse(lastSegment);
          if (time is DateTime) {
            Duration difference = time.difference(nowTime);
            int days = difference.inDays;
            if (days > 7) {
              // 删除超过7天的文件
              jdLog('离现在差距$days天 删除了-------->');
              FileTool.deleteFile(element);
            }
          }
        } catch (onError) {
          jdLog('转换后的onError--------> $onError');
        }
      });
    }); */
  }
}
