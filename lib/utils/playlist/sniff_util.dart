//直播源扫描util

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/media_info.dart';
import 'package:vvibe/models/url_sniff_res.dart';
import 'package:vvibe/utils/ffi_util.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';

class SniffUtil {
  static SniffUtil _instance = new SniffUtil._();
  factory SniffUtil() => _instance;

  SniffUtil._();

  final client = Dio(BaseOptions(headers: {'User-Agnet': DEF_REQ_UA}));
//提取模板变量列表
  List<String> extratTplVars(String tpl) {
    RegExp reg = new RegExp(r"\[\d+-\d+\]");
    final matchRes = reg.allMatches(tpl);
    List<String> l = [];
    for (var i = 0; i < matchRes.length; i++) {
      final ele = matchRes.elementAt(i), v = ele.group(0);
      if (v != null && v.isNotEmpty) {
        l.add(v);
      }
    }
    return l;
  }

  //每个分组生成值列表
  List<String> genGroupValues(String group) {
    if (!group.startsWith('[') && !group.endsWith(']')) return [];
    final vls = group.replaceAll('[', '').replaceAll(']', '').split('-');
    if (vls.length != 2) return [];
    final start = int.tryParse(vls[0]) ?? 0, last = int.tryParse(vls[1]) ?? 0;
    if (start <= 0 || last <= 0 || last < start) return [];
    final List<String> ret = [];
    for (var i = start; i <= last; i++) {
      ret.add(i.toString().padLeft(vls[0].length, '0'));
    }
    return ret;
  }

/*  genUrls: (url: string) => {
    const expArr = url.match(REGEX_TV_PERIOD) || []

    if (expArr.length < 1) {
      return []
    }
    const list: string[] = []
    const group = expArr[0],
      periods = group.replace(/[\[\]]/g, '').split('-')

    const start = periods[0],
      end = periods[1],
      length = parseInt(end) - parseInt(start)
    for (let j = 0; j <= length; j++) {
      const item = parseInt(start) + j,
        tmpUrl = url.replace(group, item.toString().padStart(String(start).length, '0')),
        nestUrls = tvUtils.genUrls(tmpUrl)
      if (!tmpUrl.includes('[')) {
        list.push(tmpUrl)
      }
      list.push(...nestUrls)
    }

    return list
  } */
//根据变量分组和url模板生成最终url列表
  List<String> genFinalUrls(String tpl) {
    List<String> groups = extratTplVars(tpl);
    if (groups.length < 1) return [];
    List<String> res = [];
    final group = groups[0], values = genGroupValues(group);
    for (var v in values) {
      final tmpUrl = tpl.replaceFirst(group, v),
          nestUrls = genFinalUrls(tmpUrl);
      if (tmpUrl.indexOf('[') < 1 && tmpUrl.indexOf(']') < 1) {
        res.add(tmpUrl);
      }
      res.addAll(nestUrls);
    }

    return res;
  }

  //根据url模板生成url列表
  List<String> genUrlsByTpl(String tpl) {
    if (!tpl.startsWith('http://') && !tpl.startsWith('https://')) {
      EasyLoading.showError('仅支持Http协议');
      return [];
    }

    final groups = extratTplVars(tpl);
    if (groups.length < 1 || groups.length > 3) {
      EasyLoading.showError('变量分组应大于0且不能超过3个');
      return [];
    }

    List<String> res = genFinalUrls(tpl);
    return res;
  }

  final REGEX_IPV4 = new RegExp(r"\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}");
  //提取ipv4
  String extractIpv4(String url) {
    final res = REGEX_IPV4.firstMatch(url);
    if (res != null) {
      return res.group(0) ?? '';
    }
    return '';
  }

  //扫描检测url
  Future<UrlSniffRes> checkSniffUrl(String url,
      {bool withMeta = false, timeout = 3000, int index = 0}) async {
    try {
      final startTime = DateTime.now();
      final inst = Dio(new BaseOptions(
          connectTimeout: timeout, headers: {'User-Agent': DEF_REQ_UA}));
      final resp = await inst.get(url);
      MediaInfo? meta = null;
      String ipInfo = '';
      DateTime endTime = DateTime.now();
      final ipv4 = extractIpv4(url);
      if (withMeta) {
        meta = await FfiUtil().getMediaInfo(url);
      }
      if (ipv4.isNotEmpty) {
        ipInfo = (await FfiUtil().getIpInfo(ipv4)) ?? '';
      }
      print(endTime.difference(startTime).inMilliseconds);
      return UrlSniffRes.fromJson({
        'url': url,
        'index': index,
        'status': UrlSniffResStatus.success,
        'statusCode': resp.statusCode,
        'mediaInfo': meta,
        'ipInfo': ipInfo,
        'duration': endTime.difference(startTime).inMilliseconds
      });
    } on DioError catch (e) {
      print('$url 扫描错误   ${e.error}');
      return UrlSniffRes.fromJson({
        'index': index,
        'status': e.type == DioErrorType.connectTimeout
            ? UrlSniffResStatus.timeout
            : UrlSniffResStatus.failed,
        'statusCode': e.type == DioErrorType.connectTimeout ? 504 : 500,
        'mediaInfo': null,
        'ipInfo': '',
        'duration': 0,
        'url': url
      });
    }
  }

  String getVideoSize(MediaInfo? info) {
    if (info != null && info.streams != null) {
      final videos =
          info.streams!.where((element) => element.codecType == 'video');
      return videos.length > 0
          ? '${videos.first.width}*${videos.first.height}'
          : '-';
    }
    return '-';
  }

  //导出直播源为txt
  exportTxtFile(List<UrlSniffRes> list, {withInvalid = false}) async {
    final List<UrlSniffRes> data = !withInvalid
        ? list
            .where((element) => element.status == UrlSniffResStatus.success)
            .toList()
        : list;
    final Directory dir = await PlaylistUtil().getPlayListDir();
    final file =
        File('${dir.path}/直播源扫描报告${DateTime.now().millisecondsSinceEpoch}.txt');
    String contents = '${DateTime.now().toString()}\n#报告由VVibe制作\n== 有效源 ==\n';
    for (var ele in data) {
      contents = contents +
          '${ele.index}号[${getVideoSize(ele.mediaInfo)}],${ele.url}\n';
    }
    return file.writeAsString(contents);
  }
}
