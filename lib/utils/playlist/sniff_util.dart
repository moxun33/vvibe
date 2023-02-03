//直播源扫描util
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';

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
    print(groups);
    List<String> res = [];
    return res;
  }
}
