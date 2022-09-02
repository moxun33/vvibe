import 'dart:io';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //本地播放列表目录
  Future<Directory> getPlayListDir() async {
    final dir = Directory('playlist');
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  //获取本地播放列表文件列表
  Future<List<String>> getPlayListFiles() async {
    final Directory dir = await getPlayListDir();
    final dirList = await dir.list().toList();
    final List<String> list = [];
    for (var v in dirList) {
      list.add(v.path);
    }
    return list;
  }

  //解析本地文件的播放列表内容
  Future<List<dynamic>> parsePlaylistFile(String filePath) async {
    if (filePath.endsWith('.m3u')) return parseM3uContents(filePath);
    if (filePath.endsWith('.txt')) return parseTxtContents(filePath);
    return [];
  }

  //解析txt的播放列表文件内容
  parseTxtContents(String filePath) async {}
  //解析m3u的播放列表文件内容
  parseM3uContents(String filePath) async {}
}
