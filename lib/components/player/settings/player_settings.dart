//播放器的设置弹窗
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';
import 'package:vvibe/utils/utils.dart';

import 'widgets/settings_widgets.dart';

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({Key? key}) : super(key: key);

  @override
  _PlayerSettingsState createState() => _PlayerSettingsState();
}

class _PlayerSettingsState extends State<PlayerSettings> {
  final TextEditingController _uaTextCtl = TextEditingController();
  final TextEditingController _epgUrlTextCtl = TextEditingController();
  final TextEditingController _danmuFSizeTextCtl = TextEditingController();
  bool _checkAlive = true;
  bool _deinterlace = false;
  bool _showLogo = false;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final v = await LoacalStorage().getJSON(PLAYER_SETTINGS);

    if (v != null) {
      _uaTextCtl.text = v['ua'] ?? '';
      _epgUrlTextCtl.text = v['epg'] ?? '';
      _danmuFSizeTextCtl.text = v['dmFSize'].toString();
      setState(() {
        _checkAlive = PlaylistUtil().isBoolValid(v, false);
        _deinterlace = PlaylistUtil().isBoolValid(v['deinterlace'], false);
        _showLogo = PlaylistUtil().isBoolValid(v['showLogo']);
      });
    }
  }

  get _buildInputRow => SettingsWidgets.buildInputRow;
  get _buildSwitch => SettingsWidgets.buildSwitch;

  void save() async {
    final ua = _uaTextCtl.text,
        epg = _epgUrlTextCtl.text,
        dmFSize = _danmuFSizeTextCtl.text;
    if (double.tryParse(dmFSize) == null) {
      EasyLoading.showError('弹幕尺寸只能输入数字');
      return;
    }
    final _map = {
      'ua': ua.isNotEmpty ? ua : DEF_REQ_UA,
      'epg': epg.isNotEmpty ? epg : DEF_EPG_URL,
      'dmFSize': dmFSize.isNotEmpty ? int.parse(dmFSize) : DEF_DM_FONT_SIZE,
      'checkAlive': _checkAlive.toString(),
      'deinterlace': _deinterlace.toString(),
      'showLogo': _showLogo.toString(),
    };
    await LoacalStorage().setJSON(PLAYER_SETTINGS, _map);
    EasyLoading.showSuccess('保存成功');
    EpgUtil().downloadEpgDataAync();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1500,
      child: Column(
        children: [
          Row(
            children: [
              _buildInputRow(_uaTextCtl,
                  label: 'User-Agent',
                  inputWidth: 450.0,
                  decoration: InputDecoration(
                      hintText: '全局请求User-Agent，默认  ${DEF_REQ_UA}')),
              SizedBox(
                width: 50,
              ),
              _buildInputRow(_epgUrlTextCtl,
                  label: 'EPG地址',
                  inputWidth: 350.0,
                  decoration:
                      InputDecoration(hintText: 'EPG地址，默认 ${DEF_EPG_URL}')),
            ],
          ),
          Row(children: [
            _buildInputRow(_danmuFSizeTextCtl,
                label: '弹幕大小',
                inputWidth: 450.0,
                decoration: InputDecoration(hintText: '弹幕字体大小，默认20')),
          ]),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Row(
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
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Center(
            child: ElevatedButton(
              child: Padding(
                  padding: const EdgeInsets.all(10), child: Text("立即保存")),
              onPressed: () {
                // 通过_formKey.currentState 获取FormState后，
                // 调用validate()方法校验用户名密码是否合法，校验
                // 通过后再提交数据。
                save();
              },
            ),
          )
        ],
      ),
    );
  }
}
