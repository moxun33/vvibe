// To parse this JSON data, do
//
//     final channelEpg = channelEpgFromJson(jsonString);

import 'dart:convert';

import 'package:vvibe/utils/playlist/epg_util.dart';

ChannelEpg channelEpgFromJson(String str) =>
    ChannelEpg.fromJson(json.decode(str));

String channelEpgToJson(ChannelEpg data) => json.encode(data.toJson());

class ChannelEpg {
  ChannelEpg({
    required this.date,
    required this.name,
    this.url,
    this.id,
    required this.epg,
  });

  DateTime date;
  int? id;
  String name;
  String? url;
  List<EpgDatum> epg;

  factory ChannelEpg.fromJson(Map<String, dynamic> json) => ChannelEpg(
        date: DateTime.parse(json["date"]),
        id: json["id"],
        name: json["name"],
        url: json["url"],
        epg: List<EpgDatum>.from(
            (json["epg"] ?? json["epg_data"]).map((x) => EpgDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}",
        "name": name,
        "id": id,
        "url": url,
        "epg": List<dynamic>.from(epg.map((x) => x.toJson())),
      };
}

class EpgDatum {
  EpgDatum({
    required this.start,
    this.desc,
    required this.end,
    required this.title,
  });

  DateTime start;
  DateTime end;
  String title;
  String? desc;

  factory EpgDatum.fromJson(Map<String, dynamic> json) => EpgDatum(
        start: EpgUtil().parseEpgTime(json["start"]),
        end: EpgUtil().parseEpgTime(json["end"] ?? json['stop']),
        title: json["title"],
        desc: json["desc"] is String ? json["desc"] : '',
      );

  Map<String, dynamic> toJson() => {
        "start": start,
        "desc": desc,
        "end": end,
        "title": title,
      };
}
