/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:05:05
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-03 18:06:07
 * @FilePath: \vvibe\lib\components\player\player_context_menu.dart
 * @Description: 
 * @qmj
 */
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/settings/open_url_dialog.dart';
import 'package:vvibe/components/player/settings/setting_alert_dialog.dart';
import 'package:native_context_menu/native_context_menu.dart';

class PlayerContextMenu extends StatefulWidget {
  PlayerContextMenu(
      {Key? key,
      required this.onOpenUrl,
      required this.showPlaylist,
      required this.playListShowed,
      required this.child})
      : super(key: key);
  final void Function(String url) onOpenUrl;
  final void Function() showPlaylist;
  final bool playListShowed;
  final Widget child;
  @override
  _PlayerContextMenuState createState() => _PlayerContextMenuState();
}

class _PlayerContextMenuState extends State<PlayerContextMenu> {
  void _showNewWin(String key, {String? title}) async {
    final window = await DesktopMultiWindow.createWindow(jsonEncode({
      'key': key,
    }));
    window
      ..setTitle(title ?? 'VVibe')
      ..setFrame(const Offset(0, 0) & Size(1280, 720 + CUS_WIN_TITLEBAR_HEIGHT))
      ..center()
      ..show();
  }

  void _onItemSelect(BuildContext context, MenuItem item) {
    final title = item.title;
    switch (title) {
      case '打开链接':
        showDialog(
            context: context,
            builder: (context) {
              return OpenUrlDialog(
                onOpenUrl: widget.onOpenUrl,
              );
            });
        break;
      case '播放列表':
        if (widget.playListShowed) return;
        widget.showPlaylist();
        break;
      case '扫描直播源':
        _showNewWin('sniff', title: 'VVibe 直播源扫描');

        break;
      case '检测直播源':
        EasyLoading.showInfo('TODO');

        break;
      case '应用设置':
        showDialog(
            context: context,
            builder: (context) {
              return SettingAlertDialog();
            });
        break;
      case '关于应用':
        /*  showDialog(
            context: context,
            builder: (context) {
              return AboutDialog();
            }); */
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      // onDismissed: () => setState(() {}),
      onItemSelected: (item) {
        _onItemSelect(context, item);
      },
      menuItems: [
        MenuItem(title: '打开链接'),
        MenuItem(title: '播放列表'),
        MenuItem(title: '扫描直播源'),
        MenuItem(title: '检测直播源'),
        MenuItem(title: '应用设置'),
        MenuItem(title: '关于应用'),
      ],
      child: widget.child,
    );
  }
}
