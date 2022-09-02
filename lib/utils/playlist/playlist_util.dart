import 'dart:io';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //本地播放列表目录
  Future<Directory> getPlayListDir() async {
    final dir = Directory('./playlist');
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  //获取本地播放列表文件列表
  getPlayListFiles() async {
    final Directory dir = await getPlayListDir();
    return dir.list();
  }
}
