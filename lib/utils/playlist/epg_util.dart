//epg管理

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/utils/gzip.dart';
import 'package:vvibe/utils/utils.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:xml2json/xml2json.dart';

// Global options
final _epgCacheoptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional.

  // Default.
  policy: CachePolicy.request,
  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  hitCacheOnErrorExcept: [401, 403],
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to [null].
  maxStale: const Duration(days: 1),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended when [true].
  allowPostMethod: false,
);

class EpgUtil {
  static EpgUtil _instance = new EpgUtil._();
  factory EpgUtil() => _instance;

  EpgUtil._();

  final client = Dio(BaseOptions(headers: {'User-Agnet': DEF_REQ_UA}))
    ..interceptors.add(DioCacheInterceptor(options: _epgCacheoptions));

  //data目录（在应用根目录下）
  Future<Directory> createDir(
      {String dirName = IS_RELEASE ? 'data/epg' : 'assets/epg'}) async {
    final dir = Directory(dirName);
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  Future<String> getEpgUrl() async {
    String url = DEF_EPG_URL;
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    if (settings != null) {
      url = settings['egp'] ?? DEF_EPG_URL;
    }
    return url;
  }

  String getToday() {
    DateTime now = DateTime.now();
    return getDate(
      now,
    );
  }

  String getDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year.toString().padLeft(4, '0')}$m$d';
  }

  String subDate(DateTime dt, days) {
    return getDate(dt.subtract(Duration(days: days ?? 1)));
  }

//生成7天日期
  List<String> genWeekDays() {
    DateTime now = DateTime.now();
    return [
      subDate(now, 7),
      subDate(now, 6),
      subDate(now, 5),
      subDate(now, 4),
      subDate(now, 3),
      subDate(now, 2),
      subDate(now, 1),
      getDate(now)
    ];
  }

//根据[tvg-id、tvg-name、name和dates 远程获取节目单
  Future<ChannelEpg?> getChannelBiypEpg(channel, [String? date]) async {
    final params = {'ch': channel, 'date': date ?? getToday()};
    final resp = await client.get(await getEpgUrl(), queryParameters: params);
    if (resp.statusCode == 200) {
      if (resp.data is Map)
        return ChannelEpg.fromJson(resp.data);
      else
        return null;
    } else {
      print('加载节目单失败 $params');
      return null;
    }
  }

//根据[tvg-id、tvg-name、name]获取每天的节目单
  Future<List<ChannelEpg>?> getChannelEpg(channel) async {
    const res = null;
    if (res != null) {
      return res;
    } else {
      print('获取 $channel 的节目单失败 ');
      return null;
    }
  }

//根据tvg-id、tvg-name、name和date获取节目单
  Future<ChannelEpg?> getChannelDateEpg(channel, [String? date]) async {
    final d = date ?? getToday();

    try {
      if (channel.isEmpty) return null;
      final Map<String, dynamic> map = {'date': d};
      if (int.tryParse(channel) is int) {
        map['id'] = channel;
      } else {
        map['name'] = channel;
      }
      final epg = await pickChannelEpgJson(channel, d);
      map['epg'] = epg ?? [];
      return ChannelEpg.fromJson(map);
    } catch (e) {
      print('获取 $channel $d 的节目单失败 $e');
      return null;
    }
  }

  downloadEpgDataIsolate() {
    try {
      downloadEpgData();
    } catch (e) {}
  }

  Future<String> getZipPath() async {
    return '${(await createDir()).path}/e.xml.gz';
  }

  Future<String> getXmlFilePath() async {
    return (await getZipPath()).replaceAll('e.xml.gz', 'e.xml');
  }

  Future<String> getJsonFilePath() async {
    return (await getZipPath()).replaceAll('e.xml.gz', 'e.json');
  }

// 格式化epg的时间 String dateString = '20231029190000 +0800';
  DateTime parseEpgTime(String date) {
    try {
      DateTime dateTime =
          DateTime.parse(date.substring(0, 8) + 'T' + date.substring(8, 14));
      String timeZoneOffset = date.substring(15);

      /*  dateTime = dateTime
          .add(Duration(hours: int.parse(timeZoneOffset.substring(0, 3))));
      dateTime = dateTime
          .add(Duration(minutes: int.parse(timeZoneOffset.substring(3))));
 */
      return dateTime;
    } catch (e) {
      print('$e');
      return DateTime.now();
    }
  }

// 从下载的epg文件提取频道、日期的epg数据
  Future<List<Map<String, dynamic>>?> pickChannelEpgJson(
      String channel, String date) async {
    try {
      if (channel.isEmpty) return null;

      final epgStr = await readEpgJson();
      if (epgStr == null) return null;
      final json = jsonDecode(epgStr);
      final Map<String, dynamic> tv = json['tv'] ?? {};
      final List<dynamic> channels = tv['channel'] ?? [];

      final List<dynamic> programmes = (tv['programme'] ?? []);
      var myChannels = channels
          .where((e) =>
              e['display-name'] == channel ||
              channel.contains(e['display-name']) ||
              e['id'] == int.tryParse(channel))
          .toList();
      if (myChannels.isEmpty) {
        return null;
      }
      final myChannel = myChannels[0];
      final tvgId = myChannel['id'];
      final List epg = programmes
          .where((e) =>
              e['channel'].toString() == tvgId.toString() &&
              e['start'].startsWith(date) &&
              e['stop'].startsWith(date))
          .toList();
      return List<Map<String, dynamic>>.from(epg);
    } catch (e) {
      print('pickChannelEpgJson 出错： $e');
      return null;
    }
  }

  Future<String?> readEpgJson() async {
    try {
      final p = await getJsonFilePath();
      final file = File(p);
      return file.readAsString();
    } catch (e) {
      print('读取epg json出错 $e');
      return null;
    }
  }

  Future<dynamic> unzipEpg() async {
    final gzPath = await getZipPath();
    return unzip(gzPath, await getXmlFilePath());
  }

  void parseXml() async {
    final xmlPath = await getXmlFilePath();
    try {
      final jsonPath = await getJsonFilePath();
      File file = File(xmlPath);
      final xml = await file.readAsString();
      final transformer = Xml2Json();
      transformer.parse(xml);
      var json = transformer.toOpenRally();
      File jsonFile = File(jsonPath);
      await jsonFile.writeAsString(json);
      print('解析epg $xmlPath 完成，生成json $jsonPath');
    } catch (e) {
      print('解析epg $xmlPath 失败 $e');
    }
  }

  Future downloadEpgData() async {
    String url = await getEpgUrl();

    final savePath = await getZipPath();
    final dlRes = await downloadFile(url, savePath);

    if (dlRes != null) {
      print("下载epg成功 " + url + ' ' + dlRes.path);
      final unziped = await unzipEpg();
      if (unziped) {
        parseXml();
      }
    } else {
      print("下载epg失败" + url);
    }
  }

  Future<File?> downloadFile(String downLoadUrl, String savePath) async {
    DateTime timeStart = DateTime.now();
    print('开始下载～当前时间：$timeStart');
    try {
      Dio dio = Dio();
      var resp = await dio.get(downLoadUrl,
          options: Options(responseType: ResponseType.bytes));
      var file = File(savePath);
      if (resp.statusCode != 200) {
        print(downLoadUrl + '下载epg失败 ' + resp.statusMessage.toString());
        return null;
      }
      print('$downLoadUrl epg文件下载成功 $savePath');
      return file.writeAsBytes(resp.data, flush: true); // Added flush: true
    } catch (e) {
      print("downloadFile报错：$e");
      return null;
    }
  }
}
