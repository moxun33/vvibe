// To parse this JSON data, do
//
//     final playListInfo = playListInfoFromJson(jsonString);

import 'dart:convert';

import 'package:vvibe/models/playlist_item.dart';

PlayListInfo playListInfoFromJson(String str) =>
    PlayListInfo.fromJson(json.decode(str));

String playListInfoToJson(PlayListInfo data) => json.encode(data.toJson());

class PlayListInfo {
  String? xTvgUrl;
  String? catchup;
  String? catchupSource;
  bool? showLogo;
  bool? checkAlive;
  List<PlayListItem> channels;

  PlayListInfo({
    this.xTvgUrl,
    this.catchup,
    this.catchupSource,
    this.showLogo,
    this.checkAlive,
    required this.channels,
  });

  factory PlayListInfo.fromJson(Map<String, dynamic> json) => PlayListInfo(
        xTvgUrl: json["x-tvg-url"] ?? json["tvg-url"],
        catchup: json["catchup"], // "append",
        catchupSource: json[
            "catchup-source"], //"?playseek=\${(b)yyyyMMddHHmmss}-\${(e)yyyyMMddHHmmss}",
        showLogo: json["x-show-logo"] ?? json["show-logo"],
        checkAlive: json["x-check-alive"] ?? json["check-alive"],

        channels: json["channels"] == null
            ? []
            : List<PlayListItem>.from(json["channels"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tvg-url": xTvgUrl,
        "catchup": catchup,
        "catchup-source": catchupSource,
        "show-logo": showLogo,
        "check-alive": checkAlive,
        "channels": List<PlayListItem>.from(channels.map((x) => x)),
      };
}
