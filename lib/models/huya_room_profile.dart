/*
 * @Author: Moxx 
 * @Date: 2022-09-08 10:59:07 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-08 11:18:27
 */
// To parse this JSON data, do
//
//     final huyaRoomProfile = huyaRoomProfileFromJson(jsonString);

import 'dart:convert';

HuyaRoomProfile huyaRoomProfileFromJson(String str) =>
    HuyaRoomProfile.fromJson(json.decode(str));

String huyaRoomProfileToJson(HuyaRoomProfile data) =>
    json.encode(data.toJson());

class HuyaRoomGlobalProfile {
  HuyaRoomGlobalProfile({
    required this.roomProfile,
    required this.roomInfo,
    required this.roomRecommendLiveList,
    required this.welcomeText,
  });

  HuyaRoomProfile roomProfile;
  HuyaRoomInfo roomInfo;
  List<HuyaRoomRecommendLiveList> roomRecommendLiveList;
  String welcomeText;

  factory HuyaRoomGlobalProfile.fromJson(Map<String, dynamic> json) =>
      HuyaRoomGlobalProfile(
        roomProfile: HuyaRoomProfile.fromJson(json["roomProfile"]),
        roomInfo: HuyaRoomInfo.fromJson(json["roomInfo"]),
        roomRecommendLiveList: List<HuyaRoomRecommendLiveList>.from(
            json["roomRecommendLiveList"]
                .map((x) => HuyaRoomRecommendLiveList.fromJson(x))),
        welcomeText: json["welcomeText"],
      );

  Map<String, dynamic> toJson() => {
        "roomProfile": roomProfile.toJson(),
        "roomInfo": roomInfo.toJson(),
        "roomRecommendLiveList":
            List<dynamic>.from(roomRecommendLiveList.map((x) => x.toJson())),
        "welcomeText": welcomeText,
      };
}

class HuyaRoomInfo {
  HuyaRoomInfo({
    required this.tCacheInfo,
    required this.eLiveStatus,
    required this.tProfileInfo,
    required this.tLiveInfo,
    required this.tRecentLive,
    required this.tReplayInfo,
    required this.classname,
  });

  HuyaTCacheInfo tCacheInfo;
  int eLiveStatus;
  HuyaTProfileInfo tProfileInfo;
  HuyaTLiveInfo tLiveInfo;
  HuyaTLiveInfo tRecentLive;
  HuyaTLiveInfo tReplayInfo;
  String classname;

  factory HuyaRoomInfo.fromJson(Map<String, dynamic> json) => HuyaRoomInfo(
        tCacheInfo: HuyaTCacheInfo.fromJson(json["tCacheInfo"]),
        eLiveStatus: json["eLiveStatus"],
        tProfileInfo: HuyaTProfileInfo.fromJson(json["tProfileInfo"]),
        tLiveInfo: HuyaTLiveInfo.fromJson(json["tLiveInfo"]),
        tRecentLive: HuyaTLiveInfo.fromJson(json["tRecentLive"]),
        tReplayInfo: HuyaTLiveInfo.fromJson(json["tReplayInfo"]),
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "tCacheInfo": tCacheInfo.toJson(),
        "eLiveStatus": eLiveStatus,
        "tProfileInfo": tProfileInfo.toJson(),
        "tLiveInfo": tLiveInfo.toJson(),
        "tRecentLive": tRecentLive.toJson(),
        "tReplayInfo": tReplayInfo.toJson(),
        "_classname": classname,
      };
}

class HuyaTCacheInfo {
  HuyaTCacheInfo({
    required this.iSourceType,
    required this.iUpdateTime,
    required this.classname,
  });

  int iSourceType;
  int iUpdateTime;
  String classname;

  factory HuyaTCacheInfo.fromJson(Map<String, dynamic> json) => HuyaTCacheInfo(
        iSourceType: json["iSourceType"],
        iUpdateTime: json["iUpdateTime"],
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "iSourceType": iSourceType,
        "iUpdateTime": iUpdateTime,
        "_classname": classname,
      };
}

class HuyaTLiveInfo {
  HuyaTLiveInfo({
    required this.lUid,
    required this.lYyid,
    required this.sNick,
    required this.iSex,
    required this.iLevel,
    required this.sAvatar180,
    required this.lProfileRoom,
    required this.sPrivateHost,
    required this.sProfileHomeHost,
    required this.iIsPlatinum,
    required this.lActivityId,
    required this.lActivityCount,
    required this.iGid,
    required this.iGameId,
    required this.sGameFullName,
    required this.sGameHostName,
    required this.iBussType,
    required this.lLiveId,
    required this.lChannel,
    required this.lLiveChannel,
    required this.lUserCount,
    required this.lTotalCount,
    required this.iStartTime,
    required this.iEndTime,
    required this.iTime,
    required this.sRoomName,
    required this.sIntroduction,
    required this.sPreviewUrl,
    required this.iLiveSourceType,
    required this.iScreenType,
    required this.sScreenshot,
    required this.iRecommendStatus,
    required this.sRecommendTagName,
    required this.iIsSecret,
    required this.iCameraOpen,
    required this.iCodecType,
    required this.iIsBluRay,
    required this.sBluRayMBitRate,
    required this.iBitRate,
    required this.lLiveCompatibleFlag,
    required this.iUpdateCacheTime,
    required this.lMultiStreamFlag,
    required this.tLiveStreamInfo,
    required this.iIsRoomPay,
    required this.iIsWatchTogetherVip,
    required this.tRoomPayInfo,
    required this.classname,
    required this.tReplayVideoInfo,
    required this.sRoomPayTag,
    required this.mpCorner,
    required this.tImgRecInfo,
  });

