//  download 完整的ffmpeg
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/common/values/storage.dart';
import 'package:vvibe/utils/gzip.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/utils/logger.dart';

class VVFFmpeg {
  static VVFFmpeg _instance = new VVFFmpeg._();
  factory VVFFmpeg() => _instance;

  VVFFmpeg._();

  String downloadUrl() {
    if (Platform.isWindows) {
      return 'https://gitdl.cn/https://github.com/moxun33/vvibe/releases/download/v0.7.9/ffmpeg-master-windows-desktop-vs2022-default.zip';
    }
    return '';
  }

  //data目录（在应用根目录下）
  Future<Directory> createDir(
      {String dirName = IS_RELEASE ? 'data/ffmpeg' : 'assets/ffmpeg'}) async {
    final dir = Directory(dirName);
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  String zipFileName() {
    if (Platform.isWindows) {
      return 'ffmpeg-master-windows-desktop-vs2022-default.zip';
    }
    return '';
  }

  Future<String> getZipPath() async {
    return '${(await createDir()).path}/${zipFileName()}';
  }

  Future<String> getUnzipedDir() async {
    return '${(await createDir()).path}';
  }

  downloadAync() {
    download('');
  }

  void download(String? msg) async {
    try {
      final setting = await LoacalStorage().getJSON(PLAYER_SETTINGS);
      if (setting != null && setting['fullFfmpeg'] != 'true') {
        replaceFfmpeg(rollback: true);
        return;
      }
      Dio dio = Dio();
      final savePath = await getZipPath();
      if (File(savePath).existsSync()) {
        unzipFfmpeg(savePath);
        return;
      }
      DateTime timeStart = DateTime.now();
      MyLogger.info('start downloading ffmpeg～now：$timeStart');
      var resp = await dio.download(downloadUrl(), savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          final currentProgress = received / total;
          MyLogger.info(
              'ffmpeg download progress: ${(currentProgress * 100).toStringAsFixed(0)}%');
        }
      });

      if (resp.statusCode != 200) {
        MyLogger.error(downloadUrl() +
            ' download ffmpeg failed ' +
            resp.statusMessage.toString());
        return null;
      }
      MyLogger.info('$downloadUrl ffmpeg  download success\n $savePath');
      unzipFfmpeg(savePath);
    } catch (e) {
      MyLogger.error("download ffmpeg errors：$e");
    }
  }

  Future<bool> unzipFfmpeg(String savePath) async {
    try {
      MyLogger.info('start unzip ffmpeg');
      final unzipPath = await getUnzipedDir();
      unzipZip(savePath, unzipPath);
      MyLogger.info('unzip ${savePath} success, ${unzipPath}');
      replaceFfmpeg();
      return true;
    } catch (e) {
      MyLogger.error("unzip ffmpeg errors：$e");
      return false;
    }
  }

//替换windows的ffmpeg dll
  Future<bool> replaceFfmpegDll(
      {String filename = 'ffmpeg-7.dll', rollback = false}) async {
    try {
      if (Platform.isWindows) {
        final zipName = await zipFileName();
        final unzipDir = await getUnzipedDir();
        final unzipPath = '${unzipDir}/${zipName}'.replaceAll('.zip', '');
        final ffmpegDllPath = '$unzipPath/bin/x64/${filename}';
        final appDir = IS_RELEASE
            ? Directory.current.path
            : Directory(Platform.resolvedExecutable).parent.path;
        final originDllPth = '${appDir}/${filename}';
        final originDllBakPth = originDllPth + '.bak';
        final oFfmpegDllBak = File(originDllBakPth);
        if (rollback && oFfmpegDllBak.existsSync()) {
          await oFfmpegDllBak.copy(originDllPth);
          MyLogger.info('rollback ${appDir}/${filename}success');
          await oFfmpegDllBak.delete();
          return true;
        }
        if (oFfmpegDllBak.existsSync()) {
          return true;
        }
        if (File(originDllPth).existsSync()) {
          await File(originDllPth).copy(originDllBakPth);
          MyLogger.info('backup ${appDir}/${filename}success');
        }
        if (File(ffmpegDllPath).existsSync()) {
          await File(ffmpegDllPath).copy(originDllPth);
          MyLogger.info('replcing ${appDir}/${filename}success');
        }
      }
      return true;
    } catch (e) {
      MyLogger.error("replace ffmpeg dll errors：$e");
      return false;
    }
  }

  // 替换完整版的ffmpeg
  Future<bool> replaceFfmpeg({rollback = false}) async {
    try {
      // if (!IS_RELEASE) return false;
      if (Platform.isWindows) {
        await replaceFfmpegDll();
      }
      return true;
    } catch (e) {
      MyLogger.error("replace ffmpeg errors: $e");
      return false;
    }
  }
}