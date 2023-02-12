//开始连接斗鱼、忽悠、b站的弹幕
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/services.dart';
import 'package:vvibe/utils/logger.dart';

class DanmakuService {
  static DanmakuService _instance = new DanmakuService._();
  factory DanmakuService() => _instance;

  DanmakuService._();
  DouyuDnamakuService? _dy;
  BilibiliDanmakuService? _bl;
  HuyaDanmakuService? _hy;

//开始连接斗鱼、虎牙、b站的弹幕
  void start(
      PlayListItem item, void renderDanmaku(LiveDanmakuItem? data)) async {
    try {
      stop();

      if (!(item.tvgId != null && item.tvgId!.isNotEmpty)) return;
      final String rid = item.tvgId!;
      Logger.info('即将登录弹幕 ${item.group} ${item.name} ${item.tvgId}');

      if (item.group!.contains(RegExp('斗鱼|douyu'))) {
        _dy = DouyuDnamakuService(roomId: rid, onDanmaku: renderDanmaku);
        _dy!.connect();
      }

      if (item.group!.contains(RegExp(r'B站|bilibili'))) {
        _bl = BilibiliDanmakuService(roomId: rid, onDanmaku: renderDanmaku);
        _bl?.connect();
      }
      if (item.group!.contains(RegExp('虎牙|huya'))) {
        _hy = HuyaDanmakuService(roomId: rid, onDanmaku: renderDanmaku);
        _hy?.connect();
      }
    } catch (e) {
      Logger.error(e.toString());
    }
  }

//断开所有弹幕连接
  void stop() {
    _dy?.dispose();

    _bl?.displose();

    _hy?.displose();
  }
}
