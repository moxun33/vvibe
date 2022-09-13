/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:55:49
 * @LastEditors: moxun33
 * @LastEditTime: 2022-09-13 20:57:04
 * @FilePath: \vvibe\lib\components\player\settings\open_url_dialog.dart
 * @Description: 打开链接弹窗
 * @aqmj
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';

class OpenUrlDialog extends StatefulWidget {
  OpenUrlDialog({Key? key, required this.onOpenUrl}) : super(key: key);
  final void Function(String url) onOpenUrl;
  @override
  _OpenUrlDialogState createState() => _OpenUrlDialogState();
}

class _OpenUrlDialogState extends State<OpenUrlDialog> {
  final TextEditingController _urlController = TextEditingController();
  void _openUrl(BuildContext context) {
    final url = _urlController.text;
    if (url.isEmpty) {
      EasyLoading.showError('请输入播放链接');
      return;
    }
    Navigator.pop(context);
    widget.onOpenUrl(url);
  }

  void checkClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      final valid = PlaylistUtil().validateUrl(data.text ?? '');
      if (valid) {
        _urlController.text = data.text!;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkClipboard();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('打开链接'),
      actions: [
        TextButton(
            child: const Text('打开'),
            onPressed: () {
              _openUrl(context);
            }),
      ],
      content: SizedBox(
        width: 500,
        height: 100,
        child: TextField(
          autofocus: true,
          controller: _urlController,
          decoration: InputDecoration(
              hintText: "播放链接",
              icon: Icon(Icons.add_link_sharp),
              suffixIcon: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _urlController.clear();
                  });
                },
              )),
        ),
      ),
    );
  }
}
