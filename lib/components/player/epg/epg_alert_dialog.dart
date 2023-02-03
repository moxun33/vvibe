//播放器的设置弹窗
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vvibe/components/player/epg/epg_date_tabs.dart';
import 'package:vvibe/models/playlist_item.dart';

class EpgAlertDialog extends StatefulWidget {
  const EpgAlertDialog({Key? key, required this.urlItem}) : super(key: key);

  final PlayListItem urlItem;
  @override
  _EpgAlertDialogState createState() => _EpgAlertDialogState();
}

class _EpgAlertDialogState extends State<EpgAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('节目单'),
      actions: [
        TextButton(child: const Text(''), onPressed: () {}),
      ],
      content: SizedBox(
        width: 1000,
        height: Get.size.height,
        child: EpgDateTabsView(),
      ),
    );
  }
}
