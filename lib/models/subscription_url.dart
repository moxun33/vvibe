// To parse this JSON data, do
//
//     final subscriptionUrl = subscriptionUrlFromJson(jsonString);

import 'dart:convert';

SubscriptionUrl subscriptionUrlFromJson(String str) =>
    SubscriptionUrl.fromJson(json.decode(str));

String subscriptionUrlToJson(SubscriptionUrl data) =>
    json.encode(data.toJson());

class SubscriptionUrl {
  SubscriptionUrl({
    required this.id,
    required this.name,
    required this.url,
  });

  String id;
  String name;
  String url;

  factory SubscriptionUrl.fromJson(Map<String, dynamic> json) =>
      SubscriptionUrl(
        id: json["id"],
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
      };
}
