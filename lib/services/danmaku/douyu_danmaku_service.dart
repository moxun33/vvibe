/*
 * @Author: Moxx 
 * @Date: 2022-09-07 14:10:22 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-08 12:19:29
 */
import 'dart:async';
import 'dart:convert';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/utils/color_util.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:web_socket_channel/io.dart';

class DouyuDnamakuService {
  DouyuDnamakuService({required this.roomId, required this.onDanmaku});

  final String roomId;
  final void Function(LiveDanmakuItem? danmaku) onDanmaku;

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

  //开始ws连接
  void connect() {
    _channel = IOWebSocketChannel.connect("wss://danmuproxy.douyu.com:8506");
    login();
    setListener();
    timer = Timer.periodic(const Duration(seconds: 45), (callback) {
      totleTime += 45;
      heartBeat();
      //print("时间: $totleTime s");
    });
  }

  //发送心跳包
  void heartBeat() {
    String heartbeat = 'type@=mrkl/';
    _channel?.sink.add(encode(heartbeat));
  }

  //设置监听
  void setListener() {
    _channel?.stream.listen((msg) {
      try {
        Uint8List list = Uint8List.fromList(msg);
        final LiveDanmakuItem? danmaku = decode(list);
        if (danmaku != null && danmaku.msg.isNotEmpty) {
          onDanmaku(danmaku);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void login() {
    debugPrint("斗鱼 登录弹幕");
    String roomID = roomId.toString();
    String login =
        "type@=loginreq/room_id@=$roomID/dfl@=sn@A=105@Sss@A=1/username@=61609154/uid@=61609154/ver@=20190610/aver@=218101901/ct@=0/";
    // print(login);
    _channel?.sink.add(encode(login));
    String joingroup = "type@=joingroup/rid@=$roomID/gid@=-9999/";
    // print(joingroup);
    _channel?.sink.add(encode(joingroup));
    String heartbeat = 'type@=mrkl/';
    //print(heartbeat);
    _channel?.sink.add(encode(heartbeat));
  }

  Uint8List encode(String msg) {
    ByteData header = ByteData(12);
    //定义协议头
    header.setInt32(0, msg.length + 9, Endian.little);
    header.setInt32(4, msg.length + 9, Endian.little);
    header.setInt32(8, 689, Endian.little);
    List<int> data = header.buffer.asUint8List().toList();
    List<int> msgData = utf8.encode(msg);
    data.addAll(msgData);
    //结尾 \0 协议规定
    data.add(0);
    return Uint8List.fromList(data);
  }

//解析消息
  Map<String, String> parseMsg(String msg) {
    final baseArr = msg.split("/");
    Map<String, String> msgMap = {};

    for (var i = 0; i < baseArr.length; i++) {
      final kv = baseArr[i].split('@=');
      if (kv.length > 1) {
        final v = kv[0] == 'ic' ? kv[1].replaceAll('@S', '/') : kv[1];
        msgMap[kv[0]] = v;
      }
    }
    return msgMap;
  }

//弹幕颜色
  Color setDanmakuColor(String color) {
    int num = (int.tryParse(color) ?? 10) - 1;
    switch (num) {
      case 0:
        return ColorUtil.fromHex('#ff0000');
      case 1:
        return ColorUtil.fromHex('#1e87f0');
      case 2:
        return ColorUtil.fromHex('#7ac84b');
      case 3:
        return ColorUtil.fromHex('#ff7f00');
      case 4:
        return ColorUtil.fromHex('#9b39f4');
      case 5:
        return ColorUtil.fromHex('#ff69b4');

      default:
        return ColorUtil.fromDecimal('');
    }
  }

  //对消息进行解码
  decode(Uint8List list) {
    try {
      //消息总长度
      int totalLength = list.length;
      // 当前消息长度
      int len = 0;
      int decodedMsgLen = 0;
      // 单条消息的 buffer
      Uint8List singleMsgBuffer;
      Uint8List lenStr;
      LiveDanmakuItem? danmaku;
      while (decodedMsgLen < totalLength) {
        try {
          lenStr = list.sublist(decodedMsgLen, decodedMsgLen + 4);
          len = lenStr.buffer.asByteData().getInt32(0, Endian.little) + 4;
          singleMsgBuffer = list.sublist(decodedMsgLen, decodedMsgLen + len);
          decodedMsgLen += len;
          String byteDatas = utf8
              .decode(singleMsgBuffer.sublist(12, singleMsgBuffer.length - 2));
          //type@=chatmsg/rid@=4549169/uid@=115902484/nn@=消息内容/txt@=坑/cid@=486d1c603c494315b011110000000000/ic@=avatar_v3@S202208@S788d2957c66f46529a6ec0b8520c3489/level@=33/sahf@=0/col@=5/rg@=4/cst@=1662646767542/bnn@=橙記/bl@=22/brid@=4549169/hc@=eaccdb9a398c4648d7821dca31d4fb97/diaf@=1/hl@=1/ifs@=1/el@=/lk@=/fl@=22/hb@=1232@S/dms@=5/pdg@=29/pdk@=88/ail@=1446@S/ext@=/

          if (byteDatas.startsWith("type@=chatmsg")) {
            final msgMap = parseMsg(byteDatas);
            //debugPrint(msgMap.toString());
            final nickname = msgMap['nn'] ?? '';
            final uid = msgMap['uid'] ?? '';
            final content = msgMap['txt'] ?? '';
            final Color color = setDanmakuColor(msgMap['col'] ?? '');
            final String ic = msgMap['ic'] ?? '';
            final Map<String, dynamic> ext = {
              'avatar': "https://apic.douyucdn.cn/upload/${ic}_big.jpg"
            };
            debugPrint(
                '斗鱼弹幕-->$uid $nickname: $content  $color ${msgMap['col']}');
            //  print(msgMap);
            danmaku = LiveDanmakuItem(
                name: nickname, msg: content, uid: uid, ext: ext, color: color);
          }
        } catch (e) {
          MyLogger.error('斗鱼弹幕解析异常: $e');
          decodedMsgLen = totalLength; //ignore this message data
        }
      }
      return danmaku;
    } catch (e) {
      MyLogger.error('斗鱼弹幕解析ERROR: $e');
    }
  }

  //销毁连接
  void dispose() {
    timer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
