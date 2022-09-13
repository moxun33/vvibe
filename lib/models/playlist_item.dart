/*
 * @Author: Moxx
 * @Date: 2022-09-05 14:43:05
 * @LastEditors: Moxx
 * @LastEditTime: 2022-09-13 15:27:45
 * @FilePath: \vvibe\lib\models\playlist_item.dart
 * @Description: 
 * @qmj
 */
// To parse this JSON data, do
//
//     final playListItem = playListItemFromJson(jsonString);

import 'dart:convert';

PlayListItem playListItemFromJson(String str) =>
    PlayListItem.fromJson(json.decode(str));

String playListItemToJson(PlayListItem data) => json.encode(data.toJson());

class PlayListItem {
  PlayListItem(
      {this.group,
      this.name,
      this.tvgId,
      this.url,
      this.tvgLogo,
      this.tvgName});

  String? group;
  String? name;
  String? tvgId;
  String? url;
  String? tvgName;
  String? tvgLogo;

  factory PlayListItem.fromJson(Map<String, dynamic> json) => PlayListItem(
        group: json["group"],
        name: json["name"],
        tvgId: json["tvgId"],
        url: json["url"],
        tvgName: json["tvgName"],
        tvgLogo: json["tvgLogo"],
      );

  Map<String, dynamic> toJson() => {
        "group": group,
        "name": name,
        "tvgId": tvgId,
        "url": url,
        "tvgName": tvgName,
        "tvgLogo": tvgLogo,
      };
}
