/*
 * @Author: Moxx
 * @Date: 2022-09-13 16:22:39
 * @LastEditors: moxun33
 * @LastEditTime: 2024-06-30 16:55:11
 * @FilePath: \vvibe\lib\utils\playlist\playlist_util.dart
 * @Description:
 * @qmj
 */
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/playlist_info.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/models/playlist_text_group.dart';
import 'package:vvibe/services/danmaku/danmaku_type.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/utils/playlist/playlist_check_req.dart';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //创建目录（在应用根目录下）
  Future<Directory> createDir(String dirName) async {
    final dir = Directory(dirName);
    if (!(await dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  //本地播放列表目录
  Future<Directory> getPlayListDir() async {
    return createDir('playlist');
  }

//本地视频截图
  Future<Directory> getSnapshotDir() async {
    return createDir('snapshots');
  }

  //在其他应用打开文件
  Future<void> launchFile(String file) async {
    String path = (await getPlayListDir()).path;
    if (file.isEmpty) {
      path = path.replaceAll("/", "\\"); // necessary for Windows
      await Process.start('explorer', [path]);
    } else {
      ProcessResult result =
          await Process.run('cmd', ['/c', 'start', '', '$path/$file']);
      if (result.exitCode == 0) {
        // good
      } else {
        // bad
      }
    }
  }

  //获取本地播放列表文件列表
  Future<List<Map<String, dynamic>>> getPlayListFiles(
      {bool basename = false}) async {
    try {
      final Directory dir = await getPlayListDir();
      final dirList = await dir.list().toList();
      final List<String> list = [];
      for (var v in dirList) {
        if (v.path.endsWith(".txt") || v.path.endsWith(".m3u")) {
          final path = v.path.replaceAll('\\', '/');
          list.add(basename ? path.split('/').last : path);
        }
      }
      return list
          .map(
            (e) => {'id': e, 'name': e, 'type': 'file'},
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  //解析【本地】文件的播放列表内容
  Future<PlayListInfo?> parsePlaylistFile(
    String filename,
  ) async {
    try {
      final filePath =
          "${(await PlaylistUtil().getPlayListDir()).path}/${filename}";
      final lines = await compute(readFileLines, filePath);
      PlayListInfo? data = await compute(parseM3uContents, lines);
      if (data != null && data.channels.isNotEmpty) {
        return data;
      }
      return compute(parseTxtContents, lines);
    } catch (e) {
      print(e);
    }
    return null;
  }

// 获取订阅配置列表
  Future<Map<String, List<dynamic>>> getSubConfigs() async {
    final files = await PlaylistUtil().getPlayListFiles(basename: true);
    final urls = await PlaylistUtil().getSubUrls();
    return {
      'files': files,
      'urls': urls,
    };
  }

//获取订阅地址列表
  Future<List<Map<String, dynamic>>> getSubUrls() async {
    final list = await LoacalStorage().getJSON(PLAYLIST_SUB_URLS);
    return list != null ? List<Map<String, dynamic>>.from(list) : [];
  }

  // 是否为url
  bool isUrl(String? url) {
    try {
      if (url == null || url.isEmpty) return false;
      final uri = Uri.tryParse(url);
      return uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool isBoolValid(dynamic v, [bool revert = true]) {
    if (revert) {
      return v.toString() != 'false' && v.toString() != 'no';
    }
    if (v == null) return false;
    return v.toString() == 'true' || v.toString() == 'yes';
  }

  bool isStrValid(dynamic v) {
    if (v == null) return false;
    return v.toString().isNotEmpty;
  }

// 解析本地或远程订阅,自动下钻单个直播源集合； 触发：一个直播源且名称为index
  Future<PlayListInfo?> parsePlayListsDrill(String src,
      {int drillMax = 1, Map<String, dynamic>? config}) async {
    int drilled = 0;
    PlayListInfo? info =
        await PlaylistUtil().parsePlayLists(src, config: config);
    Map<String, dynamic>? topMeta = {};
    bool showLogo = true, checkAlive = false;

    showLogo = info?.showLogo == true;
    checkAlive = info?.checkAlive == true;

    while (info != null &&
        info.channels.length == 1 &&
        info.channels.first.url.isNotEmpty &&
        drilled < drillMax) {
      info = await PlaylistUtil()
          .parsePlayLists(info.channels.first.url, config: config);
      drilled++;
    }
    if (info != null && drilled > 0) {
      info.showLogo = showLogo;
      info.checkAlive = checkAlive;
    }

    return info;
  }

// 解析本地或远程订阅
  Future<PlayListInfo?> parsePlayLists(String src,
      {Map<String, dynamic>? config}) async {
    PlayListInfo? data =
        await PlaylistUtil().parsePlaylistSubUrl(src, config: config);
    if (data != null && data.channels.isNotEmpty) {
      return data;
    }
    return PlaylistUtil().parsePlaylistFile(
      src,
    );
  }

  final dioCacheOptions = CacheOptions(
    // A default store is required for interceptor.
    store: MemCacheStore(),
    maxStale: const Duration(seconds: 30),
  );
  //判断是否为斗鱼、虎牙、b站的代理url
  Map<String, dynamic> isDyHyDlProxyUrl(String url) {
    try {
      final uri = Uri.parse(url.trim()),
          matchDy = uri.path.contains(DanmakuType.douyuProxyUrlReg),
          matchHy = uri.path.contains(DanmakuType.huyaProxyUrlReg),
          matchBl = uri.path.contains(DanmakuType.biliProxyUrlReg);

      return {
        'playUrl': '',
        'platformHit': matchDy || matchHy || matchBl,
        'douyu': matchDy,
        'huya': matchHy,
        'bilibili': matchBl
      };
    } catch (e) {
      return {};
    }
  }

  //解析代理url的最终url
  Future<String> parseProxyTargetUrl(String url) async {
    var _url = url;
    try {
      final client = Dio(BaseOptions(followRedirects: false));
      await client.get(url);
    } on DioException catch (e) {
      if ('${e.response?.statusCode}'.startsWith('30')) {
        final urls = e.response?.headers['location'];
        if (urls!.isNotEmpty) {
          _url = urls.first;
        }
      }
    }
    return _url;
  }

//根据url解析分组、tvgId等信息
  Map<String, dynamic> parseUrlExtInfos(String url) {
    final allUrls = url.split('#');

    final map = {
      'group': '未分组',
      'tvgId': '',
      'ext': Map<String, dynamic>.from(
          {'bakUrls': allUrls.length > 1 ? allUrls.sublist(1) : []})
    };
    final uri = Uri.parse(url.trim()),
        matches = isDyHyDlProxyUrl(url),
        matchDy = matches['douyu'] == true,
        matchHy = matches['huya'] == true,
        matchBl = matches['bilibili'] == true;
    try {
      matches['memo'] = url.split('\$').last;
    } catch (e) {
      matches['memo'] = '';
    }
    if (matchDy) map['group'] = DanmakuType.douyuCN;
    if (matchHy) map['group'] = DanmakuType.huyaCN;
    if (matchBl) map['group'] = DanmakuType.bilibiliCN;

    if (matches['platformHit'] == true) {
      final queryId = uri.queryParameters['id'], pathSegs = uri.pathSegments;
      if (queryId != null && queryId.isNotEmpty) {
        map['tvgId'] = queryId;
      } else if (pathSegs.isNotEmpty && pathSegs.last.isNotEmpty) {
        map['tvgId'] = pathSegs.last;
      }
      map['ext'] = matches;
    }

    return map;
  }

  //根据单个打开的url解析
  PlayListItem parseSingleUrl(String url) {
    final _info = parseUrlExtInfos(url.trim()),
        ext = _info['ext'] ?? Map<String, dynamic>.from({});
    final PlayListItem item = PlayListItem.fromJson({
      'url': url,
      'name': APP_NAME,
      'group': _info['group'],
      'tvgId': _info['tvgId'],
      'ext': ext
    });
    return item;
  }

  //根据单个打开的url解析 异步
  Future<PlayListItem> parseSingleUrlAsync(String url, {String? name}) async {
    final _info = await compute(parseUrlExtInfos, url),
        ext = _info['ext'] ?? {};
    /* if (ext['platformHit'] == true) {
      ext['playUrl'] = await parseProxyTargetUrl(url);
    } */
    ext['playUrl'] = url;
    final PlayListItem item = PlayListItem.fromJson({
      'url': url,
      'name': name ?? APP_NAME,
      'group': _info['group'],
      'tvgId': _info['tvgId'],
      'ext': ext ?? {}
    });
    return item;
  }

//根据url解析远程txt或m3u内容
  Future<PlayListInfo?> parsePlaylistSubUrl(String url,
      {Map<String, dynamic>? config, bool? forceRefresh = false}) async {
    if (!PlaylistUtil().isUrl(url)) return null;
    final headers = {
      'User-Agent':
          config != null && isStrValid(config['ua']) ? config['ua'] : DEF_REQ_UA
    };

    final client = Dio(BaseOptions(
        headers: headers, receiveTimeout: const Duration(seconds: 30)));
    if (forceRefresh != true) {
      final dioCacheOptions = CacheOptions(
        policy: CachePolicy.forceCache,
        store: MemCacheStore(),
        maxStale: const Duration(minutes: 1),
      );
      client.interceptors.add(DioCacheInterceptor(options: dioCacheOptions));
    }
    final resp = await client.get(url);
    if (resp.statusCode == 200 || resp.statusCode! < 400) {
      final String _data = resp.data;
      final List<String> lines = _data.split('\n');
      if (lines.length > 0 && lines[0].startsWith('#EXTM3U')) {
        return compute(parseM3uContents, lines);
      } else {
        return compute(parseTxtContents, lines);
      }
    } else {
      await EasyLoading.showError('加载订阅失败 ${resp.statusCode} ');
    }
    return null;
  }

//读取文件文本行内容
  Future<List<String>> readFileLines(String filePath) async {
    try {
      return File(filePath).readAsLines();
    } catch (e) {
      return [];
    }
  }

//解析text的分组 [{'group':'name','index':0}]
  List<PlayListTextGroup> parseTxtGroups(List<String> lines) {
    List<PlayListTextGroup> groups = [];
    for (var line in lines) {
      if (line.contains(',') && (line.contains('#genre#'))) {
        groups.add(PlayListTextGroup.fromJson(
            {'group': line.split(',').first, 'index': lines.indexOf(line)}));
      }
    }
    return groups;
  }

//根据txt的分组列表和子项在txt的索引匹配分组
  String matchTxtUrlGroup(List<PlayListTextGroup> groups, int urlIndex) {
    final matches = groups.where((element) => element.index < urlIndex);
    if (matches.length > 0) {
      final PlayListTextGroup group = matches.last;
      return group.group;
    }
    return '未分组';
  }

  //根据文本行 解析txt的播放列表文件内容
  PlayListInfo? parseTxtContents(List<String> lines,
      {bool includeMeta = false}) {
    try {
      final groups = parseTxtGroups(lines);
      final list = lines
          .where((element) =>
              element.isNotEmpty &&
              element.contains(',') &&
              !element.contains('#genre#') &&
              element.split(',').length >= 2)
          .map((String e) {
        final List<String> arr = e.split(',');

        final item = PlayListItem(
            group: matchTxtUrlGroup(groups, lines.indexOf(e)),
            name: arr[0].trim(),
            tvgId: '',
            url: arr[1].trim());

        final platProxy = isDyHyDlProxyUrl(arr[1]);

        if (platProxy['platformHit'] == true) {
          PlayListItem _temp = parseSingleUrl(arr[1]);

          item.tvgId = _temp.tvgId;
          item.group = _temp.group;
        }
        return item;
      }).toList();
      return PlayListInfo.fromJson({'channels': list});
    } catch (e) {
      print('读取解析TXT文本行内容出错: $e');
    }
    return null;
  }

  //reg group-title, tvg-id, tvg-logo等属性表达式
  String getTextByReg(String line, RegExp reg, {String defVal = ""}) {
    Match? match = reg.firstMatch(line);

    if (match != null) {
      return match.group(1) ?? "";
    }
    return defVal;
  }
  // 解析第一行的 x-tvg-url等信息

  Map<String, dynamic> extractM3uMeta(String line) {
    return {
      "tvg-url": getTextByReg(line, new RegExp(r'(?:x-)?tvg-url="(.*?)"')),
      'show-logo': isBoolValid(
          getTextByReg(line, new RegExp(r'(?:x-)?show-logo="(.*?)"'))),
      'check-alive': isBoolValid(
          getTextByReg(line, new RegExp(r'(?:x-)?check-alive="(.*?)"')), false),
      'catchup': getTextByReg(line, new RegExp(r'catchup="(.*?)"')),
      'catchup-source':
          getTextByReg(line, new RegExp(r'catchup-source="(.*?)"')),
    };
  }

  //根据文本行 解析m3u的播放列表文件内容
  Future<PlayListInfo?> parseM3uContents(List<String> lines,
      [bool includeMeta = false]) async {
    try {
      // 移除空行
      lines.removeWhere((element) => element.isEmpty);
      if (!(lines.length > 0 && lines[0].trim().startsWith("#EXTM3U"))) {
        return null;
      }
      // 解析第一行的 x-tvg-url等信息
      final Map<String, dynamic> meta = extractM3uMeta(lines[0]);

      List<PlayListItem> list = [];
      for (var i = 0; i < lines.length; i++) {
        if (i > 0 && lines[i].startsWith("#EXTINF:")) {
          PlayListItem tempItem =
              PlayListItem.fromJson({'ext': Map<String, dynamic>.from({})});
          final info = lines[i],
              url = lines[i + 1],
              name = info.split(',').last.trim(),
              group = getTextByReg(info, new RegExp(r'group-title="(.*?)"'),
                  defVal: ''),
              tvgId = getTextByReg(info, new RegExp(r'tvg-id="(.*?)"')),
              platProxy = isDyHyDlProxyUrl(url);

          if (platProxy['platformHit'] == true) {
            PlayListItem _temp = parseSingleUrl(url);
            tempItem.group = _temp.group;
            tempItem.tvgId = _temp.tvgId;
            tempItem.ext = _temp.ext;
          }
          final item = PlayListItem(
              ext: tempItem.ext ?? Map<String, dynamic>.from({}),
              group: group.isNotEmpty ? group : (tempItem.group ?? '未分组'),
              tvgName: getTextByReg(info, new RegExp(r'tvg-name="(.*?)"')),
              tvgLogo: getTextByReg(info, new RegExp(r'tvg-logo="(.*?)"')),
              catchup: getTextByReg(info, new RegExp(r'catchup="(.*?)"')),
              catchupSource:
                  getTextByReg(info, new RegExp(r'catchup-source="(.*?)"')),
              name: name,
              tvgId: tvgId.isNotEmpty ? tvgId : tempItem.tvgId.toString(),
              url: url);
          //print(item.toJson());
          list.add(item);
          if (lines[i].trim().startsWith('#EXTM3U')) {
            final _meta = extractM3uMeta(lines[i]);
            meta.forEach((key, value) {
              if (_meta[key] != null && _meta[key].toString().isNotEmpty) {
                meta[key] = _meta[key];
              }
            });
          }
        }
      }
      return PlayListInfo.fromJson({
        ...meta,
        'channels': list,
      });
    } catch (e) {
      print('读取M3U文本行内容出错: $e');
    }
    return null;
  }

  //对播放列表分组
  Map<String, List<PlayListItem>> getPlaylistgroups(List<PlayListItem> list) {
    return groupBy(list, (e) => e.group ?? "未分组");
  }

// realtime url
  bool isRtUrl(String url) {
    const protols = [
      'rtmp',
      'rtsp',
      'rtp',
      'rtmpt',
      'rtmpt',
      'rtmps',
      'gopher',
      'mms'
    ];
    if (protols.contains(url.split('://')[0])) {
      return true;
    }
    return false;
  }

  //检查是否为真实有效的url
  bool validateUrl(String url) {
    final v = isUrl(url);
    if (!v) return isRtUrl(url);
    return v;
  }

  Future<Map> checkUrlAccessible(String url, CancelToken cancelToken) async {
    return PlaylistCheckReq().check(url, cancelToken);
  }
}
