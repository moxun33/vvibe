import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/utils/utils.dart';

//订阅播放列表
class PlaylistSubscription extends StatefulWidget {
  const PlaylistSubscription({Key? key}) : super(key: key);

  @override
  _PlaylistSubscritionState createState() => _PlaylistSubscritionState();
}

class _PlaylistSubscritionState extends State<PlaylistSubscription> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _uaController = TextEditingController();
  final TextEditingController _epgController = TextEditingController();
  final TextEditingController _bgController = TextEditingController();
  final _uuid = Uuid();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> urls = []; //所有的订阅
  Map<String, dynamic>? editUrl; //正在编辑的订阅
  late String name, url, ua, epg, blackGroups;
  bool _checkAlive = false;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final v = await LoacalStorage().getJSON(PLAYLIST_SUB_URLS);
    if (v != null) {
      print(v);
      setState(() {
        urls = new List<Map<String, dynamic>>.from(v);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _submitForm();
    }
  }

  void _submitForm() {
    final _urls = urls;
    final index =
        _urls.indexWhere((element) => element['id'] == editUrl?['id']);
    if (editUrl != null && index > -1) {
      editUrl!['name'] = name.isEmpty ? '未命名' : name;
      editUrl!['url'] = url;
      editUrl!['ua'] = ua;
      editUrl!['epg'] = epg;
      editUrl!['blackGroups'] = blackGroups;
      editUrl!['checkAlive'] = _checkAlive.toString();
      editUrl!['showLogo'] = _showLogo.toString();

      _urls.fillRange(index, index, editUrl);
      setState(() {
        editUrl = null;
      });
    } else {
      final _map = {
        'name': name,
        'url': url,
        'id': _uuid.v4(),
        'ua': ua,
        'epg': epg,
        'blackGroups': blackGroups,
        'checkAlive': _checkAlive.toString(),
        'showLogo': _showLogo.toString()
      };
      //_urls.add(SubscriptionUrl(id: _uuid.v4(), name: name, url: url));
      _urls.add(_map);
    }
    _updateUrlsData(_urls);
    _nameController.clear();
    _urlController.clear();
    _uaController.clear();
    _epgController.clear();
    _bgController.clear();
  }

  void _updateUrlsData(List<Map<String, dynamic>> list) {
    setState(() {
      urls = list;
    });
    LoacalStorage().setJSON(PLAYLIST_SUB_URLS, list);
    EasyLoading.showSuccess('保存成功');
  }

//编辑
  void _onEdit(item) {
    setState(() {
      editUrl = item;
    });
    _nameController.text = item['name'] ?? '';
    _urlController.text = item['url'] ?? '';
    _uaController.text = item['ua'] ?? '';
    _epgController.text = item['epg'] ?? '';
    _bgController.text = item['blackGroups'] ?? '';
    setState(() {
      _checkAlive = PlaylistUtil().isBoolValid(item['checkAlive'], false);
      _showLogo = PlaylistUtil().isBoolValid(item['showLogo']);
    });
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  void _onDelete(int index) {
    final _urls = urls;
    _urls.removeAt(index);
    _updateUrlsData(_urls);
  }

  String? _validateUrl(value) {
    if (value.isEmpty) {
      return '不能为空';
    }
    // 判断url
    if (!PlaylistUtil().isUrl(value)) {
      return 'URL无效';
    }
    return null;
  }

  String? _validateEpgUrl(value) {
    if (!value.isEmpty) {
      return _validateUrl(value);
    }
    return null;
  }

  Widget _buildSubsList() {
    return ListView.builder(
        itemCount: urls.length,
        itemExtent: 70.0,
        itemBuilder: (BuildContext context, int index) {
          final item = urls[index];
          return ListTile(
            title: Row(children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: Icon(
                          PlaylistUtil().isStrValid(item['epg'])
                              ? Icons.event_repeat_sharp
                              : Icons.link,
                          color: PlaylistUtil().isStrValid(item['epg'])
                              ? Colors.green
                              : AppColors.primaryColor,
                          size: 12)),
                  SelectableText(
                    item['name'],
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              SizedBox(
                width: 50,
              ),
              Tooltip(
                child: IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 16,
                  ),
                  onPressed: () {
                    _onEdit(item);
                  },
                ),
                message: '编辑',
              ),
              Tooltip(
                child: IconButton(
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _onDelete(index);
                  },
                ),
                message: '删除',
              )
            ]),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: Icon(
                        PlaylistUtil().isStrValid(item['showLogo'])
                            ? Icons.tv_outlined
                            : Icons.tv_off_outlined,
                        color: Colors.orange,
                        size: 12,
                      )),
                  SelectableText(
                    item['url'],
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            contentPadding: EdgeInsets.all(0),
          );
        });
  }

  Widget _buildForm2() {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        TextFormField(
          autofocus: true,
          controller: _urlController,
          decoration: InputDecoration(
            labelText: '订阅地址, 如: http://a.cn/a.m3u',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          onSaved: (value) {
            this.url = value!;
          },
          validator: _validateUrl,
        ),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
              labelText: '名称', labelStyle: TextStyle(color: Colors.grey)),
          onSaved: (value) {
            this.name = value!;
          },
        ),
        TextFormField(
          controller: _uaController,
          decoration: InputDecoration(
            labelText: 'User-Agent',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          onSaved: (value) {
            this.ua = value!;
          },
        ),
        TextFormField(
          controller: _epgController,
          decoration: InputDecoration(
            labelText: 'EPG地址，支持.xml/.xml.gz',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          onSaved: (value) {
            this.epg = value!;
          },
          validator: _validateEpgUrl,
        ),
        TextFormField(
          controller: _bgController,
          decoration: InputDecoration(
              labelText: '屏蔽分组, 英文逗号分隔',
              labelStyle: TextStyle(color: Colors.grey)),
          onSaved: (value) {
            this.blackGroups = value!;
          },
        ),
        Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                SizedBox(
                    width: 60,
                    child:
                        Text('实时检测', style: TextStyle(color: Colors.purple))),
                SizedBox(
                  width: 80,
                  child: Switch(
                    value: _checkAlive, //当前状态
                    onChanged: (value) {
                      setState(() {
                        _checkAlive = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                    width: 60,
                    child:
                        Text('频道图标', style: TextStyle(color: Colors.purple))),
                SizedBox(
                  width: 80,
                  child: Switch(
                    value: _showLogo, //当前状态
                    onChanged: (value) {
                      setState(() {
                        _showLogo = value;
                      });
                    },
                  ),
                ),
              ],
            )),
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
                child: SizedBox(
              width: 150,
              child: ElevatedButton(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text("立即保存"),
                        SizedBox(
                          width: 20,
                          child: Tooltip(
                            child: Icon(Icons.question_mark_outlined),
                            message:
                                '注意：订阅接口响应须为.m3u或.txt格式的标准文本内容;\n暂时支持斗鱼、虎牙和B站实时弹幕，请确保m3u文件的group-title分别为斗鱼或douyu、虎牙或huya、 B站或bilibili, tvg-id为真实房间id',
                          ),
                        ),
                      ],
                    )),
                onPressed: () {
                  _submit();
                },
              ),
            )))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(right: 10),
          width: 400,
          child: _buildForm2(),
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.black12, width: 0.5))),
          child: _buildSubsList(),
        )),
      ],
    );
  }
}
