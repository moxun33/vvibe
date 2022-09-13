import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/components/player/settings/open_url_dialog.dart';
import 'package:vvibe/components/player/settings/setting_alert_dialog.dart';

class PlayerContextMenu extends StatefulWidget {
  PlayerContextMenu({Key? key, required this.onOpenUrl}) : super(key: key);
  final void Function(String url) onOpenUrl;
  @override
  _PlayerContextMenuState createState() => _PlayerContextMenuState();
}

class _PlayerContextMenuState extends State<PlayerContextMenu> {
  final List<Map<String, String>> playerCtxMenus = [
    {'value': 'openUrl', 'label': '打开链接'},
    {'value': 'scanVerify', 'label': '扫源验证'},

    {'value': 'setting', 'label': '软件设置'},
    {'value': 'about', 'label': '关于软件'},
    // {'value': 'close', 'label': '关闭菜单'},
    // {'value': 'quitApp', 'label': '退出软件'},
  ];
  IconData _getIcon(String? type) {
    switch (type) {
      case 'openUrl':
        return Icons.add_link_outlined;
      case 'scanVerify':
        return Icons.satellite_alt_outlined;
      case 'setting':
        return Icons.settings_applications_outlined;
      case 'about':
        return Icons.info_outline;

      default:
        return Icons.home_outlined;
    }
  }

  void onItemTap(
    BuildContext context,
    String? type,
  ) {
    //  Navigator.pop(context);
    switch (type) {
      case 'openUrl':
        showDialog(
            context: context,
            builder: (context) {
              return OpenUrlDialog(
                onOpenUrl: widget.onOpenUrl,
              );
            });
        break;
      case 'scanVerify':
        EasyLoading.showInfo('TODO');

        break;
      case 'setting':
        showDialog(
            context: context,
            builder: (context) {
              return SettingAlertDialog();
            });
        break;
      case 'about':
        showDialog(
            context: context,
            builder: (context) {
              return AboutDialog();
            });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            width: 140,
            height: 180,
            color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                itemCount: playerCtxMenus.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = playerCtxMenus[index];
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      child: SizedBox(
                          width: 130,
                          height: 40,
                          child: Row(
                            children: [
                              Icon(
                                _getIcon(item['value']),
                                color: Colors.purple,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                item['label'] ?? '',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                              ),
                            ],
                          )),
                      onPressed: () {
                        onItemTap(
                          context,
                          item['value'],
                        );
                      },
                    ),
                  );
                })));
  }
}
