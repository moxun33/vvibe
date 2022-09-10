import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/models/subscription_url.dart';
import 'package:vvibe/utils/utils.dart';
import 'package:uuid/uuid.dart';

//订阅播放列表
class PlaylistSubscription extends StatefulWidget {
  const PlaylistSubscription({Key? key}) : super(key: key);

  @override
  _PlaylistSubscritionState createState() => _PlaylistSubscritionState();
}

class _PlaylistSubscritionState extends State<PlaylistSubscription> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final _uuid = Uuid();

  List<Map<String, dynamic>> urls = []; //所有的订阅
  Map<String, dynamic>? editUrl; //正在编辑的订阅

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

  bool _validateUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  void _submitForm() {
    //验证通过提交数据
    final name = _nameController.text, url = _urlController.text;
    if (name.isEmpty || url.isEmpty) {
      EasyLoading.showError('名称和地址都不能为空');
      return;
    }
    if (!_validateUrl(url)) {
      EasyLoading.showError('订阅地址无效');
      return;
    }
    final _urls = urls;
    final index =
        _urls.indexWhere((element) => element['id'] == editUrl?['id']);
    if (editUrl != null && index > -1) {
      editUrl!['name'] = name;
      editUrl!['url'] = url;
      _urls.fillRange(index, index, editUrl);
      setState(() {
        editUrl = null;
      });
    } else {
      final _map = {'name': name, 'url': url, 'id': _uuid.v4()};
      //_urls.add(SubscriptionUrl(id: _uuid.v4(), name: name, url: url));
      _urls.add(_map);
    }
    _updateUrlsData(_urls);
    _nameController.clear();
    _urlController.clear();
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
    _nameController.text = item['name'];
    _urlController.text = item['url'];
  }

  void _onDelete(int index) {
    final _urls = urls;
    _urls.removeAt(index);
    _updateUrlsData(_urls);
  }

  Widget _buildForm() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 300,
          child: TextField(
            autofocus: true,
            controller: _nameController,
            decoration: InputDecoration(
                hintText: "名称",
                icon: Icon(Icons.insert_chart_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _nameController.clear();
                    });
                  },
                )),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        SizedBox(
          width: 500,
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
                hintText: "URL地址, 如: http://localhost/live.m3u",
                icon: Icon(Icons.subscriptions_outlined),
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
        SizedBox(
          width: 20,
        ),
        // 登录按钮
        SizedBox(
          width: 130,
          child: Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text("保存"),
                          SizedBox(
                            width: 20,
                          ),
                          Tooltip(
                            child: Icon(Icons.question_mark_outlined),
                            message:
                                '注意：\n订阅接口响应必须为.m3u或.txt格式的文本内容;\n暂时支持斗鱼、虎牙和B站实时弹幕，请确保m3u文件的group-title分别为斗鱼或douyu、虎牙或huya、 B站或bilibili, tvg-id为真实房间id',
                          )
                        ],
                      )),
                  onPressed: () {
                    // 通过_formKey.currentState 获取FormState后，
                    // 调用validate()方法校验用户名密码是否合法，校验
                    // 通过后再提交数据。
                    _submitForm();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildForm(),
        Expanded(
            child: ListView.builder(
                itemCount: urls.length,
                itemExtent: 60.0,
                itemBuilder: (BuildContext context, int index) {
                  final item = urls[index];
                  return ListTile(
                    title: Row(children: [
                      Text(item['name']),
                      SizedBox(
                        width: 50,
                      ),
                      Tooltip(
                        child: IconButton(
                          icon: Icon(Icons.edit_outlined),
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
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _onDelete(index);
                          },
                        ),
                        message: '删除',
                      )
                    ]),
                    subtitle: Text(item['url']),
                  );
                })),
      ],
    );
  }
}
