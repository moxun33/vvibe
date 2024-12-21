//直播源嗅探窗口

import 'package:flutter/material.dart';

class LiveSniffWin extends StatefulWidget {
  const LiveSniffWin(
      {Key? key,
      //required this.windowController,
      required this.args,
      required this.theme})
      : super(key: key);
  final ThemeData theme;
  // final WindowController windowController;
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
    return SizedBox(); /*  return SubWindow(
      windowController: widget.windowController,
      args: widget.args,
      child: LiveSniff(),
      title: 'VVibe 直播源扫描',
      theme: widget.theme,
    ); */
  }
}
