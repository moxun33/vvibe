// To parse this JSON data, do
//
//     final liveDanmakuItem = liveDanmakuItemFromJson(jsonString);

import 'dart:convert';

LiveDanmakuItem liveDanmakuItemFromJson(String str) =>
    LiveDanmakuItem.fromJson(json.decode(str));

String liveDanmakuItemToJson(LiveDanmakuItem data) =>
    json.encode(data.toJson());

class LiveDanmakuItem {
  LiveDanmakuItem({
    required this.name,
    required this.msg,
    required this.uid,
  });

  String name;
  String msg;
  String uid;

  factory LiveDanmakuItem.fromJson(Map<String, dynamic> json) =>
      LiveDanmakuItem(
        name: json["name"],
        msg: json["uid"],
        uid: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "msg": msg,
        "uid": uid,
      };
}
