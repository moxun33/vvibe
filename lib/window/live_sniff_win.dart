//直播源嗅探窗口
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/langs/translation_service.dart';
import 'package:vvibe/components/sniff/live_sniff.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class LiveSniffWin extends StatefulWidget {
  const LiveSniffWin(
      {Key? key,
      required this.windowController,
      required this.args,
      required this.theme})
      : super(key: key);
  final ThemeData theme;
  final WindowController windowController;
  final Map? args;

  @override
  _LiveSniffWinState createState() => _LiveSniffWinState();
}

class _LiveSniffWinState extends State<LiveSniffWin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LiveSniff(),
      title: 'VVibe 直播源扫描',
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      locale: TranslationService.locale,
    );
  }
}
