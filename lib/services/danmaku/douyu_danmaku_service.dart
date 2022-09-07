/*
 * @Author: Moxx 
 * @Date: 2022-09-07 14:10:22 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-07 15:06:05
 */
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:web_socket_channel/io.dart';

class DouyuDnamakuService {
  DouyuDnamakuService({required this.roomId, required this.onDanmaku});

  final String roomId;
  final void Function(LiveDanmakuItem? danmaku) onDanmaku;

  Timer? timer;
  IOWebSocketChannel? _channel;
  int totleTime = 0;

  //开始ws连接
  void startConnect() {
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
    _channel!.sink.add(encode(heartbeat));
  }

  //设置监听
  void setListener() {
    _channel!.stream.listen((msg) {
      Uint8List list = Uint8List.fromList(msg);
      final LiveDanmakuItem? danmaku = decode(list);
      onDanmaku(danmaku);
    });
  }

  void login() {
    //print("login");
    String roomID = roomId.toString();
    String login =
        "type@=loginreq/room_id@=$roomID/dfl@=sn@A=105@Sss@A=1/username@=61609154/uid@=61609154/ver@=20190610/aver@=218101901/ct@=0/";
    //print(login);
    _channel!.sink.add(encode(login));
    String joingroup = "type@=joingroup/rid@=$roomID/gid@=-9999/";
    //print(joingroup);
    _channel!.sink.add(encode(joingroup));
    String heartbeat = 'type@=mrkl/';
    //print(heartbeat);
    _channel!.sink.add(encode(heartbeat));
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

  //对消息进行解码
  decode(Uint8List list) {
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
      lenStr = list.sublist(decodedMsgLen, decodedMsgLen + 4);
      len = lenStr.buffer.asByteData().getInt32(0, Endian.little) + 4;
      singleMsgBuffer = list.sublist(decodedMsgLen, decodedMsgLen + len);
      decodedMsgLen += len;
      String byteDatas =
          utf8.decode(singleMsgBuffer.sublist(12, singleMsgBuffer.length - 2));
      //type@=chatmsg/rid@=99999/ct@=2/uid@=151938256/nn@=99999丶让我中个奖吧/txt@=这应该也就18左右吧/cid@=0a99327c7fbb495bbfd1f10000000000/ic@=avanew@Sface@S201707@S21@S18@Sc8e935d61918b28151e86548b1fad59f/level@=9/sahf@=0/cst@=1591546069188/bnn@=大马猴/bl@=7/brid@=99999/hc@=7094bdb067efbb89706bf894ceb8e67c/el@=/lk@=/fl@=7/urlev@=16/dms@=3/pdg@=65/pdk@=18

      //目前只处理弹幕信息所以简单点

      if (byteDatas.contains("type@=chatmsg")) {
        //截取用户名
        var nickname = byteDatas
            .substring(byteDatas.indexOf("nn@="), byteDatas.indexOf("/txt"))
            .replaceAll("nn@=", "");
        //截取弹幕信息
        var content = byteDatas
            .substring(byteDatas.indexOf("txt@="), byteDatas.indexOf("/cid"))
            .replaceAll("txt@=", "");
        debugPrint('斗鱼弹幕-->$nickname: $content');
        danmaku = LiveDanmakuItem(name: nickname, msg: content);
      }
    }
    return danmaku;
  }

  //销毁连接
  void dispose() {
    timer?.cancel();
    _channel?.sink.close();
  }
}
