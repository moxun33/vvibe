//epg管理

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/utils/gzip.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/utils.dart';
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
  maxStale: const Duration(hours: 1),
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

// epg 主机
  Future<String> getEpgUrl([String? epgUrl]) async {
    if (epgUrl != null && epgUrl.isNotEmpty) {
      return epgUrl;
    }
    String url = DEF_EPG_URL;
    final settings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    if (settings != null) {
      url = settings['epg'] ?? DEF_EPG_URL;
    }
    return url;
  }

  List<String> extractXmlUrls(String text) {
    RegExp regex = RegExp(r'https?://[^\s/$.?#].[^\s]*\.xml');
    Iterable<RegExpMatch> matches = regex.allMatches(text);
    List<String> urls = [];

    for (RegExpMatch match in matches) {
      if (match.group(0) != null) urls.add(match.group(0)!);
    }

    return urls;
  }

  // epg xml地址
  Future<String?> getEpgXmlUrl([String? epgUrl]) async {
    try {
      String url = await getEpgUrl(epgUrl);
      if (url.endsWith('.xml.gz') || url.endsWith('.xml')) {
        return url;
      }

      if (url.contains('epg.aptvapp.com'))
        return Uri.parse(url).origin + '/xml';
      var resp = await client.get(url);
      if (resp.statusCode != 200 && resp.statusCode != 201) return null;
      final type = resp.headers['Content-Type'] ?? [];
      if (type.first.contains('text/html')) {
        final urls = extractXmlUrls(resp.data);
        if (urls.isEmpty) return null;
        final xmlUrl = urls[0].replaceAll('</br>', '\n').split('\n')[0];
        final uri = Uri.tryParse(xmlUrl);
        String _xmlUri = xmlUrl;
        if (uri != null) '${uri.origin}${uri.path}';
        return _xmlUri.endsWith('.gz') ? _xmlUri : _xmlUri + '.gz';
      }
      return url + '/e.xml.gz';
    } catch (e) {
      MyLogger.error('getEpgXmlUrl errors：' + e.toString());
      return null;
    }
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
      subDate(now, 6),
      subDate(now, 5),
      subDate(now, 4),
      subDate(now, 3),
      subDate(now, 2),
      subDate(now, 1),
      getDate(now)
    ];
  }

//根据[tvg-id、tvg-name、name和dates 远程获取节目单json数据
  Future<ChannelEpg?> getChannelApiEpg(String channel, [String? date]) async {
    final d = date ?? getToday();
    final params = {
      'ch': channel,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.parse(d))
    };
    try {
      var resp = await client.get('https://epg.112114.eu.org',
          queryParameters: params,
          options: Options(responseType: ResponseType.json));
      MyLogger.info(
        'now get ${channel} ${date}  epg ',
      );
      if (resp.data == null) {
        resp = await client.get('https://epg.v1.mk/json',
            queryParameters: params,
            options: Options(responseType: ResponseType.json));
      }
      if (resp.data != null && resp.data is Map) {
        final Map<String, dynamic> map = {
          'date': resp.data['date'] ?? d,
          'epg': List<dynamic>.from(resp.data['epg_data'] ?? [])
              .map((e) => Map<String, dynamic>.from({
                    ...e,
                    'start': d + e['start'].toString().replaceAll(':', ''),
                    'end': d + e['end'].toString().replaceAll(':', ''),
                  }))
              .toList()
        };
        if (int.tryParse(channel) is int) {
          map['id'] = channel;
        } else {
          map['name'] = resp.data['channel_name'] ?? channel;
        }
        return ChannelEpg.fromJson(map);
      } else {
        return null;
      }
    } catch (e) {
      MyLogger.error('load epg errors $params ${e.toString()}');
      return null;
    }
  }

