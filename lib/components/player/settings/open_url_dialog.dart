/*
 * @Author: Moxx
 * @Date: 2022-09-13 14:55:49
 * @LastEditors: Moxx
 * @LastEditTime: 2022-09-13 16:06:56
 * @FilePath: \vvibe\lib\components\player\settings\open_url_dialog.dart
 * @Description: 打开链接弹窗
 * @aqmj
 */
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
