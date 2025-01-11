//播放器的设置弹窗
import 'package:flutter/material.dart';
import 'package:vvibe/components/player/epg/epg_date_tabs.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/utils.dart';

class EpgAlertDialog extends StatefulWidget {
  const EpgAlertDialog(
      {Key? key, required this.urlItem, this.epgUrl, required this.doPlayback})
      : super(key: key);

  final PlayListItem urlItem;
  final String? epgUrl;
  final Function doPlayback;
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
        height: getDeviceHeight(context),
        child: EpgDateTabsView(
          epgUrl: widget.epgUrl,
          doPlayback: widget.doPlayback,
          urlItem: widget.urlItem,
        ),
      ),
    );
  }
}
