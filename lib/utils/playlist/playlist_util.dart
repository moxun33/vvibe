/*
 * @Author: Moxx
 * @Date: 2022-09-13 16:22:39
 * @LastEditors: Moxx
 * @LastEditTime: 2022-09-19 17:29:17
 * @FilePath: \vvibe\lib\utils\playlist\playlist_util.dart
 * @Description: 
 * @qmj
 */
import 'dart:io';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vvibe/common/values/storage.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:collection/collection.dart';
import 'package:vvibe/models/playlist_text_group.dart';
import 'package:vvibe/utils/local_storage.dart';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //本地播放列表目录
  Future<Directory> getPlayListDir() async {
    final dir = Directory('playlist');
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  //获取本地播放列表文件列表
  Future<List<String>> getPlayListFiles({bool basename = false}) async {
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
  }

  //解析【本地】文件的播放列表内容
  Future<List<PlayListItem>> parsePlaylistFile(String filePath) async {
    try {
      if (filePath.endsWith('.m3u')) {
        final lines = await compute(readFileLines, filePath);
        return compute(parseM3uContents, lines);
      }

      if (filePath.endsWith('.txt')) {
        final lines = await readFileLines(filePath);

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
      store: MemCacheStore());
//根据url解析远程txt或m3u内容
  Future<List<PlayListItem>> parsePlaylistSubUrl(String url) async {
    final client = Dio()
      ..interceptors.add(DioCacheInterceptor(options: dioCacheOptions));
    final resp = await client.get(url);
    if (resp.statusCode == 200) {
      final String _data = resp.data;
      final List<String> lines = _data.split('\n');
      if (lines.length > 0 && lines[0].startsWith('#EXTM3U')) {
        return compute(parseM3uContents, lines);
      } else {
        return compute(parseTxtContents, lines);
      }
    }

    return [];
  }

//读取文件文本行内容
  Future<List<String>> readFileLines(String filePath) async {
    return File(filePath).readAsLines();
  }

//解析text的分组 [{'group':'name','index':0}]
  List<PlayListTextGroup> parseTxtGroups(List<String> lines) {
    List<PlayListTextGroup> groups = [];
    for (var line in lines) {
      if (line.contains(',') && line.contains('#genre#')) {
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
              element.contains(',') && !element.contains('#genre#'))
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
          final info = lines[i],
              url = lines[i + 1],
              name = info.split(',').last.trim();
          list.add(PlayListItem(
              group: getTextByReg(info, new RegExp(r'group-title="(.*?)"'),
                  defVal: '未分组'),
              tvgName: getTextByReg(info, new RegExp(r'tvg-name="(.*?)"')),
              tvgLogo: getTextByReg(info, new RegExp(r'tvg-logo="(.*?)"')),
              catchup: getTextByReg(info, new RegExp(r'catchup="(.*?)"')),
              catchupSource:
                  getTextByReg(info, new RegExp(r'catchup-source="(.*?)"')),
              name: name,
              tvgId: getTextByReg(info, new RegExp(r'tvg-id="(.*?)"')),
              url: url));
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

  Future<int?> checkUrlAccessible(String url, {bool isolate = false}) async {
    try {
      final req = Dio(new BaseOptions(
          connectTimeout: 5000, headers: {'User-Agent': 'Windows ZTE'})).head;
      dynamic resp;
      if (isolate) {
        resp = await compute(req, url);
      } else {
        resp = await req(url);
      }

      //  debugPrint('检查 $url 可访问状态:${resp.statusCode} ');

      return resp.statusCode;
    } on DioError catch (e) {
      final num = e.response?.statusCode ?? 500;

      debugPrint('检查 $url 可访问出错：  $num');

      return num;
    }
  }
}
