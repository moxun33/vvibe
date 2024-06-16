// To parse this JSON data, do
//
//     final ipGeo = ipGeoFromJson(jsonString);

import 'dart:convert';

IpGeo ipGeoFromJson(String str) => IpGeo.fromJson(json.decode(str));

String ipGeoToJson(IpGeo data) => json.encode(data.toJson());

class IpGeo {
  String? ip;
  String? country;
  String? province;
  String? city;
  String? county;
  String? region;
  String? isp;

  IpGeo({
    this.ip,
    this.country,
    this.province,
    this.city,
    this.county,
    this.region,
    this.isp,
  });

  factory IpGeo.fromJson(Map<String, dynamic> json) => IpGeo(
        ip: json["ip"],
        country: json["country"],
        province: json["province"],
        city: json["city"],
        county: json["county"],
        region: json["region"],
        isp: json["isp"],
      );

  Map<String, dynamic> toJson() => {
        "ip": ip,
        "country": country,
        "province": province,
        "city": city,
        "county": county,
        "region": region,
        "isp": isp,
      };
}
