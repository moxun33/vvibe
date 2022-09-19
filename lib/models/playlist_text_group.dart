/*
 * @Author: Moxx
 * @Date: 2022-09-19 17:25:43
 * @LastEditors: Moxx
 * @LastEditTime: 2022-09-19 17:25:48
 * @FilePath: \vvibe\lib\models\playlist_text_group.dart
 * @Description: 
 * @qmj
 */
// To parse this JSON data, do
//
//     final playListTextGroup = playListTextGroupFromJson(jsonString);

import 'dart:convert';

PlayListTextGroup playListTextGroupFromJson(String str) =>
    PlayListTextGroup.fromJson(json.decode(str));

String playListTextGroupToJson(PlayListTextGroup data) =>
    json.encode(data.toJson());

class PlayListTextGroup {
  PlayListTextGroup({
    required this.group,
    required this.index,
  });

  String group;
  int index;

  factory PlayListTextGroup.fromJson(Map<String, dynamic> json) =>
      PlayListTextGroup(
        group: json["group"],
        index: json["index"],
      );

  Map<String, dynamic> toJson() => {
        "group": group,
        "index": index,
      };
}
