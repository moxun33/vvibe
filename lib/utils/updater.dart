import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vvibe/common/values/consts.dart';

class Updater {
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
      return null;
    });
    final ver = (resp.data['tag_name'] ?? '').replaceAll('v', '');
    print('updater getLatestVersion: ${ver}');
    // Return the tag name, which is always a semantically versioned string.
    return ver;
  }

  static Future<String> getBinaryUrl(version) async {
    // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)

    // Make sure that this link includes the platform extension with which to save your binary.
    // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
    final url =
        "https://ghproxy.cc/https://github.com/moxun33/vvibe/releases/download/v$version/vvibe-v$version-${Platform.operatingSystem}-x64.$platformExt";
    print('updater getBinaryUrl: $url');
    return 'http://pi.mo:7881/tv/vvibe-v0.10.9-windows-x64.zip';
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

  static get downloadDir => '${ASSETS_DIR}/updater';

  static initDownloadDir() {
    final dir = downloadDir;
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync();
    }
  }

  static clearDownloaDir() {
    Directory(downloadDir).deleteSync(recursive: true);
  }

  static Future<File> getDownloadFileLocation(String? latestVersion) async {
    clearDownloaDir();
    initDownloadDir();
    return File(
        '${downloadDir}/vvibe-$latestVersion-${Platform.operatingSystem}-x64.$platformExt');
  }
}
