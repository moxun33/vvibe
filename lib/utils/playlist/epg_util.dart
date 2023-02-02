//epg管理

import 'dart:io';
import 'package:archive/archive_io.dart';

import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/common/values/values.dart';

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

//解压epg压缩包, 读取xml内容
  Future<dynamic> unzipEpg() async {
    final savePath = await getZipPath();

    extractFileToDisk(savePath, (await createDir()).path);
  }

  //解析xml
  Future<dynamic> parseXml(String xml) async {}

  //获取epg,然后缓存
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
  }
}