  int lUid;
  int lYyid;
  String sNick;
  int iSex;
  int iLevel;
  String sAvatar180;
  int lProfileRoom;
  String sPrivateHost;
  String sProfileHomeHost;
  int iIsPlatinum;
  int lActivityId;
  int lActivityCount;
  int iGid;
  int iGameId;
  String sGameFullName;
  String sGameHostName;
  int iBussType;
  double lLiveId;
  int lChannel;
  int lLiveChannel;
  int lUserCount;
  int lTotalCount;
  int iStartTime;
  int iEndTime;
  int iTime;
  String sRoomName;
  String sIntroduction;
  String sPreviewUrl;
  int iLiveSourceType;
  int iScreenType;
  String sScreenshot;
  int iRecommendStatus;
  String sRecommendTagName;
  int iIsSecret;
  int iCameraOpen;
  int iCodecType;
  int iIsBluRay;
  SBluRayMBitRate sBluRayMBitRate;
  int iBitRate;
  int lLiveCompatibleFlag;
  int iUpdateCacheTime;
  int lMultiStreamFlag;
  HuyaTLiveStreamInfo? tLiveStreamInfo;
  int iIsRoomPay;
  int iIsWatchTogetherVip;
  HuyaTRoomPayInfo? tRoomPayInfo;
  String classname;
  HuyaTReplayVideoInfo? tReplayVideoInfo;
  String sRoomPayTag;
  HuyaMpCorner? mpCorner;
  HuyaTImgRecInfo? tImgRecInfo;

