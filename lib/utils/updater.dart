import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/utils/gzip.dart';

class UpdaterUtil {
  static String get platformExt {
    switch (Platform.operatingSystem) {
      case 'windows':
        {
          return 'zip';
        }

      case 'macos':
        {
          return 'dmg';
        }

      case 'linux':
        {
          return 'tar.xz';
        }
      default:
        {
          return 'zip';
        }
    }
  }

  static Dio dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
  ));

  static const RELEASE_API =
      "https://api.github.com/repos/moxun33/vvibe/releases/latest";

  static Future<String?> getLatestVersion() async {
    // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
    final resp = await dio.get(RELEASE_API).catchError((e) {
      print('${e.toString()} updater getLatestVersion dio errors');
    });
    final ver = (resp.data['tag_name'] ?? '').replaceAll('v', '');
    print('updater getLatestVersion: ${ver}');
    // Return the tag name, which is always a semantically versioned string.
    return ver;
  }

  static int compareVersions(String version1, String version2) {
    // 将版本号拆分成数字列表
    List<int> v1Parts = version1.split('.').map(int.parse).toList();
    List<int> v2Parts = version2.split('.').map(int.parse).toList();

    // 补齐较短的版本号
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);

    // 比较每一部分
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1; // version1 < version2
      if (v1Parts[i] > v2Parts[i]) return 1; // version1 > version2
    }

    // 如果所有部分相等，则版本号相同
    return 0; // version1 == version2
  }

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final current = Global.packageInfo?.version;
      if (current == null) {
        return {'available': false};
      }
      final latest = await getLatestVersion();
      if (latest == null) {
        return {'available': false};
      }
      print('updater isNeedUpdate: latest=> $latest  current=>$current');
      return {
        'available': UpdaterUtil.compareVersions(latest, current) > 0,
        'current': current,
        'latest': latest
      };
    } catch (e) {
      print('updater checkForUpdate errors: $e');
      return null;
    }
  }

  static Future<UpdatStatus?> startDownload(String version) async {
    print('updater start download');
    final url = await getBinaryUrl(version);
    Dio dio = Dio();
    final File savePath = await getDownloadFileLocation(version);
    try {
      // 开始下载文件
      Response response = await dio.download(url, savePath.absolute.path);

      // 检查是否下载成功
      if (response.statusCode == 200) {
        print('更新文件下载成功，已保存到 $savePath');
        // 解压
        if (Platform.isWindows) {
          final res = await unzipZip(savePath.absolute.path, downloadDir);
          return res ? UpdatStatus.readyToInstall : UpdatStatus.error;
        }
        return UpdatStatus.error;
      } else {
        print('下载更新失败，状态码: ${response.statusCode}');
        return UpdatStatus.error;
      }
    } catch (e) {
      print('下载更新文件时发生错误: $e');
      return UpdatStatus.error;
    }
  }

// 安装更新
  static installWindowsUpdate() async {
    try {
      final scriptPath = '${DATA_DIR}\scripts\install-update.bat';

      Process process = await Process.start(scriptPath, [],
          mode: ProcessStartMode.detached // 以新进程执行
          );

      // 输出执行进程的日志
      process.stdout.listen((data) {
        print(String.fromCharCodes(data));
      });

      process.stderr.listen((data) {
        print("Error: ${String.fromCharCodes(data)}");
      });
      exit(0);
    } catch (e) {
      print('Error running PowerShell script: $e');
    }
  }

  static startInstallUpdate() {
    if (!IS_RELEASE) return;

    if (Platform.isWindows) {
      installWindowsUpdate();
    }
  }

  static Future<String> getBinaryUrl(version) async {
    // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)

    // Make sure that this link includes the platform extension with which to save your binary.
    // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
    final url =
        "https://ghproxy.cc/https://github.com/moxun33/vvibe/releases/download/v$version/vvibe-v$version-${Platform.operatingSystem}-x64.$platformExt";
    print('updater getBinaryUrl: $url');
    if (!IS_RELEASE)
      return 'http://pi.mo:7881/tv/vvibe-v0.10.13-windows-x64.zip';
    return url;
  }

  static Future<String?> getChangelog(_, __) async {
    // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
    final resp = await dio
        .get(
      RELEASE_API,
    )
        .catchError((e) {
      print('${e.toString()} updater getChangelog dio errors');
    });
    return resp.data['body'] ?? '';
  }

  static get downloadDir => '${DATA_DIR}/updater';

  static initDownloadDir() {
    final dir = downloadDir;
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync();
    }
  }

  static clearDownloaDir() {
    // 清空子目录
    try {
      if (Directory(downloadDir).existsSync()) {
        Directory(downloadDir).listSync().forEach((element) {
          element.deleteSync(recursive: true);
        });
      }
    } catch (e) {}
    //Directory(downloadDir).deleteSync(recursive: true);
  }

  static Future<File> getDownloadFileLocation(String? latestVersion) async {
    clearDownloaDir();
    initDownloadDir();
    return File(
        '${downloadDir}/${APP_NAME}-$latestVersion-${Platform.operatingSystem}-x64.$platformExt');
  }
}
