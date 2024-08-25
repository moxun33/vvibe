//播放器的设置弹窗
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';
import 'package:vvibe/utils/utils.dart';

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
  bool _fullFfmpeg = false;
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
        _checkAlive = v['checkAlive'].toString() == 'false' ? false : true;
        _fullFfmpeg = v['fullFfmpeg'].toString() == 'true' ? true : false;
      });
    }
  }

  Widget _buldInputRow(TextEditingController controller,
      {String? label, InputDecoration? decoration}) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: Text(label ?? '', style: TextStyle(color: Colors.purple))),
        SizedBox(
          width: 350,
          child: TextField(controller: controller, decoration: decoration),
        )
      ],
    );
  }

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
      'fullFfmpeg': _fullFfmpeg.toString()
    };
    await LoacalStorage().setJSON(PLAYER_SETTINGS, _map);
    EasyLoading.showSuccess('保存成功');
    EpgUtil().downloadEpgDataIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1500,
      child: Column(
        children: [
          Row(
            children: [
              _buldInputRow(_uaTextCtl,
                  label: 'User-Agent',
                  decoration: InputDecoration(
                      hintText: '全局请求User-Agent，默认  ${DEF_REQ_UA}')),
              SizedBox(
                width: 50,
              ),
              _buldInputRow(_epgUrlTextCtl,
                  label: 'EPG地址',
                  decoration:
                      InputDecoration(hintText: 'EPG地址，默认 ${DEF_EPG_URL}')),
            ],
          ),
          Row(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 60,
                      child:
                          Text('实时检测', style: TextStyle(color: Colors.purple))),
                  SizedBox(
                    width: 150,
                    child: Switch(
                      value: _checkAlive, //当前状态
                      onChanged: (value) {
                        //重新构建页面
                        setState(() {
                          _checkAlive = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                width: 290,
              ),
              _buldInputRow(_danmuFSizeTextCtl,
                  label: '弹幕大小',
                  decoration: InputDecoration(hintText: '弹幕字体大小，默认20')),
              SizedBox(
                width: 50,
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                  width: 60,
                  child:
                      Text('FFmpeg', style: TextStyle(color: Colors.purple))),
              SizedBox(
                width: 150,
                child: Switch(
                  value: _fullFfmpeg, //当前状态
                  onChanged: (value) {
                    //重新构建页面
                    setState(() {
                      _fullFfmpeg = value;
                    });
                  },
                ),
              ),
              Expanded(
                  child: Text('默认是裁剪版ffmpeg。开启后自动下载完整版ffmpeg，支持开启反交错等滤镜。重启生效。'))
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Center(
            child: ElevatedButton(
              child:
                  Padding(padding: const EdgeInsets.all(10), child: Text("保存")),
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
