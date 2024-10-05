/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2024-08-18 13:07:35
 * @FilePath: \vvibe\lib\main.dart
 * @Description:
 * @qmj
 */
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/pages/home/home.dart';
import 'package:vvibe/window/window.dart';
import 'package:vvibe/window/window_widgets.dart';

void main(List<String> args) async {
  Global.init().then((theme) {
    runApp(MyApp(theme: theme ?? ThemeData()));
    VWindow().initWindow();
  });
  /* if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    MyLogger.info('multi window argument $argument');
    Global.init(shouldSetSize: false).then((theme) {
      runApp(LiveSniffWin(
        theme: theme ?? ThemeData(),
        windowController: WindowController.fromWindowId(windowId),
        args: argument,
      ));
      VWindow().initWindow();
    });
  } else {
    Global.init().then((theme) {
      runApp(MyApp(theme: theme ?? ThemeData()));
      VWindow().initWindow();
    });
  } */
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VVibe',
      theme: theme.useSystemChineseFont(Brightness.light),
      home: WindowScaffold(child: HomePage()),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      locale: Locale('zh', 'Hans'),
    );
  }
}
