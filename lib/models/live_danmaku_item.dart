// To parse this JSON data, do
//
//     final liveDanmakuItem = liveDanmakuItemFromJson(jsonString);

import 'dart:convert';
import 'dart:ui';

LiveDanmakuItem liveDanmakuItemFromJson(String str) =>
    LiveDanmakuItem.fromJson(json.decode(str));

String liveDanmakuItemToJson(LiveDanmakuItem data) =>
    json.encode(data.toJson());

class LiveDanmakuItem {
  LiveDanmakuItem(
      {required this.name,
      required this.msg,
      required this.uid,
      this.ext,
      this.color});

  String name;
  String msg;
  String uid;
  Map<String, dynamic>? ext;
  Color? color;

  factory LiveDanmakuItem.fromJson(Map<String, dynamic> json) =>
      LiveDanmakuItem(
        name: json["name"],
        msg: json["msg"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "msg": msg,
        "uid": uid,
      };
}
