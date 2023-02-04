// To parse this JSON data, do
//
//     final mediaInfo = mediaInfoFromJson(jsonString);

import 'dart:convert';

MediaInfo mediaInfoFromJson(String str) => MediaInfo.fromJson(json.decode(str));

String mediaInfoToJson(MediaInfo data) => json.encode(data.toJson());

class MediaInfo {
  MediaInfo({
    this.format,
    this.streams,
  });

  Format? format;
  List<Stream>? streams;

  factory MediaInfo.fromJson(Map<String, dynamic> json) => MediaInfo(
        format: json["format"] == null ? null : Format.fromJson(json["format"]),
        streams: json["streams"] == null
            ? []
            : List<Stream>.from(
                json["streams"]!.map((x) => Stream.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "format": format?.toJson(),
        "streams": streams == null
            ? []
            : List<dynamic>.from(streams!.map((x) => x.toJson())),
      };
}

class Format {
  Format({
    this.bitRate,
    this.duration,
    this.filename,
    this.formatLongName,
    this.formatName,
    this.nbPrograms,
    this.nbStreams,
    this.probeScore,
    this.size,
    this.startTime,
    this.tags,
  });

  dynamic bitRate;
  dynamic duration;
  String? filename;
  String? formatLongName;
  String? formatName;
  int? nbPrograms;
  int? nbStreams;
  int? probeScore;
  String? size;
  String? startTime;
  dynamic tags;

  factory Format.fromJson(Map<String, dynamic> json) => Format(
        bitRate: json["bit_rate"],
        duration: json["duration"],
        filename: json["filename"],
        formatLongName: json["format_long_name"],
        formatName: json["format_name"],
        nbPrograms: json["nb_programs"],
        nbStreams: json["nb_streams"],
        probeScore: json["probe_score"],
        size: json["size"],
        startTime: json["start_time"],
        tags: json["tags"],
      );

  Map<String, dynamic> toJson() => {
        "bit_rate": bitRate,
        "duration": duration,
        "filename": filename,
        "format_long_name": formatLongName,
        "format_name": formatName,
        "nb_programs": nbPrograms,
        "nb_streams": nbStreams,
        "probe_score": probeScore,
        "size": size,
        "start_time": startTime,
        "tags": tags,
      };
}

class Stream {
  Stream({
    this.avgFrameRate,
    this.bitRate,
    this.bitsPerRawSample,
    this.bitsPerSample,
    this.channelLayout,
    this.channels,
    this.chromaLocation,
    this.closedCaptions,
    this.codecLongName,
    this.codecName,
    this.codecTag,
    this.codecTagString,
    this.codecTimeBase,
    this.codecType,
    this.codedHeight,
    this.codedWidth,
    this.colorRange,
    this.colorSpace,
    this.displayAspectRatio,
    this.disposition,
    this.duration,
    this.durationTs,
    this.fieldOrder,
    this.hasBFrames,
    this.height,
    this.id,
    this.index,
    this.isAvc,
    this.level,
    this.maxBitRate,
    this.nalLength,
    this.nalLengthSize,
    this.nbFrames,
    this.nbReadFrames,
    this.pixFmt,
    this.profile,
    this.rFrameRate,
    this.refs,
    this.sampleAspectRatio,
    this.sampleFmt,
    this.sampleRate,
    this.sideDataList,
    this.startPts,
    this.startTime,
    this.tags,
    this.timeBase,
    this.width,
  });

  String? avgFrameRate;
  dynamic bitRate;
  String? bitsPerRawSample;
  int? bitsPerSample;
  String? channelLayout;
  int? channels;
  String? chromaLocation;
  int? closedCaptions;
  String? codecLongName;
  String? codecName;
  String? codecTag;
  String? codecTagString;
  String? codecTimeBase;
  String? codecType;
  int? codedHeight;
  int? codedWidth;
  String? colorRange;
  String? colorSpace;
  dynamic displayAspectRatio;
  Map<String, int>? disposition;
  dynamic duration;
  dynamic durationTs;
  dynamic fieldOrder;
  int? hasBFrames;
  int? height;
  dynamic id;
  int? index;
  String? isAvc;
  int? level;
  dynamic maxBitRate;
  dynamic nalLength;
  String? nalLengthSize;
  dynamic nbFrames;
  dynamic nbReadFrames;
  String? pixFmt;
  String? profile;
  String? rFrameRate;
  int? refs;
  dynamic sampleAspectRatio;
  String? sampleFmt;
  String? sampleRate;
  List<dynamic>? sideDataList;
  int? startPts;
  String? startTime;
  Tags? tags;
  String? timeBase;
  int? width;

  factory Stream.fromJson(Map<String, dynamic> json) => Stream(
        avgFrameRate: json["avg_frame_rate"],
        bitRate: json["bit_rate"],
        bitsPerRawSample: json["bits_per_raw_sample"],
        bitsPerSample: json["bits_per_sample"],
        channelLayout: json["channel_layout"],
        channels: json["channels"],
        chromaLocation: json["chroma_location"],
        closedCaptions: json["closed_captions"],
        codecLongName: json["codec_long_name"],
        codecName: json["codec_name"],
        codecTag: json["codec_tag"],
        codecTagString: json["codec_tag_string"],
        codecTimeBase: json["codec_time_base"],
        codecType: json["codec_type"],
        codedHeight: json["coded_height"],
        codedWidth: json["coded_width"],
        colorRange: json["color_range"],
        colorSpace: json["color_space"],
        displayAspectRatio: json["display_aspect_ratio"],
        disposition: Map.from(json["disposition"]!)
            .map((k, v) => MapEntry<String, int>(k, v)),
        duration: json["duration"],
        durationTs: json["duration_ts"],
        fieldOrder: json["field_order"],
        hasBFrames: json["has_b_frames"],
        height: json["height"],
        id: json["id"],
        index: json["index"],
        isAvc: json["is_avc"],
        level: json["level"],
        maxBitRate: json["max_bit_rate"],
        nalLength: json["nal_length"],
        nalLengthSize: json["nal_length_size"],
        nbFrames: json["nb_frames"],
        nbReadFrames: json["nb_read_frames"],
        pixFmt: json["pix_fmt"],
        profile: json["profile"],
        rFrameRate: json["r_frame_rate"],
        refs: json["refs"],
        sampleAspectRatio: json["sample_aspect_ratio"],
        sampleFmt: json["sample_fmt"],
        sampleRate: json["sample_rate"],
        sideDataList: json["side_data_list"] == null
            ? []
            : List<dynamic>.from(json["side_data_list"]!.map((x) => x)),
        startPts: json["start_pts"],
        startTime: json["start_time"],
        tags: json["tags"] == null ? null : Tags.fromJson(json["tags"]),
        timeBase: json["time_base"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "avg_frame_rate": avgFrameRate,
        "bit_rate": bitRate,
        "bits_per_raw_sample": bitsPerRawSample,
        "bits_per_sample": bitsPerSample,
        "channel_layout": channelLayout,
        "channels": channels,
        "chroma_location": chromaLocation,
        "closed_captions": closedCaptions,
        "codec_long_name": codecLongName,
        "codec_name": codecName,
        "codec_tag": codecTag,
        "codec_tag_string": codecTagString,
        "codec_time_base": codecTimeBase,
        "codec_type": codecType,
        "coded_height": codedHeight,
        "coded_width": codedWidth,
        "color_range": colorRange,
        "color_space": colorSpace,
        "display_aspect_ratio": displayAspectRatio,
        "disposition": Map.from(disposition!)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "duration": duration,
        "duration_ts": durationTs,
        "field_order": fieldOrder,
        "has_b_frames": hasBFrames,
        "height": height,
        "id": id,
        "index": index,
        "is_avc": isAvc,
        "level": level,
        "max_bit_rate": maxBitRate,
        "nal_length": nalLength,
        "nal_length_size": nalLengthSize,
        "nb_frames": nbFrames,
        "nb_read_frames": nbReadFrames,
        "pix_fmt": pixFmt,
        "profile": profile,
        "r_frame_rate": rFrameRate,
        "refs": refs,
        "sample_aspect_ratio": sampleAspectRatio,
        "sample_fmt": sampleFmt,
        "sample_rate": sampleRate,
        "side_data_list": sideDataList == null
            ? []
            : List<dynamic>.from(sideDataList!.map((x) => x)),
        "start_pts": startPts,
        "start_time": startTime,
        "tags": tags?.toJson(),
        "time_base": timeBase,
        "width": width,
      };
}

class Tags {
  Tags({
    this.creationTime,
    this.encoder,
    this.handlerName,
    this.language,
  });

  dynamic creationTime;
  dynamic encoder;
  dynamic handlerName;
  dynamic language;

  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        creationTime: json["creation_time"],
        encoder: json["encoder"],
        handlerName: json["handler_name"],
        language: json["language"],
      );

  Map<String, dynamic> toJson() => {
        "creation_time": creationTime,
        "encoder": encoder,
        "handler_name": handlerName,
        "language": language,
      };
}
