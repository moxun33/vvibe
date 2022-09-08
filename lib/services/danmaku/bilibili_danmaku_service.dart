/*
 * @Author: Moxx 
 * @Date: 2022-09-08 09:29:34 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-08 10:32:22
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:web_socket_channel/io.dart';

class BilibiliDanmakuService {
  BilibiliDanmakuService({required this.roomId, required this.onDanmaku});
  final String roomId;
  final void Function(LiveDanmakuItem? danmaku) onDanmaku;

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

  //开始连接
  void connect() {
    timer = Timer.periodic(const Duration(seconds: 30), (callback) {
      totleTime += 30;
      //sendXinTiaoBao();
      // debugPrint("时间: $totleTime s");
      // _channel!.sink.close();
      // initLive();
      sendHeartBeat();
    });
    initLive();
  }

  //初始化
  Future<void> initLive() async {
    _channel =
        IOWebSocketChannel.connect('wss://broadcastlv.chat.bilibili.com/sub');
    joinRoom(roomId);
    setListener();
  }

  void sendHeartBeat() {
    List<int> code = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, 2, 0, 0, 0, 1];
    _channel!.sink.add(Uint8List.fromList(code));
  }

  //加入房间
  void joinRoom(String id) {
    String msg = "{"
        "\"roomid\":${int.parse(id)},"
        "\"uId\":0,"
        "\"protover\":2,"
        "\"platform\":\"web\","
        "\"clientver\":\"1.10.6\","
        "\"type\":2,"
        "\"key\":\""
        "\"}";
    //debugPrint(msg);
    _channel!.sink.add(encode(7, msg: msg));
    sendHeartBeat();
  }

  //对消息编码
  Uint8List encode(int op, {String? msg}) {
    List<int> header = [0, 0, 0, 0, 0, 16, 0, 1, 0, 0, 0, op, 0, 0, 0, 1];
    if (msg != null) {
      List<int> msgCode = utf8.encode(msg);
      header.addAll(msgCode);
    }
    Uint8List uint8list = Uint8List.fromList(header);
    uint8list = writeInt(uint8list, 0, 4, header.length);
    return uint8list;
  }

  //对消息进行解码
  decode(Uint8List list) {
    int headerLen = readInt(list, 4, 2);
    int ver = readInt(list, 6, 2);
    int op = readInt(list, 8, 4);

    switch (op) {
      case 8:
        debugPrint("B站进入房间");
        break;
      case 5:
        int offset = 0;
        while (offset < list.length) {
          int packLen = readInt(list, offset + 0, 4);
          int headerLen = readInt(list, offset + 4, 2);
          Uint8List body;
          if (ver == 2) {
            body = list.sublist(offset + headerLen, offset + packLen);
            decode(ZLibDecoder().convert(body) as Uint8List);
            offset += packLen;
            continue;
          } else {
            body = list.sublist(offset + headerLen, offset + packLen);
          }
          String data = utf8.decode(body);
          offset += packLen;
          Map<String, dynamic> jd = json.decode(data);
          switch (jd["cmd"]) {
            case "DANMU_MSG":
              String msg = jd["info"][1].toString();
              String name = jd["info"][2][1].toString();
              String uid = jd["info"][2][0].toString();
              // addDanmaku(LiveDanmakuItem(name, msg));
              debugPrint('B站弹幕--> $uid $name: $msg');
              break;
            default:
          }
        }
        break;
      case 3:
        int people = readInt(list, headerLen, 4);
        debugPrint("B站房间人气: $people");
        break;
      default:
    }
  }

  //设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      decode(list);
    });
  }

  //写入编码
  Uint8List writeInt(Uint8List src, int start, int len, int value) {
    int i = 0;
    while (i < len) {
      src[start + i] = value ~/ pow(256, len - i - 1);
      i++;
    }
    return src;
  }

  //从编码读出数字
  int readInt(Uint8List src, int start, int len) {
    int res = 0;
    for (int i = len - 1; i >= 0; i--) {
      res += pow(256, len - i - 1) * src[start + i] as int;
    }
    return res;
  }

  void displose() {
    timer?.cancel();
    _channel?.sink.close();
  }
}
