import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/utils/local_storage.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';

import './widgets/settings_widgets.dart';

class PlayFileSettingDialog extends StatefulWidget {
  PlayFileSettingDialog({Key? key, required this.file}) : super(key: key);
  Map<String, dynamic> file;

  @override
  _PlayFileSettingDialogState createState() => _PlayFileSettingDialogState();
}

class _PlayFileSettingDialogState extends State<PlayFileSettingDialog> {
  final TextEditingController _uaTextCtl = TextEditingController();
  final TextEditingController _epgUrlTextCtl = TextEditingController();
  final TextEditingController _bgController = TextEditingController();
  late String name, url, ua, epg, blackGroups;
  bool _checkAlive = false;
  bool _showLogo = false;
  bool _deinterlace = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Map<String, dynamic> get file => widget.file;
  String get cacheKey => '${file['name'] ?? 'default'}_PLAY_SETTINGS';
  void _initData() async {
    final v = await LoacalStorage().getJSON(cacheKey);
    if (v != null) {
      print(v);
      _uaTextCtl.text = v['ua'] ?? '';
      _epgUrlTextCtl.text = v['epg'] ?? '';
      _epgUrlTextCtl.text = v['epg'] ?? '';
      _bgController.text = v['blackGroups'] ?? '';
      setState(() {
        _checkAlive = PlaylistUtil().isBoolValid(v['checkAlive'], false);
        _showLogo = PlaylistUtil().isBoolValid(v['showLogo']);
        _deinterlace = PlaylistUtil().isBoolValid(v['deinterlace'], false);
      });
    }
  }

  _submit() {
    final values = {};
    values['ua'] = _uaTextCtl.text;
    values['epg'] = _epgUrlTextCtl.text;
    values['blackGroups'] = _bgController.text;
    values['checkAlive'] = _checkAlive.toString();
    values['showLogo'] = _showLogo.toString();
    values['deinterlace'] = _deinterlace.toString();
    LoacalStorage().setJSON(cacheKey, values);
    EasyLoading.showSuccess('保存成功');
  }

  get _buildInputRow => SettingsWidgets.buildInputRow;
  get _buildSwitch => SettingsWidgets.buildSwitch;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('${widget.file['name']} 播放设置'),
        actions: [
          //TextButton(child: const Text('保存'), onPressed: () {}),
        ],
        content: SizedBox(
          width: 800,
          height: 500,
          child: Column(
            children: [
              _buildInputRow(_uaTextCtl,
                  label: 'User-Agent',
                  decoration: InputDecoration(
                      hintText: '当前文件请求User-Agent，默认  ${DEF_REQ_UA}')),
              _buildInputRow(_epgUrlTextCtl,
                  label: 'EPG地址',
                  decoration: InputDecoration(
                      hintText: '当前文件EPG地址，支持.xml/.xml.gz，默认 ${DEF_EPG_URL}')),
              _buildInputRow(_bgController,
                  label: '屏蔽分组',
                  decoration: InputDecoration(hintText: '屏蔽分组, 英文逗号分隔')),
              Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      _buildSwitch('实时检测', _checkAlive, (value) {
                        setState(() {
                          _checkAlive = value;
                        });
                      }),
                      SizedBox(
                        width: 50,
                      ),
                      _buildSwitch('频道图标', _showLogo, (value) {
                        setState(() {
                          _showLogo = value;
                        });
                      }),
                      SizedBox(
                        width: 50,
                      ),
                      _buildSwitch('反交错', _deinterlace, (value) {
                        setState(() {
                          _deinterlace = value;
                        });
                      }),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text("立即保存"),
                            ],
                          )),
                      onPressed: () {
                        _submit();
                      },
                    ),
                  )))
            ],
          ),
        ));
  }
}
