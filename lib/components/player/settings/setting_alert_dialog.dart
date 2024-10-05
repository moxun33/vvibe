//播放器的设置弹窗
import 'package:flutter/material.dart';
import 'package:vvibe/components/player/settings/setting_tabs.dart';
import 'package:vvibe/utils/utils.dart';

class SettingAlertDialog extends StatefulWidget {
  const SettingAlertDialog({Key? key}) : super(key: key);

  @override
  _SettingAlertDialogState createState() => _SettingAlertDialogState();
}

class _SettingAlertDialogState extends State<SettingAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置'),
      actions: [
        TextButton(child: const Text(''), onPressed: () {}),
      ],
      content: SizedBox(
        width: 1000,
        height: getDeviceHeight(context),
        child: SettingsTabsView(),
      ),
    );
  }
}
