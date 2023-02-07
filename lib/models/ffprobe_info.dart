// To parse this JSON data, do
//
//     final fFprobeInfo = fFprobeInfoFromJson(jsonString);

import 'dart:convert';

FFprobeInfo fFprobeInfoFromJson(String str) =>
    FFprobeInfo.fromJson(json.decode(str));

String fFprobeInfoToJson(FFprobeInfo data) => json.encode(data.toJson());

class FFprobeInfo {
  FFprobeInfo({
    this.best,
    this.details,
    this.format,
    this.streams,
  });

  Best? best;
  Details? details;
  FFprobeInfoFormat? format;
  List<Stream>? streams;

  factory FFprobeInfo.fromJson(Map<String, dynamic> json) => FFprobeInfo(
        best: json["best"] == null ? null : Best.fromJson(json["best"]),
        details:
            json["details"] == null ? null : Details.fromJson(json["details"]),
        format: json["format"] == null
            ? null
            : FFprobeInfoFormat.fromJson(json["format"]),
        streams: json["streams"] == null
            ? []
            : List<Stream>.from(
                json["streams"]!.map((x) => Stream.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "best": best?.toJson(),
        "details": details?.toJson(),
        "format": format?.toJson(),
        "streams": streams == null
            ? []
            : List<dynamic>.from(streams!.map((x) => x.toJson())),
      };
}

class Best {
  Best({
    this.audio,
    this.subtitle,
    this.video,
  });

  int? audio;
  dynamic subtitle;
  int? video;

  factory Best.fromJson(Map<String, dynamic> json) => Best(
        audio: json["audio"],
        subtitle: json["subtitle"],
        video: json["video"],
      );

  Map<String, dynamic> toJson() => {
        "audio": audio,
        "subtitle": subtitle,
        "video": video,
      };
}

class Details {
  Details();

  factory Details.fromJson(Map<String, dynamic> json) => Details();

  Map<String, dynamic> toJson() => {};
}

class FFprobeInfoFormat {
  FFprobeInfoFormat({
    this.aliases,
    this.description,
    this.extensions,
    this.mimeTypes,
    this.name,
  });

  List<dynamic>? aliases;
  String? description;
  List<dynamic>? extensions;
  List<dynamic>? mimeTypes;
  String? name;

  factory FFprobeInfoFormat.fromJson(Map<String, dynamic> json) =>
      FFprobeInfoFormat(
        aliases: json["aliases"] == null
            ? []
            : List<dynamic>.from(json["aliases"]!.map((x) => x)),
        description: json["description"],
        extensions: json["extensions"] == null
            ? []
            : List<dynamic>.from(json["extensions"]!.map((x) => x)),
        mimeTypes: json["mime_types"] == null
            ? []
            : List<dynamic>.from(json["mime_types"]!.map((x) => x)),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "aliases":
            aliases == null ? [] : List<dynamic>.from(aliases!.map((x) => x)),
        "description": description,
        "extensions": extensions == null
            ? []
            : List<dynamic>.from(extensions!.map((x) => x)),
        "mime_types": mimeTypes == null
            ? []
            : List<dynamic>.from(mimeTypes!.map((x) => x)),
        "name": name,
      };
}

class Stream {
  Stream({
    this.avgFrameRate,
    this.codec,
    this.content,
    this.discard,
    this.disposition,
    this.duration,
    this.frameRate,
    this.frames,
    this.index,
    this.startTime,
    this.timeBase,
  });

  List<int>? avgFrameRate;
  Codec? codec;
  Content? content;
  String? discard;
  Disposition? disposition;
  dynamic duration;
  List<int>? frameRate;
  int? frames;
  int? index;
  int? startTime;
  List<int>? timeBase;

  factory Stream.fromJson(Map<String, dynamic> json) => Stream(
        avgFrameRate: json["avg_frame_rate"] == null
            ? []
            : List<int>.from(json["avg_frame_rate"]!.map((x) => x)),
        codec: json["codec"] == null ? null : Codec.fromJson(json["codec"]),
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
        discard: json["discard"],
        disposition: json["disposition"] == null
            ? null
            : Disposition.fromJson(json["disposition"]),
        duration: json["duration"],
        frameRate: json["frame_rate"] == null
            ? []
            : List<int>.from(json["frame_rate"]!.map((x) => x)),
        frames: json["frames"],
        index: json["index"],
        startTime: json["start_time"],
        timeBase: json["time_base"] == null
            ? []
            : List<int>.from(json["time_base"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "avg_frame_rate": avgFrameRate == null
            ? []
            : List<dynamic>.from(avgFrameRate!.map((x) => x)),
        "codec": codec?.toJson(),
        "content": content?.toJson(),
        "discard": discard,
        "disposition": disposition?.toJson(),
        "duration": duration,
        "frame_rate": frameRate == null
            ? []
            : List<dynamic>.from(frameRate!.map((x) => x)),
        "frames": frames,
        "index": index,
        "start_time": startTime,
        "time_base":
            timeBase == null ? [] : List<dynamic>.from(timeBase!.map((x) => x)),
      };
}

class Codec {
  Codec({
    this.description,
    this.id,
    this.name,
  });

  String? description;
  String? id;
  String? name;

  factory Codec.fromJson(Map<String, dynamic> json) => Codec(
        description: json["description"],
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "id": id,
        "name": name,
      };
}

class Content {
  Content({
    this.video,
    this.audio,
  });

  Video? video;
  Audio? audio;

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        video: json["video"] == null ? null : Video.fromJson(json["video"]),
        audio: json["audio"] == null ? null : Audio.fromJson(json["audio"]),
      );

  Map<String, dynamic> toJson() => {
        "video": video?.toJson(),
        "audio": audio?.toJson(),
      };
}

class Audio {
  Audio({
    this.align,
    this.bitRate,
    this.channelLayout,
    this.channels,
    this.delay,
    this.format,
    this.frameStart,
    this.frames,
    this.maxBitRate,
    this.sampleRate,
  });

  int? align;
  int? bitRate;
  Disposition? channelLayout;
  int? channels;
  int? delay;
  AudioFormat? format;
  dynamic frameStart;
  int? frames;
  int? maxBitRate;
  int? sampleRate;

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
        align: json["align"],
        bitRate: json["bit_rate"],
        channelLayout: json["channel_layout"] == null
            ? null
            : Disposition.fromJson(json["channel_layout"]),
        channels: json["channels"],
        delay: json["delay"],
        format: json["format"] == null
            ? null
            : AudioFormat.fromJson(json["format"]),
        frameStart: json["frame_start"],
        frames: json["frames"],
        maxBitRate: json["max_bit_rate"],
        sampleRate: json["sample_rate"],
      );

  Map<String, dynamic> toJson() => {
        "align": align,
        "bit_rate": bitRate,
        "channel_layout": channelLayout?.toJson(),
        "channels": channels,
        "delay": delay,
        "format": format?.toJson(),
        "frame_start": frameStart,
        "frames": frames,
        "max_bit_rate": maxBitRate,
        "sample_rate": sampleRate,
      };
}

class Disposition {
  Disposition({
    this.bits,
  });

  int? bits;

  factory Disposition.fromJson(Map<String, dynamic> json) => Disposition(
        bits: json["bits"],
      );

  Map<String, dynamic> toJson() => {
        "bits": bits,
      };
}

class AudioFormat {
  AudioFormat({
    this.f32,
  });

  String? f32;

  factory AudioFormat.fromJson(Map<String, dynamic> json) => AudioFormat(
        f32: json["f32"],
      );

  Map<String, dynamic> toJson() => {
        "f32": f32,
      };
}

class Video {
  Video({
    this.aspectRatio,
    this.bitRate,
    this.chromaLocation,
    this.colorPrimaries,
    this.colorRange,
    this.colorSpace,
    this.colorTransferCharacteristic,
    this.delay,
    this.format,
    this.hasBFrames,
    this.height,
    this.intraDcPrecision,
    this.maxBitRate,
    this.references,
    this.width,
  });

  List<int>? aspectRatio;
  int? bitRate;
  String? chromaLocation;
  String? colorPrimaries;
  String? colorRange;
  String? colorSpace;
  String? colorTransferCharacteristic;
  int? delay;
  String? format;
  bool? hasBFrames;
  int? height;
  int? intraDcPrecision;
  int? maxBitRate;
  int? references;
  int? width;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        aspectRatio: json["aspect_ratio"] == null
            ? []
            : List<int>.from(json["aspect_ratio"]!.map((x) => x)),
        bitRate: json["bit_rate"],
        chromaLocation: json["chroma_location"],
        colorPrimaries: json["color_primaries"],
        colorRange: json["color_range"],
        colorSpace: json["color_space"],
        colorTransferCharacteristic: json["color_transfer_characteristic"],
        delay: json["delay"],
        format: json["format"],
        hasBFrames: json["has_b_frames"],
        height: json["height"],
        intraDcPrecision: json["intra_dc_precision"],
        maxBitRate: json["max_bit_rate"],
        references: json["references"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "aspect_ratio": aspectRatio == null
            ? []
            : List<dynamic>.from(aspectRatio!.map((x) => x)),
        "bit_rate": bitRate,
        "chroma_location": chromaLocation,
        "color_primaries": colorPrimaries,
        "color_range": colorRange,
        "color_space": colorSpace,
        "color_transfer_characteristic": colorTransferCharacteristic,
        "delay": delay,
        "format": format,
        "has_b_frames": hasBFrames,
        "height": height,
        "intra_dc_precision": intraDcPrecision,
        "max_bit_rate": maxBitRate,
        "references": references,
        "width": width,
      };
}
