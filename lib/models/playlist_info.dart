// To parse this JSON data, do
//
//     final playListInfo = playListInfoFromJson(jsonString);

import 'dart:convert';

import 'package:vvibe/models/playlist_item.dart';

PlayListInfo playListInfoFromJson(String str) =>
    PlayListInfo.fromJson(json.decode(str));

String playListInfoToJson(PlayListInfo data) => json.encode(data.toJson());

class PlayListInfo {
  String? tvgUrl;
  String? catchup;
  String? catchupSource;
  bool? showLogo;
  bool? checkAlive;
  List<PlayListItem> channels;

  PlayListInfo({
    this.tvgUrl,
    this.catchup,
    this.catchupSource,
    this.showLogo,
    this.checkAlive,
    required this.channels,
  });

  factory PlayListInfo.fromJson(Map<String, dynamic> json) => PlayListInfo(
        tvgUrl: json["x-tvg-url"] ?? json["tvg-url"] ?? json["tvgUrl"],
        catchup: json["catchup"], // "append",
        catchupSource: json[
            "catchup-source"], //"?playseek=\${(b)yyyyMMddHHmmss}-\${(e)yyyyMMddHHmmss}",
        showLogo: json["x-show-logo"] ?? json["show-logo"] ?? json["showLogo"],
        checkAlive:
            json["x-check-alive"] ?? json["check-alive"] ?? json["checkAlive"],

        channels: json["channels"] == null
            ? []
            : List<PlayListItem>.from(json["channels"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tvgUrl": tvgUrl,
        "catchup": catchup,
        "catchupSource": catchupSource,
        "showLogo": showLogo,
        "checkAlive": checkAlive,
        "channels": List<PlayListItem>.from(channels.map((x) => x)),
      };
}