//根据[tvg-id、tvg-name、name]获取频道节目单
  Future<List<ChannelEpg>?> getChannelEpg(channel) async {
    const res = null;
    if (res != null) {
      return res;
    } else {
      MyLogger.error('get $channel epg errors ');
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
      map['epg'] = epg;
      if ((epg == null || epg.isEmpty)) {
        return getChannelApiEpg(channel, d);
      }
      return ChannelEpg.fromJson(map);
    } catch (e) {
      MyLogger.info('get $channel $d errors $e');
      return null;
    }
  }

  downloadEpgDataAync({String? epgUrl}) {
    try {
      downloadEpgData(epgUrl: epgUrl);
    } catch (e) {
      MyLogger.error('downloadEpgDataAync errors $e $epgUrl');
    }
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

// 格式化epg的时间 String dateString = '2023 1029 19 00 00 +0800';
  DateTime parseEpgTime(String date) {
    try {
      date = date.padRight(14, '0');
      DateTime dateTime =
          DateTime.parse(date.substring(0, 8) + 'T' + date.substring(8, 14));
      final tz = DateTime.now().timeZoneOffset;
      String tzOffset = date.length > 14
          ? date.substring(15)
          : '+${tz.inHours.toString().padLeft(2, '0')}${tz.inMinutes.toString().padLeft(2, '0')}';

      /*  dateTime = dateTime
          .add(Duration(hours: int.parse(tzOffset.substring(0, 3))));
      dateTime = dateTime
          .add(Duration(minutes: int.parse(tzOffset.substring(3))));
 */
      return dateTime;
    } catch (e) {
      MyLogger.error('parseEpgTimeerrors$e $date');
      return DateTime.now();
    }
  }

// 从download的epg文件提取频道、日期的epg数据
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
              e['id'] == (channel) ||
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
              ((e['start'].startsWith(date) && e['stop'].startsWith(date))))
          .toList();
      return List<Map<String, dynamic>>.from(epg);
    } catch (e) {
      MyLogger.error('pickChannelEpgJson errors： $e');
      return null;
    }
  }

  Future<String?> readEpgJson() async {
    try {
      final p = await getJsonFilePath();
      final file = File(p);
      return file.readAsString();
    } catch (e) {
      MyLogger.error('read epg jsonerrors $e');
      return null;
    }
  }

  Future<dynamic> unzipEpg() async {
    final gzPath = await getZipPath();
    final res = await unzipGzip(gzPath, await getXmlFilePath());
    if (res == false) {
      downloadEpgData(text: true);
      MyLogger.info('re download epg texts');
    }
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
      MyLogger.info('parseepg $xmlPath success，generating json $jsonPath');
    } catch (e) {
      MyLogger.error('parseepg $xmlPath failed $e');
    }
  }

// downloadepg数据
  Future downloadEpgData({text = false, String? epgUrl}) async {
    final url = await getEpgXmlUrl(epgUrl);
    if (url == null || !url.contains('xml')) return;
    final savePath = text ? await getXmlFilePath() : await getZipPath();
    final dlRes = await downloadFile(
      url,
      savePath,
    );

    if (dlRes != null) {
      MyLogger.info("download epg success " + url + ' ' + dlRes.path);
      if (!text) {
        final unziped = await unzipEpg();

        parseXml();
      } else {
        parseXml();
      }
    } else {
      MyLogger.error("download epg failed" + url);
    }
  }

  Future<File?> downloadFile(String downloadUrl, String savePath) async {
    DateTime timeStart = DateTime.now();
    MyLogger.info('start downloading epg～now time：$timeStart');
    try {
      Dio dio = Dio();
      var resp = await dio.download(downloadUrl, savePath,
          onReceiveProgress: (received, total) {
        /*  if (total != -1) {
          final currentProgress = received / total;
          MyLogger.info(
              '当前downloadepg的进度：${(currentProgress * 100).toStringAsFixed(0)}%');
        } */
      });
      if (resp.statusCode != 200) {
        MyLogger.error(downloadUrl +
            'downloadepg failed ' +
            resp.statusMessage.toString());
        return null;
      }
      MyLogger.info('$downloadUrl epg file downloaded $savePath');
      return File(savePath); // Added flush: true
    } catch (e) {
      MyLogger.error("downloadFile errors：$e");
      return null;
    }
  }
}
