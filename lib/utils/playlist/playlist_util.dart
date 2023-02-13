/*
 * @Author: Moxx
 * @Date: 2022-09-13 16:22:39
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-13 18:05:28
 * @FilePath: \vvibe\lib\utils\playlist\playlist_util.dart
 * @Description: 
 * @qmj
 */
import 'dart:io';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:collection/collection.dart';
import 'package:vvibe/models/playlist_text_group.dart';
import 'package:vvibe/services/danmaku/danmaku_type.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/utils/logger.dart';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //创建目录（在应用根目录下）
  Future<Directory> createDir(String dirName) async {
    final dir = Directory(dirName);
    if (!await (dir.exists())) {
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

  //获取本地播放列表文件列表
  Future<List<String>> getPlayListFiles({bool basename = false}) async {
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
      return list;
    } catch (e) {
      return [];
    }
  }

  //解析【本地】文件的播放列表内容
  Future<List<PlayListItem>> parsePlaylistFile(String filePath) async {
    try {
      if (filePath.endsWith('.m3u')) {
        final lines = await compute(readFileLines, filePath);
        return compute(parseM3uContents, lines);
      }

      if (filePath.endsWith('.txt')) {
        final lines = await compute(readFileLines, filePath);

        return compute(parseTxtContents, lines);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

//获取订阅地址列表
  Future<List<Map<String, dynamic>>> getSubUrls() async {
    final list = await LoacalStorage().getJSON(PLAYLIST_SUB_URLS);
    return list != null ? List<Map<String, dynamic>>.from(list) : [];
  }

  final dioCacheOptions = CacheOptions(
    // A default store is required for interceptor.
    store: MemCacheStore(),
    maxStale: const Duration(hours: 10),
  );
  //判断是否为斗鱼、虎牙、b站的代理url
  Map<String, bool> isDyHyDlProxyUrl(String url) {
    final uri = Uri.parse(url),
        matchDy = uri.path.contains(DanmakuType.douyuProxyUrlReg),
        matchHy = uri.path.contains(DanmakuType.huyaProxyUrlReg),
        matchBl = uri.path.contains(DanmakuType.biliProxyUrlReg);

    return {'douyu': matchDy, 'huya': matchHy, 'bilibili': matchBl};
  }
  //根据单个打开的url解析

  PlayListItem parseSingleUrl(String url) {
    String group = '未分组';
    String tvgId = '';
    try {
      final uri = Uri.parse(url),
          matches = isDyHyDlProxyUrl(url),
          matchDy = matches['douyu'] == true,
          matchHy = matches['huya'] == true,
          matchBl = matches['bilibili'] == true;
      if (matchDy) group = DanmakuType.douyuCN;
      if (matchHy) group = DanmakuType.huyaCN;
      if (matchBl) group = DanmakuType.bilibiliCN;
      if (matchBl || matchHy || matchDy) {
        final queryId = uri.queryParameters['id'], pathSegs = uri.pathSegments;
        if (queryId != null && queryId.isNotEmpty) {
          tvgId = queryId;
        } else if (pathSegs.isNotEmpty && int.parse(pathSegs.last) > 0) {
          tvgId = pathSegs.last;
        }
      }
    } catch (e) {
      Logger.error('解析 $url 出错 ${e.toString()}');
    }
    final PlayListItem item = PlayListItem.fromJson(
        {'url': url, 'name': 'vvibe', 'group': group, 'tvgId': tvgId});
    return item;
  }

//根据url解析远程txt或m3u内容
  Future<List<PlayListItem>> parsePlaylistSubUrl(String url) async {
    final client = Dio()
      ..interceptors.add(DioCacheInterceptor(options: dioCacheOptions));
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

    return [];
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
      if (line.contains(',') &&
          (line.contains('#genre#') || !line.contains('://'))) {
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
  List<PlayListItem> parseTxtContents(List<String> lines) {
    try {
      final groups = parseTxtGroups(lines);
      final list = lines
          .where((element) =>
              element.contains(',') &&
              !element.contains('#genre#') &&
              element.contains('://'))
          .map((String e) {
            final List<String> arr = e.split(',');

            return PlayListItem(
                group: matchTxtUrlGroup(groups, lines.indexOf(e)),
                name: arr[0].trim(),
                tvgId: '',
                url: arr[1]);
          })
          .where((PlayListItem element) =>
              element.url != null && element.name != null)
          .toList();
      return list;
    } catch (e) {
      print('读取解析TXT文本行内容出错: $e');
      return [];
    }
  }

  //reg group-title, tvg-id, tvg-logo等属性表达式
  String getTextByReg(String line, RegExp reg, {String defVal = ""}) {
    Match? match = reg.firstMatch(line);

    if (match != null) {
      return match.group(1) ?? "";
    }
    return defVal;
  }

  //根据文本行 解析m3u的播放列表文件内容
  List<PlayListItem> parseM3uContents(List<String> lines) {
    try {
      if (!(lines.length > 0 && lines[0].startsWith("#EXTM3U"))) {
        return [];
      }

      List<PlayListItem> list = [];
      for (var i = 0; i < lines.length; i++) {
        if (i > 0 && lines[i].startsWith("#EXTINF:")) {
          PlayListItem tempItem = PlayListItem.fromJson({});
          final info = lines[i],
              url = lines[i + 1],
              name = info.split(',').last.trim(),
              group = getTextByReg(info, new RegExp(r'group-title="(.*?)"'),
                  defVal: ''),
              tvgId = getTextByReg(info, new RegExp(r'tvg-id="(.*?)"')),
              platProxy = isDyHyDlProxyUrl(url);

          if (platProxy['douyu'] == true ||
              platProxy['huya'] == true ||
              platProxy['bilibili'] == true) {
            PlayListItem _temp = parseSingleUrl(url);
            tempItem.group = _temp.group;
            tempItem.tvgId = _temp.tvgId;
             
          }
          final item = PlayListItem(
              group: group.isNotEmpty ? group : (tempItem.group ?? '未分组'),
              tvgName: getTextByReg(info, new RegExp(r'tvg-name="(.*?)"')),
              tvgLogo: getTextByReg(info, new RegExp(r'tvg-logo="(.*?)"')),
              catchup: getTextByReg(info, new RegExp(r'catchup="(.*?)"')),
              catchupSource:
                  getTextByReg(info, new RegExp(r'catchup-source="(.*?)"')),
              name: name,
              tvgId: tvgId.isNotEmpty ? tvgId : tempItem.tvgId.toString(),
              url: url);
          print(item.toJson());
          list.add(item);
        }
      }
      return list;
    } catch (e) {
      print('读取M3U文本行内容出错: $e');
      return [];
    }
  }

  //对播放列表分组
  Map<String, List<PlayListItem>> getPlaylistgroups(List<PlayListItem> list) {
    return groupBy(list, (e) => e.group ?? "未分组");
  }

  //检查是否为真实有效的url
  bool validateUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  Future<int?> checkUrlAccessible(String url,
      {bool isolate = false, bool reqGet = false}) async {
    try {
      final inst = Dio(new BaseOptions(
          connectTimeout: 3000, headers: {'User-Agent': DEF_REQ_UA}));
      final req = inst.head;
      dynamic resp;
      if (isolate) {
        resp = await compute(req, url);
      } else {
        resp = await req(url);
      }
      //debugPrint('检查 $url 可访问状态:${resp.statusCode} ');
      return resp.statusCode;
      /* return resp.statusCode != 200 && !reqGet
          ? checkUrlAccessible(url, isolate: isolate, reqGet: true)
          : resp.statusCode; */
    } on DioError catch (e) {
      final num = e.response?.statusCode ?? 500;

      debugPrint('检查 $url 可访问出错：  $num  ${e.message}');

      return num;
    }
  }
}
