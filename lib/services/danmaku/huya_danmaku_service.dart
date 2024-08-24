/*
 * @Author: Moxx
 * @Date: 2022-09-08 10:27:05
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-08 12:22:40
 */
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import 'package:vvibe/models/huya_room_profile.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/utils/dart_tars_protocol/tarscodec.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:web_socket_channel/io.dart';

class HuyaDanmakuService {
  HuyaDanmakuService({required this.roomId, required this.onDanmaku});
  final String roomId;
  final void Function(LiveDanmakuItem? danmaku) onDanmaku;

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

  void connect() async {
    MyLogger.info("虎牙登录弹幕");

    _channel = IOWebSocketChannel.connect("wss://cdnws.api.huya.com");

    timer = Timer.periodic(const Duration(seconds: 30), (callback) {
      totleTime += 30;
      heartBeat();
      MyLogger.info("huya弹幕时间: $totleTime s");
    });
    await login();
    setListener();
  }

  //发送心跳包
  void heartBeat() {
    Uint8List heartbeat = huyaWsHeartbeat();
    _channel?.sink.add(heartbeat);
  }

  //设置监听
  void setListener() {
    _channel?.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  Future<Map<String, dynamic>?> _getChatInfo(String roomId) async {
    var resp = await Dio(new BaseOptions(headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
    }))
        .get(
      'https://m.huya.com/$roomId',
    )
        // ignore: body_might_complete_normally_catch_error
        .catchError((e) {
      MyLogger.error('huya弹幕错误：' + e);
    });
    String value = resp.data;
    var dataLive = parse(value);
    var body = dataLive.getElementsByTagName('body')[0];
    var script = body.getElementsByTagName('script').where((s) {
      return s.text.contains('indow.HNF_GLOBAL_INIT');
    });
    String jsonStr =
        script.first.text.replaceAll('window.HNF_GLOBAL_INIT = ', '').trim();
    jsonStr = jsonStr.substring(0, jsonStr.indexOf(',"tLiveStreamInf')) + '}}}';
    //  debugPrint('弹幕srt ' + jsonStr);
    final json = jsonDecode(jsonStr);
    return json;
    //HuyaRoomGlobalProfile.fromJson(json);
  }

  Future<HuyaRoomGlobalProfile?> login() async {
    try {
      // final HuyaRoomGlobalProfile globalProfile = await _getChatInfo(roomId);
      final globalProfile = await _getChatInfo(roomId);
      final int? danmakuId = globalProfile?['roomProfile']['lUid'];
      if (danmakuId == null) return null;
      Uint8List regData = regDataEncode(danmakuId);
      _channel?.sink.add(regData);
      //  MyLogger.info("虎牙弹幕 login success");
      Uint8List heartbeat = huyaWsHeartbeat();
      //print("heartbeat");
      _channel?.sink.add(heartbeat);
      //return globalProfile;
    } catch (e) {
      return null;
    }
  }

  //对消息进行解码
  decode(Uint8List list) {
    List danmaku = danmakuDecode(list);
    String nickname = danmaku[0];
    String message = danmaku[1];
    //TODO: 屏蔽词功能
    if (message != '') {
      MyLogger.info('虎牙弹幕 --> $nickname: $message');
      // addDanmaku(LiveDanmakuItem(nickname, message));
      onDanmaku(LiveDanmakuItem(name: nickname, msg: message, uid: ''));
    }
  }

  void displose() {
    timer?.cancel();
    _channel?.sink.close();
    _channel = null;
    MyLogger.info('关闭虎牙ws');
  }
}
