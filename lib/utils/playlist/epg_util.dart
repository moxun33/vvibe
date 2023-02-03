//epg管理

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/utils/utils.dart';

class EpgUtil {
  static EpgUtil _instance = new EpgUtil._();
  factory EpgUtil() => _instance;

  EpgUtil._();
  //data目录（在应用根目录下）
  Future<Directory> createDir({String dirName = 'data/epg'}) async {
    final dir = Directory(dirName);
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  Future<String> getEpgUrl() async {
    String url = DEF_EPG_URL;
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    if (settings != null) {
      url = settings['egp'] ?? DEF_EPG_URL;
    }
    return url;
  }

  String getToday() {
    DateTime now = DateTime.now();
    return getDate(now);
  }

  String getDate(DateTime dt) {
    final m = dt.month < 10 ? '0${dt.month}' : dt.month;
    final d = dt.day < 10 ? '0${dt.day}' : dt.day;
    return '${dt.year}-${m}-${d}';
  }

  String subDate(DateTime dt, days) {
    return getDate(dt.subtract(Duration(days: days ?? 1)));
  }

//生成7天日期
  List<String> genWeekDays() {
    DateTime now = DateTime.now();
    return [
      subDate(now, 7),
      subDate(now, 6),
      subDate(now, 5),
      subDate(now, 4),
      subDate(now, 3),
      subDate(now, 2),
      subDate(now, 1),
      getDate(now)
    ];
  }

//根据tv-name和date获取节目单
  Future<ChannelEpg?> getChannelEpg(channel, {String? date}) async {
    try {
      Dio dio = Dio();
      final params = {'ch': channel, 'date': date ?? getToday()};
      final resp = await dio.get(await getEpgUrl(), queryParameters: params);
      if (resp.statusCode == 200) {
        return ChannelEpg.fromJson(resp.data);
      } else {
        print('加载节目单失败 $params');
        return null;
      }
    } catch (e) {
      print('加载epg异常 $e');
      return null;
    }
  }
/* 
//  - 下载文件
  static void downloadFile(String downLoadUrl, String savePath,
      void Function(bool result) func) async {
    DateTime timeStart = DateTime.now();
    print('开始下载～当前时间：$timeStart');
    try {
      Dio dio = Dio();
      var response = await dio.download(downLoadUrl, savePath,
          onReceiveProgress: (int count, int total) {
        String progressValue = (count / total * 100).toStringAsFixed(1);
        print('当前下载进度:$progressValue%');
      }).whenComplete(() {
        DateTime timeEnd = DateTime.now();
        //用时多少秒
        int second_use = timeEnd.difference(timeStart).inSeconds;
        print('下载文件耗时$second_use秒');
        func(true);
      });
    } catch (e) {
      print("downloadFile报错：$e");
    }
  }

  downloadEpgDataIsolate() {
    try {
      return downloadEpgData();
    } catch (e) {}
  }

  Future<String> getZipPath() async {
    return '${(await createDir()).path}/epg.xml.tgz';
  }

//TODO:解压epg压缩包, 读取xml内容
  Future<dynamic> unzipEpg() async {
    final savePath = await getZipPath();

    extractFileToDisk(savePath, (await createDir()).path);
  }

  //TODO:解析xml
  Future<dynamic> parseXml(String xml) async {}

  //TODO:获取epg,然后缓存
  Future<dynamic> downloadEpgData() async {
    String url = DEF_EPG_URL;
    /*  final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    if (settings != null) {
      url = settings['egp'] ?? DEF_EPG_URL;
    } */
    final isGz = url.endsWith('.gz');
    if (isGz) {
      final savePath = await getZipPath();
      downloadFile(url, savePath, (result) {
        if (result) {
          print("下载成功");
          unzipEpg();
        } else {
          print("下载失败");
        }
      });
    } else {
      final client = new Dio();
      final resp = await client.get(url);
      print(resp.data);
    }
  } */
}
