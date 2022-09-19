/*
 * @Author: Moxx
 * @Date: 2022-09-15 15:59:57
 * @LastEditors: Moxx
 * @LastEditTime: 2022-09-19 16:55:41
 * @FilePath: \vvibe\lib\models\playlist_item.dart
 * @Description: 
 * @qmj
 */
// To parse this JSON data, do
//
//     final playListItem = playListItemFromJson(jsonString);

import 'dart:convert';

/* {
  "name":"",
  "group":"",
  "url":"",
"tvgId":"",
"tvgName":"",
"tvgLogo":"",
"catchup":"append",
"catchup-source":"?playseek=${(b)yyyyMMddHHmmss}-${(e)yyyyMMddHHmmss}"
} */
PlayListItem playListItemFromJson(String str) =>
    PlayListItem.fromJson(json.decode(str));

String playListItemToJson(PlayListItem data) => json.encode(data.toJson());

class PlayListItem {
  PlayListItem({
    this.name,
    this.group,
    this.url,
    this.tvgId,
    this.tvgName,
    this.tvgLogo,
    this.catchup,
    this.catchupSource,
  });

  String? name;
  String? group;
  String? url;
  String? tvgId;
  String? tvgName;
  String? tvgLogo;
  String? catchup;
  String? catchupSource;

  factory PlayListItem.fromJson(Map<String, dynamic> json) => PlayListItem(
        name: json["name"],
        group: json["group"],
        url: json["url"],
        tvgId: json["tvgId"],
        tvgName: json["tvgName"],
        tvgLogo: json["tvgLogo"],
        catchup: json["catchup"],
        catchupSource: json["catchup-source"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "group": group,
        "url": url,
        "tvgId": tvgId,
        "tvgName": tvgName,
        "tvgLogo": tvgLogo,
        "catchup": catchup,
        "catchup-source": catchupSource,
      };
}
