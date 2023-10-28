// To parse this JSON data, do
//
//     final channelEpg = channelEpgFromJson(jsonString);

import 'dart:convert';

ChannelEpg channelEpgFromJson(String str) =>
    ChannelEpg.fromJson(json.decode(str));

String channelEpgToJson(ChannelEpg data) => json.encode(data.toJson());

class ChannelEpg {
  ChannelEpg({
    required this.date,
    required this.channelName,
    this.url,
    this.channelId,
    required this.epgData,
  });

  DateTime date;
  String? channelId;
  String channelName;
  String? url;
  List<EpgDatum> epgData;

  factory ChannelEpg.fromJson(Map<String, dynamic> json) => ChannelEpg(
        date: DateTime.parse(json["date"]),
        channelId: json["channel_id"],
        channelName: json["channel_name"],
        url: json["url"],
        epgData: List<EpgDatum>.from(
            json["epg_data"].map((x) => EpgDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "channel_name": channelName,
        "channel_id": channelId,
        "url": url,
        "epg_data": List<dynamic>.from(epgData.map((x) => x.toJson())),
      };
}

class EpgDatum {
  EpgDatum({
    required this.start,
    this.desc,
    required this.end,
    required this.title,
  });

  String start;
  String? desc;
  String end;
  String title;

  factory EpgDatum.fromJson(Map<String, dynamic> json) => EpgDatum(
        start: json["start"],
        desc: json["desc"],
        end: json["end"] ?? json['stop'],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "start": start,
        "desc": desc,
        "end": end,
        "title": title,
      };
}
