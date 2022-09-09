import 'package:flutter/material.dart';
import 'package:vvibe/components/player/settings/setting_alert_dialog.dart';

class PlayerContextMenu extends StatefulWidget {
  const PlayerContextMenu({Key? key}) : super(key: key);

  @override
  _PlayerContextMenuState createState() => _PlayerContextMenuState();
}

class _PlayerContextMenuState extends State<PlayerContextMenu> {
  final List<Map<String, String>> playerCtxMenus = [
    {'value': 'openUrl', 'label': '打开链接'},
    {'value': 'scanUrl', 'label': '扫源工具'},
    {'value': 'verifyUrl', 'label': '验证有效性'},
    {'value': 'setting', 'label': '软件设置'},
    {'value': 'about', 'label': '关于软件'},
    // {'value': 'close', 'label': '关闭菜单'},
    // {'value': 'quitApp', 'label': '退出软件'},
  ];
  IconData _getIcon(String? type) {
    switch (type) {
      case 'openUrl':
        return Icons.add_link_outlined;
      case 'scanUrl':
        return Icons.satellite_alt_outlined;
      case 'verifyUrl':
        return Icons.library_add_check_outlined;
      case 'setting':
        return Icons.settings_applications_outlined;
      case 'about':
        return Icons.info_outline;
      case 'close':
        return Icons.close_sharp;
      case 'quitApp':
        return Icons.exit_to_app_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  void onItemTap(type) {
    switch (type) {
      case 'openUrl':
        break;
      case 'scanUrl':
        break;
      case 'verifyUrl':
        break;
      case 'setting':
        showDialog(
            context: context,
            builder: (context) {
              return SettingAlertDialog();
            });
        break;
      case 'about':
        break;
      case 'close':
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
            height: 220,
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
                        onItemTap(item['value']);
                      },
                    ),
                  );
                })));
  }
}