  factory HuyaTLiveInfo.fromJson(Map<String, dynamic> json) => HuyaTLiveInfo(
        lUid: json["lUid"],
        lYyid: json["lYyid"],
        sNick: json["sNick"],
        iSex: json["iSex"],
        iLevel: json["iLevel"],
        sAvatar180: json["sAvatar180"],
        lProfileRoom: json["lProfileRoom"],
        sPrivateHost: json["sPrivateHost"],
        sProfileHomeHost:
            json["sProfileHomeHost"] == null ? null : json["sProfileHomeHost"],
        iIsPlatinum: json["iIsPlatinum"],
        lActivityId: json["lActivityId"],
        lActivityCount: json["lActivityCount"],
        iGid: json["iGid"],
        iGameId: json["iGameId"],
        sGameFullName: json["sGameFullName"],
        sGameHostName: json["sGameHostName"],
        iBussType: json["iBussType"],
        lLiveId: json["lLiveId"].toDouble(),
        lChannel: json["lChannel"],
        lLiveChannel: json["lLiveChannel"],
        lUserCount: json["lUserCount"],
        lTotalCount: json["lTotalCount"],
        iStartTime: json["iStartTime"],
        iEndTime: json["iEndTime"] == null ? null : json["iEndTime"],
        iTime: json["iTime"],
        sRoomName: json["sRoomName"],
        sIntroduction: json["sIntroduction"],
        sPreviewUrl: json["sPreviewUrl"],
        iLiveSourceType: json["iLiveSourceType"],
        iScreenType: json["iScreenType"],
        sScreenshot: json["sScreenshot"],
        iRecommendStatus:
            json["iRecommendStatus"] == null ? null : json["iRecommendStatus"],
        sRecommendTagName: json["sRecommendTagName"] == null
            ? null
            : json["sRecommendTagName"],
        iIsSecret: json["iIsSecret"],
        iCameraOpen: json["iCameraOpen"],
        iCodecType: json["iCodecType"] == null ? null : json["iCodecType"],
        iIsBluRay: json["iIsBluRay"],
        sBluRayMBitRate: sBluRayMBitRateValues.map![json["sBluRayMBitRate"]]!,
        iBitRate: json["iBitRate"],
        lLiveCompatibleFlag: json["lLiveCompatibleFlag"],
        iUpdateCacheTime:
            json["iUpdateCacheTime"] == null ? null : json["iUpdateCacheTime"],
        lMultiStreamFlag:
            json["lMultiStreamFlag"] == null ? null : json["lMultiStreamFlag"],
        tLiveStreamInfo: json["tLiveStreamInfo"] == null
            ? null
            : HuyaTLiveStreamInfo.fromJson(json["tLiveStreamInfo"]),
        iIsRoomPay: json["iIsRoomPay"] == null ? null : json["iIsRoomPay"],
        iIsWatchTogetherVip: json["iIsWatchTogetherVip"] == null
            ? null
            : json["iIsWatchTogetherVip"],
        tRoomPayInfo: json["tRoomPayInfo"] == null
            ? null
            : HuyaTRoomPayInfo.fromJson(json["tRoomPayInfo"]),
        classname: json["_classname"],
        tReplayVideoInfo: json["tReplayVideoInfo"] == null
            ? null
            : HuyaTReplayVideoInfo.fromJson(json["tReplayVideoInfo"]),
        sRoomPayTag: json["sRoomPayTag"] == null ? null : json["sRoomPayTag"],
        mpCorner: json["mpCorner"] == null
            ? null
            : HuyaMpCorner.fromJson(json["mpCorner"]),
        tImgRecInfo: json["tImgRecInfo"] == null
            ? null
            : HuyaTImgRecInfo.fromJson(json["tImgRecInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "lUid": lUid,
        "lYyid": lYyid,
        "sNick": sNick,
        "iSex": iSex,
        "iLevel": iLevel,
        "sAvatar180": sAvatar180,
        "lProfileRoom": lProfileRoom,
        "sPrivateHost": sPrivateHost,
        "sProfileHomeHost": sProfileHomeHost,
        "iIsPlatinum": iIsPlatinum,
        "lActivityId": lActivityId,
        "lActivityCount": lActivityCount,
        "iGid": iGid,
        "iGameId": iGameId,
        "sGameFullName": sGameFullName,
        "sGameHostName": sGameHostName,
        "iBussType": iBussType,
        "lLiveId": lLiveId,
        "lChannel": lChannel,
        "lLiveChannel": lLiveChannel,
        "lUserCount": lUserCount,
        "lTotalCount": lTotalCount,
        "iStartTime": iStartTime,
        "iEndTime": iEndTime,
        "iTime": iTime,
        "sRoomName": sRoomName,
        "sIntroduction": sIntroduction,
        "sPreviewUrl": sPreviewUrl,
        "iLiveSourceType": iLiveSourceType,
        "iScreenType": iScreenType,
        "sScreenshot": sScreenshot,
        "iRecommendStatus": iRecommendStatus,
        "sRecommendTagName": sRecommendTagName,
        "iIsSecret": iIsSecret,
        "iCameraOpen": iCameraOpen,
        "iCodecType": iCodecType,
        "iIsBluRay": iIsBluRay,
        "sBluRayMBitRate": sBluRayMBitRateValues.reverse[sBluRayMBitRate],
        "iBitRate": iBitRate,
        "lLiveCompatibleFlag": lLiveCompatibleFlag,
        "iUpdateCacheTime": iUpdateCacheTime,
        "lMultiStreamFlag": lMultiStreamFlag,
        "tLiveStreamInfo":
            tLiveStreamInfo == null ? null : tLiveStreamInfo?.toJson(),
        "iIsRoomPay": iIsRoomPay,
        "iIsWatchTogetherVip": iIsWatchTogetherVip,
        "tRoomPayInfo": tRoomPayInfo == null ? null : tRoomPayInfo?.toJson(),
        "_classname": classname,
        "tReplayVideoInfo":
            tReplayVideoInfo == null ? null : tReplayVideoInfo?.toJson(),
        "sRoomPayTag": sRoomPayTag,
        "mpCorner": mpCorner == null ? null : mpCorner?.toJson(),
        "tImgRecInfo": tImgRecInfo == null ? null : tImgRecInfo?.toJson(),
      };
}

class HuyaMpCorner {
  HuyaMpCorner({
    required this.kproto,
    required this.bKey,
    required this.bValue,
    required this.value,
    required this.classname,
  });

  HuyaProto kproto;
  int bKey;
  int bValue;
  HuyaMpCornerValue value;
  MpCornerClassname classname;

  factory HuyaMpCorner.fromJson(Map<String, dynamic> json) => HuyaMpCorner(
        kproto: HuyaProto.fromJson(json["_kproto"]),
        bKey: json["_bKey"],
        bValue: json["_bValue"],
        value: HuyaMpCornerValue.fromJson(json["value"]),
        classname: mpCornerClassnameValues.map![json["_classname"]]!,
      );

  Map<String, dynamic> toJson() => {
        "_kproto": kproto.toJson(),
        "_bKey": bKey,
        "_bValue": bValue,
        "value": value.toJson(),
        "_classname": mpCornerClassnameValues.reverse[classname],
      };
}

enum MpCornerClassname { MAP_LT_STRING_LIVE_LIST_CORNER_INFO_GT }

final mpCornerClassnameValues = EnumValues({
  "map&lt;string,LiveList.CornerInfo&gt;":
      MpCornerClassname.MAP_LT_STRING_LIVE_LIST_CORNER_INFO_GT
});

class HuyaProto {
  HuyaProto({
    required this.classname,
  });

  KprotoClassname classname;

  factory HuyaProto.fromJson(Map<String, dynamic> json) => HuyaProto(
        classname: kprotoClassnameValues.map![json["_classname"]]!,
      );

  Map<String, dynamic> toJson() => {
        "_classname": kprotoClassnameValues.reverse[classname],
      };
}

enum KprotoClassname { STRING, INT32 }

final kprotoClassnameValues = EnumValues(
    {"int32": KprotoClassname.INT32, "string": KprotoClassname.STRING});

class HuyaMpCornerValue {
  HuyaMpCornerValue({
    required this.listPos2,
    required this.listPos1,
  });

  HuyaListPos? listPos2;
  HuyaListPos? listPos1;

  factory HuyaMpCornerValue.fromJson(Map<String, dynamic> json) =>
      HuyaMpCornerValue(
        listPos2: json["ListPos2"] == null
            ? null
            : HuyaListPos.fromJson(json["ListPos2"]),
        listPos1: json["ListPos1"] == null
            ? null
            : HuyaListPos.fromJson(json["ListPos1"]),
      );

  Map<String, dynamic> toJson() => {
        "ListPos2": listPos2 == null ? null : listPos2?.toJson(),
        "ListPos1": listPos1 == null ? null : listPos1?.toJson(),
      };
}

class HuyaListPos {
  HuyaListPos({
    required this.sContent,
    required this.sIcon,
    required this.classname,
  });

  String sContent;
  String sIcon;
  ListPos1Classname classname;

  factory HuyaListPos.fromJson(Map<String, dynamic> json) => HuyaListPos(
        sContent: json["sContent"],
        sIcon: json["sIcon"],
        classname: listPos1ClassnameValues.map![json["_classname"]]!,
      );

  Map<String, dynamic> toJson() => {
        "sContent": sContent,
        "sIcon": sIcon,
        "_classname": listPos1ClassnameValues.reverse[classname],
      };
}

enum ListPos1Classname { LIVE_LIST_CORNER_INFO }

final listPos1ClassnameValues = EnumValues(
    {"LiveList.CornerInfo": ListPos1Classname.LIVE_LIST_CORNER_INFO});

enum SBluRayMBitRate { THE_4_M, EMPTY, THE_8_M }

final sBluRayMBitRateValues = EnumValues({
  "": SBluRayMBitRate.EMPTY,
  "4M": SBluRayMBitRate.THE_4_M,
  "8M": SBluRayMBitRate.THE_8_M
});

class HuyaTImgRecInfo {
  HuyaTImgRecInfo({
    required this.sType,
    required this.sValue,
    required this.sTypeDesc,
    required this.classname,
  });

  String sType;
  String sValue;
  String sTypeDesc;
  TImgRecInfoClassname classname;

  factory HuyaTImgRecInfo.fromJson(Map<String, dynamic> json) =>
      HuyaTImgRecInfo(
        sType: json["sType"],
        sValue: json["sValue"],
        sTypeDesc: json["sTypeDesc"],
        classname: tImgRecInfoClassnameValues.map![json["_classname"]]!,
      );

  Map<String, dynamic> toJson() => {
        "sType": sType,
        "sValue": sValue,
        "sTypeDesc": sTypeDesc,
        "_classname": tImgRecInfoClassnameValues.reverse[classname],
      };
}

enum TImgRecInfoClassname { LIVE_LIST_IMG_REC_INFO }

final tImgRecInfoClassnameValues = EnumValues(
    {"LiveList.ImgRecInfo": TImgRecInfoClassname.LIVE_LIST_IMG_REC_INFO});

class HuyaTLiveStreamInfo {
  HuyaTLiveStreamInfo({
    required this.vStreamInfo,
    required this.mStreamRatio,
    required this.vBitRateInfo,
    required this.iDefaultLiveStreamBitRate,
    required this.sDefaultLiveStreamLine,
    required this.sDefaultLiveStreamSuffix,
    required this.sDefaultLiveStreamUrl,
    required this.classname,
  });

  HuyaVStreamInfo vStreamInfo;
  HuyaMStreamRatio mStreamRatio;
  HuyaVList vBitRateInfo;
  int iDefaultLiveStreamBitRate;
  String sDefaultLiveStreamLine;
  String sDefaultLiveStreamSuffix;
  String sDefaultLiveStreamUrl;
  String classname;

  factory HuyaTLiveStreamInfo.fromJson(Map<String, dynamic> json) =>
      HuyaTLiveStreamInfo(
        vStreamInfo: HuyaVStreamInfo.fromJson(json["vStreamInfo"]),
        mStreamRatio: HuyaMStreamRatio.fromJson(json["mStreamRatio"]),
        vBitRateInfo: HuyaVList.fromJson(json["vBitRateInfo"]),
        iDefaultLiveStreamBitRate: json["iDefaultLiveStreamBitRate"],
        sDefaultLiveStreamLine: json["sDefaultLiveStreamLine"],
        sDefaultLiveStreamSuffix: json["sDefaultLiveStreamSuffix"],
        sDefaultLiveStreamUrl: json["sDefaultLiveStreamUrl"],
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "vStreamInfo": vStreamInfo.toJson(),
        "mStreamRatio": mStreamRatio.toJson(),
        "vBitRateInfo": vBitRateInfo.toJson(),
        "iDefaultLiveStreamBitRate": iDefaultLiveStreamBitRate,
        "sDefaultLiveStreamLine": sDefaultLiveStreamLine,
        "sDefaultLiveStreamSuffix": sDefaultLiveStreamSuffix,
        "sDefaultLiveStreamUrl": sDefaultLiveStreamUrl,
        "_classname": classname,
      };
}

class HuyaMStreamRatio {
  HuyaMStreamRatio({
    required this.kproto,
    required this.vproto,
    required this.bKey,
    required this.bValue,
    required this.value,
    required this.classname,
  });

  HuyaProto kproto;
  HuyaProto vproto;
  int bKey;
  int bValue;
  MStreamRatioValue value;
  String classname;

  factory HuyaMStreamRatio.fromJson(Map<String, dynamic> json) =>
      HuyaMStreamRatio(
        kproto: HuyaProto.fromJson(json["_kproto"]),
        vproto: HuyaProto.fromJson(json["_vproto"]),
        bKey: json["_bKey"],
        bValue: json["_bValue"],
        value: MStreamRatioValue.fromJson(json["value"]),
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "_kproto": kproto.toJson(),
        "_vproto": vproto.toJson(),
        "_bKey": bKey,
        "_bValue": bValue,
        "value": value.toJson(),
        "_classname": classname,
      };
}

class MStreamRatioValue {
  MStreamRatioValue({
    required this.huya99,
    required this.tx,
    required this.huya,
    required this.al,
    required this.ws,
    required this.hw,
  });

  int huya99;
  int tx;
  int huya;
  int al;
  int ws;
  int hw;

  factory MStreamRatioValue.fromJson(Map<String, dynamic> json) =>
      MStreamRatioValue(
        huya99: json["HUYA99"],
        tx: json["TX"],
        huya: json["HUYA"],
        al: json["AL"],
        ws: json["WS"],
        hw: json["HW"],
      );

  Map<String, dynamic> toJson() => {
        "HUYA99": huya99,
        "TX": tx,
        "HUYA": huya,
        "AL": al,
        "WS": ws,
        "HW": hw,
      };
}

class HuyaVList {
  HuyaVList({
    required this.bValue,
    required this.value,
    required this.classname,
    required this.proto,
  });

  int bValue;
  List<HuyaVListValue> value;
  VListClassname classname;
  HuyaProto? proto;

  factory HuyaVList.fromJson(Map<String, dynamic> json) => HuyaVList(
        bValue: json["_bValue"],
        value: List<HuyaVListValue>.from(
            json["value"].map((x) => HuyaVListValue.fromJson(x))),
        classname: vListClassnameValues.map![json["_classname"]]!,
        proto:
            json["_proto"] == null ? null : HuyaProto.fromJson(json["_proto"]),
      );

  Map<String, dynamic> toJson() => {
        "_bValue": bValue,
        "value": List<dynamic>.from(value.map((x) => x.toJson())),
        "_classname": vListClassnameValues.reverse[classname],
        "_proto": proto == null ? null : proto?.toJson(),
      };
}

enum VListClassname {
  LIST_LT_LIVE_ROOM_LIVE_BIT_RATE_INFO_GT,
  LIST_LT_STRING_GT,
  LIST_LT_LIVE_LIST_LIVE_LIST_INFO_GT
}

final vListClassnameValues = EnumValues({
  "list&lt;LiveList.LiveListInfo&gt;":
      VListClassname.LIST_LT_LIVE_LIST_LIVE_LIST_INFO_GT,
  "list&lt;LiveRoom.LiveBitRateInfo&gt;":
      VListClassname.LIST_LT_LIVE_ROOM_LIVE_BIT_RATE_INFO_GT,
  "list&lt;string&gt;": VListClassname.LIST_LT_STRING_GT
});

class HuyaVListValue {
  HuyaVListValue({
    required this.sDisplayName,
    required this.iBitRate,
    required this.iCodecType,
    required this.iCompatibleFlag,
    required this.iHevcBitRate,
    required this.classname,
    required this.lUid,
    required this.lYyid,
    required this.sNick,
    required this.iSex,
    required this.iLevel,
    required this.sAvatar180,
    required this.lProfileRoom,
    required this.sPrivateHost,
    required this.sProfileHomeHost,
    required this.iIsPlatinum,
    required this.lActivityId,
    required this.lActivityCount,
    required this.iGid,
    required this.iGameId,
    required this.sGameFullName,
    required this.sGameHostName,
    required this.iBussType,
    required this.lLiveId,
    required this.lChannel,
    required this.lLiveChannel,
    required this.lUserCount,
    required this.lTotalCount,
    required this.sRoomName,
    required this.sIntroduction,
    required this.sPreviewUrl,
    required this.iLiveSourceType,
    required this.iScreenType,
    required this.sScreenshot,
    required this.iIsSecret,
    required this.iCameraOpen,
    required this.iIsBluRay,
    required this.sBluRayMBitRate,
    required this.lLiveCompatibleFlag,
    required this.iRecommendStatus,
    required this.sRecommendTagName,
    required this.iIsRoomPay,
    required this.sRoomPayTag,
    required this.iIsWatchTogetherVip,
    required this.iStartTime,
    required this.iTime,
    required this.iUpdateCacheTime,
    required this.mpCorner,
    required this.tImgRecInfo,
  });

  String sDisplayName;
  int iBitRate;
  int iCodecType;
  int iCompatibleFlag;
  int iHevcBitRate;
  ValueClassname classname;
  int lUid;
  int lYyid;
  String sNick;
  int iSex;
  int iLevel;
  String sAvatar180;
  int lProfileRoom;
  String sPrivateHost;
  String sProfileHomeHost;
  int iIsPlatinum;
  int lActivityId;
  int lActivityCount;
  int iGid;
  int iGameId;
  String sGameFullName;
  String sGameHostName;
  int iBussType;
  double lLiveId;
  int lChannel;
  int lLiveChannel;
  int lUserCount;
  int lTotalCount;
  String sRoomName;
  String sIntroduction;
  String sPreviewUrl;
  int iLiveSourceType;
  int iScreenType;
  String sScreenshot;
  int iIsSecret;
  int iCameraOpen;
  int iIsBluRay;
  SBluRayMBitRate? sBluRayMBitRate;
  int lLiveCompatibleFlag;
  int iRecommendStatus;
  String sRecommendTagName;
  int iIsRoomPay;
  String sRoomPayTag;
  int iIsWatchTogetherVip;
  int iStartTime;
  int iTime;
  int iUpdateCacheTime;
  HuyaMpCorner? mpCorner;
  HuyaTImgRecInfo? tImgRecInfo;

  factory HuyaVListValue.fromJson(Map<String, dynamic> json) => HuyaVListValue(
        sDisplayName:
            json["sDisplayName"] == null ? null : json["sDisplayName"],
        iBitRate: json["iBitRate"],
        iCodecType: json["iCodecType"] == null ? null : json["iCodecType"],
        iCompatibleFlag:
            json["iCompatibleFlag"] == null ? null : json["iCompatibleFlag"],
        iHevcBitRate:
            json["iHEVCBitRate"] == null ? null : json["iHEVCBitRate"],
        classname: valueClassnameValues.map![json["_classname"]]!,
        lUid: json["lUid"] == null ? null : json["lUid"],
        lYyid: json["lYyid"] == null ? null : json["lYyid"],
        sNick: json["sNick"] == null ? null : json["sNick"],
        iSex: json["iSex"] == null ? null : json["iSex"],
        iLevel: json["iLevel"] == null ? null : json["iLevel"],
        sAvatar180: json["sAvatar180"] == null ? null : json["sAvatar180"],
        lProfileRoom:
            json["lProfileRoom"] == null ? null : json["lProfileRoom"],
        sPrivateHost:
            json["sPrivateHost"] == null ? null : json["sPrivateHost"],
        sProfileHomeHost:
            json["sProfileHomeHost"] == null ? null : json["sProfileHomeHost"],
        iIsPlatinum: json["iIsPlatinum"] == null ? null : json["iIsPlatinum"],
        lActivityId: json["lActivityId"] == null ? null : json["lActivityId"],
        lActivityCount:
            json["lActivityCount"] == null ? null : json["lActivityCount"],
        iGid: json["iGid"] == null ? null : json["iGid"],
        iGameId: json["iGameId"] == null ? null : json["iGameId"],
        sGameFullName:
            json["sGameFullName"] == null ? null : json["sGameFullName"],
        sGameHostName:
            json["sGameHostName"] == null ? null : json["sGameHostName"],
        iBussType: json["iBussType"] == null ? null : json["iBussType"],
        lLiveId: json["lLiveId"] == null ? null : json["lLiveId"].toDouble(),
        lChannel: json["lChannel"] == null ? null : json["lChannel"],
        lLiveChannel:
            json["lLiveChannel"] == null ? null : json["lLiveChannel"],
        lUserCount: json["lUserCount"] == null ? null : json["lUserCount"],
        lTotalCount: json["lTotalCount"] == null ? null : json["lTotalCount"],
        sRoomName: json["sRoomName"] == null ? null : json["sRoomName"],
        sIntroduction:
            json["sIntroduction"] == null ? null : json["sIntroduction"],
        sPreviewUrl: json["sPreviewUrl"] == null ? null : json["sPreviewUrl"],
        iLiveSourceType:
            json["iLiveSourceType"] == null ? null : json["iLiveSourceType"],
        iScreenType: json["iScreenType"] == null ? null : json["iScreenType"],
        sScreenshot: json["sScreenshot"] == null ? null : json["sScreenshot"],
        iIsSecret: json["iIsSecret"] == null ? null : json["iIsSecret"],
        iCameraOpen: json["iCameraOpen"] == null ? null : json["iCameraOpen"],
        iIsBluRay: json["iIsBluRay"] == null ? null : json["iIsBluRay"],
        sBluRayMBitRate: json["sBluRayMBitRate"] == null
            ? null
            : sBluRayMBitRateValues.map![json["sBluRayMBitRate"]],
        lLiveCompatibleFlag: json["lLiveCompatibleFlag"] == null
            ? null
            : json["lLiveCompatibleFlag"],
        iRecommendStatus:
            json["iRecommendStatus"] == null ? null : json["iRecommendStatus"],
        sRecommendTagName: json["sRecommendTagName"] == null
            ? null
            : json["sRecommendTagName"],
        iIsRoomPay: json["iIsRoomPay"] == null ? null : json["iIsRoomPay"],
        sRoomPayTag: json["sRoomPayTag"] == null ? null : json["sRoomPayTag"],
        iIsWatchTogetherVip: json["iIsWatchTogetherVip"] == null
            ? null
            : json["iIsWatchTogetherVip"],
        iStartTime: json["iStartTime"] == null ? null : json["iStartTime"],
        iTime: json["iTime"] == null ? null : json["iTime"],
        iUpdateCacheTime:
            json["iUpdateCacheTime"] == null ? null : json["iUpdateCacheTime"],
        mpCorner: json["mpCorner"] == null
            ? null
            : HuyaMpCorner.fromJson(json["mpCorner"]),
        tImgRecInfo: json["tImgRecInfo"] == null
            ? null
            : HuyaTImgRecInfo.fromJson(json["tImgRecInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "sDisplayName": sDisplayName == null ? null : sDisplayName,
        "iBitRate": iBitRate,
        "iCodecType": iCodecType == null ? null : iCodecType,
        "iCompatibleFlag": iCompatibleFlag == null ? null : iCompatibleFlag,
        "iHEVCBitRate": iHevcBitRate == null ? null : iHevcBitRate,
        "_classname": valueClassnameValues.reverse[classname],
        "lUid": lUid == null ? null : lUid,
        "lYyid": lYyid == null ? null : lYyid,
        "sNick": sNick == null ? null : sNick,
        "iSex": iSex == null ? null : iSex,
        "iLevel": iLevel == null ? null : iLevel,
        "sAvatar180": sAvatar180 == null ? null : sAvatar180,
        "lProfileRoom": lProfileRoom == null ? null : lProfileRoom,
        "sPrivateHost": sPrivateHost == null ? null : sPrivateHost,
        "sProfileHomeHost": sProfileHomeHost == null ? null : sProfileHomeHost,
        "iIsPlatinum": iIsPlatinum == null ? null : iIsPlatinum,
        "lActivityId": lActivityId == null ? null : lActivityId,
        "lActivityCount": lActivityCount == null ? null : lActivityCount,
        "iGid": iGid == null ? null : iGid,
        "iGameId": iGameId == null ? null : iGameId,
        "sGameFullName": sGameFullName == null ? null : sGameFullName,
        "sGameHostName": sGameHostName == null ? null : sGameHostName,
        "iBussType": iBussType == null ? null : iBussType,
        "lLiveId": lLiveId == null ? null : lLiveId,
        "lChannel": lChannel == null ? null : lChannel,
        "lLiveChannel": lLiveChannel == null ? null : lLiveChannel,
        "lUserCount": lUserCount == null ? null : lUserCount,
        "lTotalCount": lTotalCount == null ? null : lTotalCount,
        "sRoomName": sRoomName == null ? null : sRoomName,
        "sIntroduction": sIntroduction == null ? null : sIntroduction,
        "sPreviewUrl": sPreviewUrl == null ? null : sPreviewUrl,
        "iLiveSourceType": iLiveSourceType == null ? null : iLiveSourceType,
        "iScreenType": iScreenType == null ? null : iScreenType,
        "sScreenshot": sScreenshot == null ? null : sScreenshot,
        "iIsSecret": iIsSecret == null ? null : iIsSecret,
        "iCameraOpen": iCameraOpen == null ? null : iCameraOpen,
        "iIsBluRay": iIsBluRay == null ? null : iIsBluRay,
        "sBluRayMBitRate": sBluRayMBitRate == null
            ? null
            : sBluRayMBitRateValues.reverse[sBluRayMBitRate],
        "lLiveCompatibleFlag":
            lLiveCompatibleFlag == null ? null : lLiveCompatibleFlag,
        "iRecommendStatus": iRecommendStatus == null ? null : iRecommendStatus,
        "sRecommendTagName":
            sRecommendTagName == null ? null : sRecommendTagName,
        "iIsRoomPay": iIsRoomPay == null ? null : iIsRoomPay,
        "sRoomPayTag": sRoomPayTag == null ? null : sRoomPayTag,
        "iIsWatchTogetherVip":
            iIsWatchTogetherVip == null ? null : iIsWatchTogetherVip,
        "iStartTime": iStartTime == null ? null : iStartTime,
        "iTime": iTime == null ? null : iTime,
        "iUpdateCacheTime": iUpdateCacheTime == null ? null : iUpdateCacheTime,
        "mpCorner": mpCorner == null ? null : mpCorner?.toJson(),
        "tImgRecInfo": tImgRecInfo == null ? null : tImgRecInfo?.toJson(),
      };
}

enum ValueClassname { LIVE_ROOM_LIVE_BIT_RATE_INFO, LIVE_LIST_LIVE_LIST_INFO }

final valueClassnameValues = EnumValues({
  "LiveList.LiveListInfo": ValueClassname.LIVE_LIST_LIVE_LIST_INFO,
  "LiveRoom.LiveBitRateInfo": ValueClassname.LIVE_ROOM_LIVE_BIT_RATE_INFO
});

class HuyaVStreamInfo {
  HuyaVStreamInfo({
    required this.bValue,
    required this.value,
    required this.classname,
  });

  int bValue;
  List<HuyaVStreamInfoValue> value;
  String classname;

  factory HuyaVStreamInfo.fromJson(Map<String, dynamic> json) =>
      HuyaVStreamInfo(
        bValue: json["_bValue"],
        value: List<HuyaVStreamInfoValue>.from(
            json["value"].map((x) => HuyaVStreamInfoValue.fromJson(x))),
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "_bValue": bValue,
        "value": List<dynamic>.from(value.map((x) => x.toJson())),
        "_classname": classname,
      };
}

class HuyaVStreamInfoValue {
  HuyaVStreamInfoValue({
    required this.sCdnType,
    required this.iIsMaster,
    required this.lChannelId,
    required this.lSubChannelId,
    required this.lPresenterUid,
    required this.sStreamName,
    required this.sFlvUrl,
    required this.sFlvUrlSuffix,
    required this.sFlvAntiCode,
    required this.sHlsUrl,
    required this.sHlsUrlSuffix,
    required this.sHlsAntiCode,
    required this.iLineIndex,
    required this.iIsMultiStream,
    required this.iPcPriorityRate,
    required this.iWebPriorityRate,
    required this.iMobilePriorityRate,
    required this.vFlvIpList,
    required this.iIsP2PSupport,
    required this.sP2PUrl,
    required this.sP2PUrlSuffix,
    required this.sP2PAntiCode,
    required this.lFreeFlag,
    required this.iIsHevcSupport,
    required this.vP2PIpList,
    required this.classname,
  });

  String sCdnType;
  int iIsMaster;
  int lChannelId;
  int lSubChannelId;
  int lPresenterUid;
  String sStreamName;
  String sFlvUrl;
  String sFlvUrlSuffix;
  String sFlvAntiCode;
  String sHlsUrl;
  String sHlsUrlSuffix;
  String sHlsAntiCode;
  int iLineIndex;
  int iIsMultiStream;
  int iPcPriorityRate;
  int iWebPriorityRate;
  int iMobilePriorityRate;
  HuyaVList vFlvIpList;
  int iIsP2PSupport;
  String sP2PUrl;
  String sP2PUrlSuffix;
  String sP2PAntiCode;
  int lFreeFlag;
  int iIsHevcSupport;
  HuyaVList vP2PIpList;
  String classname;

  factory HuyaVStreamInfoValue.fromJson(Map<String, dynamic> json) =>
      HuyaVStreamInfoValue(
        sCdnType: json["sCdnType"],
        iIsMaster: json["iIsMaster"],
        lChannelId: json["lChannelId"],
        lSubChannelId: json["lSubChannelId"],
        lPresenterUid: json["lPresenterUid"],
        sStreamName: json["sStreamName"],
        sFlvUrl: json["sFlvUrl"],
        sFlvUrlSuffix: json["sFlvUrlSuffix"],
        sFlvAntiCode: json["sFlvAntiCode"],
        sHlsUrl: json["sHlsUrl"],
        sHlsUrlSuffix: json["sHlsUrlSuffix"],
        sHlsAntiCode: json["sHlsAntiCode"],
        iLineIndex: json["iLineIndex"],
        iIsMultiStream: json["iIsMultiStream"],
        iPcPriorityRate: json["iPCPriorityRate"],
        iWebPriorityRate: json["iWebPriorityRate"],
        iMobilePriorityRate: json["iMobilePriorityRate"],
        vFlvIpList: HuyaVList.fromJson(json["vFlvIPList"]),
        iIsP2PSupport: json["iIsP2PSupport"],
        sP2PUrl: json["sP2pUrl"],
        sP2PUrlSuffix: json["sP2pUrlSuffix"],
        sP2PAntiCode: json["sP2pAntiCode"],
        lFreeFlag: json["lFreeFlag"],
        iIsHevcSupport: json["iIsHEVCSupport"],
        vP2PIpList: HuyaVList.fromJson(json["vP2pIPList"]),
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "sCdnType": sCdnType,
        "iIsMaster": iIsMaster,
        "lChannelId": lChannelId,
        "lSubChannelId": lSubChannelId,
        "lPresenterUid": lPresenterUid,
        "sStreamName": sStreamName,
        "sFlvUrl": sFlvUrl,
        "sFlvUrlSuffix": sFlvUrlSuffix,
        "sFlvAntiCode": sFlvAntiCode,
        "sHlsUrl": sHlsUrl,
        "sHlsUrlSuffix": sHlsUrlSuffix,
        "sHlsAntiCode": sHlsAntiCode,
        "iLineIndex": iLineIndex,
        "iIsMultiStream": iIsMultiStream,
        "iPCPriorityRate": iPcPriorityRate,
        "iWebPriorityRate": iWebPriorityRate,
        "iMobilePriorityRate": iMobilePriorityRate,
        "vFlvIPList": vFlvIpList.toJson(),
        "iIsP2PSupport": iIsP2PSupport,
        "sP2pUrl": sP2PUrl,
        "sP2pUrlSuffix": sP2PUrlSuffix,
        "sP2pAntiCode": sP2PAntiCode,
        "lFreeFlag": lFreeFlag,
        "iIsHEVCSupport": iIsHevcSupport,
        "vP2pIPList": vP2PIpList.toJson(),
        "_classname": classname,
      };
}

class HuyaTReplayVideoInfo {
  HuyaTReplayVideoInfo({
    required this.sUrl,
    required this.sHlsUrl,
    required this.iVideoSyncTime,
    required this.classname,
  });

  String sUrl;
  String sHlsUrl;
  int iVideoSyncTime;
  String classname;

  factory HuyaTReplayVideoInfo.fromJson(Map<String, dynamic> json) =>
      HuyaTReplayVideoInfo(
        sUrl: json["sUrl"],
        sHlsUrl: json["sHlsUrl"],
        iVideoSyncTime: json["iVideoSyncTime"],
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "sUrl": sUrl,
        "sHlsUrl": sHlsUrl,
        "iVideoSyncTime": iVideoSyncTime,
        "_classname": classname,
      };
}

class HuyaTRoomPayInfo {
  HuyaTRoomPayInfo({
    required this.lUid,
    required this.iIsRoomPay,
    required this.iIsShowTag,
    required this.sRoomPayTag,
    required this.sRoomPayPassword,
    required this.classname,
  });

  int lUid;
  int iIsRoomPay;
  int iIsShowTag;
  String sRoomPayTag;
  String sRoomPayPassword;
  String classname;

  factory HuyaTRoomPayInfo.fromJson(Map<String, dynamic> json) =>
      HuyaTRoomPayInfo(
        lUid: json["lUid"],
        iIsRoomPay: json["iIsRoomPay"],
        iIsShowTag: json["iIsShowTag"],
        sRoomPayTag: json["sRoomPayTag"],
        sRoomPayPassword: json["sRoomPayPassword"],
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "lUid": lUid,
        "iIsRoomPay": iIsRoomPay,
        "iIsShowTag": iIsShowTag,
        "sRoomPayTag": sRoomPayTag,
        "sRoomPayPassword": sRoomPayPassword,
        "_classname": classname,
      };
}

class HuyaTProfileInfo {
  HuyaTProfileInfo({
    required this.lUid,
    required this.lYyid,
    required this.sNick,
    required this.iSex,
    required this.iLevel,
    required this.sAvatar180,
    required this.lProfileRoom,
    required this.sPrivateHost,
    required this.lActivityId,
    required this.lActivityCount,
    required this.classname,
  });

  int lUid;
  int lYyid;
  String sNick;
  int iSex;
  int iLevel;
  String sAvatar180;
  int lProfileRoom;
  String sPrivateHost;
  int lActivityId;
  int lActivityCount;
  String classname;

  factory HuyaTProfileInfo.fromJson(Map<String, dynamic> json) =>
      HuyaTProfileInfo(
        lUid: json["lUid"],
        lYyid: json["lYyid"],
        sNick: json["sNick"],
        iSex: json["iSex"],
        iLevel: json["iLevel"],
        sAvatar180: json["sAvatar180"],
        lProfileRoom: json["lProfileRoom"],
        sPrivateHost: json["sPrivateHost"],
        lActivityId: json["lActivityId"],
        lActivityCount: json["lActivityCount"],
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "lUid": lUid,
        "lYyid": lYyid,
        "sNick": sNick,
        "iSex": iSex,
        "iLevel": iLevel,
        "sAvatar180": sAvatar180,
        "lProfileRoom": lProfileRoom,
        "sPrivateHost": sPrivateHost,
        "lActivityId": lActivityId,
        "lActivityCount": lActivityCount,
        "_classname": classname,
      };
}

class HuyaRoomProfile {
  HuyaRoomProfile({
    required this.tCacheInfo,
    required this.lUid,
    required this.iIsProfile,
    required this.iIsFreeze,
    required this.iIsMatchRoom,
    required this.iFreezeLevel,
    required this.classname,
    required this.liveLineUrl,
    required this.isFace,
  });

  HuyaTCacheInfo tCacheInfo;
  int lUid;
  int iIsProfile;
  int iIsFreeze;
  int iIsMatchRoom;
  int iFreezeLevel;
  String classname;
  String liveLineUrl;
  bool isFace;

  factory HuyaRoomProfile.fromJson(Map<String, dynamic> json) =>
      HuyaRoomProfile(
        tCacheInfo: HuyaTCacheInfo.fromJson(json["tCacheInfo"]),
        lUid: json["lUid"],
        iIsProfile: json["iIsProfile"],
        iIsFreeze: json["iIsFreeze"],
        iIsMatchRoom: json["iIsMatchRoom"],
        iFreezeLevel: json["iFreezeLevel"],
        classname: json["_classname"],
        liveLineUrl: json["liveLineUrl"],
        isFace: json["isFace"],
      );

  Map<String, dynamic> toJson() => {
        "tCacheInfo": tCacheInfo.toJson(),
        "lUid": lUid,
        "iIsProfile": iIsProfile,
        "iIsFreeze": iIsFreeze,
        "iIsMatchRoom": iIsMatchRoom,
        "iFreezeLevel": iFreezeLevel,
        "_classname": classname,
        "liveLineUrl": liveLineUrl,
        "isFace": isFace,
      };
}

class HuyaRoomRecommendLiveList {
  HuyaRoomRecommendLiveList({
    required this.iIdx,
    required this.sTagMark,
    required this.sTagName,
    required this.vList,
    required this.classname,
  });

  int iIdx;
  String sTagMark;
  String sTagName;
  HuyaVList vList;
  String classname;

  factory HuyaRoomRecommendLiveList.fromJson(Map<String, dynamic> json) =>
      HuyaRoomRecommendLiveList(
        iIdx: json["iIdx"],
        sTagMark: json["sTagMark"],
        sTagName: json["sTagName"],
        vList: HuyaVList.fromJson(json["vList"]),
        classname: json["_classname"],
      );

  Map<String, dynamic> toJson() => {
        "iIdx": iIdx,
        "sTagMark": sTagMark,
        "sTagName": sTagName,
        "vList": vList.toJson(),
        "_classname": classname,
      };
}

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map?.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap ?? {};
  }
}
