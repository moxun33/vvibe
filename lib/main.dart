/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-05 22:12:59
 * @FilePath: \vvibe\lib\main.dart
 * @Description: 
 * @qmj
 */
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/langs/translation_service.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/pages/Index/Index_view.dart';
import 'package:vvibe/pages/Index/index_binding.dart';
import 'package:vvibe/router/app_pages.dart';
import 'package:get/get.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:vvibe/window/window.dart';
import 'package:vvibe/window/live_sniff_win.dart';

void main(List<String> args) async {
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    print(argument);
    Global.init(shouldSetSize: false).then((theme) {
      runApp(LiveSniffWin(
        theme: theme,
        windowController: WindowController.fromWindowId(windowId),
        args: argument,
      ));
      // VWindow().initWindow();
    });
  } else {
    Global.init().then((theme) {
      runApp(MyApp(theme: theme));
      VWindow().initWindow();
    });
  }
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VVibe',
      theme: theme,
      home: IndexPage(),
      initialBinding: IndexBinding(),
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,
      builder: EasyLoading.init(),
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
    );
  }
}
