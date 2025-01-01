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
  List<PlayListItem> channels;

  PlayListInfo({
    this.xTvgUrl,
    this.catchup,
    this.catchupSource,
    required this.channels,
  });

  factory PlayListInfo.fromJson(Map<String, dynamic> json) => PlayListInfo(
        xTvgUrl: json["x-tvg-url"] ?? json["tvg-url"],
        catchup: json["catchup"], // "append",
        catchupSource: json[
            "catchup-source"], //"?playseek=\${(b)yyyyMMddHHmmss}-\${(e)yyyyMMddHHmmss}",
        channels: json["channels"] == null
            ? []
            : List<PlayListItem>.from(json["channels"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "x-tvg-url": xTvgUrl,
        "catchup": catchup,
        "catchup-source": catchupSource,
        "channels": List<PlayListItem>.from(channels.map((x) => x)),
      };
}
