// To parse this JSON data, do
//
//     final mediaInfo = mediaInfoFromJson(jsonString);

import 'dart:convert';

import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/models/media_info.dart';

UrlSniffRes mediaInfoFromJson(String str) =>
    UrlSniffRes.fromJson(json.decode(str));

String mediaInfoToJson(UrlSniffRes data) => json.encode(data.toJson());

class UrlSniffRes {
  UrlSniffRes({
    this.url,
    this.status,
    this.statusCode,
    this.mediaInfo,
    this.ipInfo,
    this.index,
    this.duration,
  });

  String? url;
  UrlSniffResStatus? status;
  int? statusCode;
  int? index;
  MediaInfo? mediaInfo;
  String? ipInfo;
  int? duration;

  factory UrlSniffRes.fromJson(Map<String, dynamic> json) => UrlSniffRes(
        url: json["url"],
        status: json["status"],
        statusCode: json["statusCode"],
        mediaInfo: json["mediaInfo"],
        ipInfo: json["ipInfo"],
        index: json["index"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "status": status,
        "statusCode": statusCode,
        "mediaInfo": mediaInfo,
        "ipInfo": ipInfo,
        "index": index,
        "duration": duration,
      };
}
