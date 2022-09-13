/*
 * @Author: Moxx 
 * @Date: 2022-09-02 16:32:16 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-10 00:55:23
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/playlist/playlist_widgets.dart';
import 'package:vvibe/components/spinning.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:vvibe/utils/utils.dart';

class VideoPlaylist extends StatefulWidget {
  const VideoPlaylist({Key? key, required this.onUrlTap, this.visible = false})
      : super(key: key);
  final void Function(PlayListItem item) onUrlTap;
  final bool visible;
  @override
  _VideoPlaylistState createState() => _VideoPlaylistState();
}

class _VideoPlaylistState extends State<VideoPlaylist> {
  List<PlayListItem> playlist = [];
  List<Map<String, dynamic>> playFiles = []; //本地、订阅列表
  String? selectedFilename = null;
  bool loading = true;
  //初始化状态时使用，我们可以在这里设置state状态
  //也可以请求网络数据后更新组件状态
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final _files = await PlaylistUtil().getPlayListFiles(basename: true);
    //订阅url列表
    final _urls = await PlaylistUtil().getSubUrls(), urls = _urls;
    urls.addAll(_files.map((e) => {'name': e}));
    setState(() => playFiles = urls);
    final lastSelect = LoacalStorage().getJSON(LAST_PLAYLIST_FILE_OR_SUB);
    if (lastSelect == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final lastFile = lastSelect['name'];

    if (lastFile != '' && _files.contains(lastFile)) {
      onPlayFileChange(jsonEncode(lastSelect));
    }
    //初始化订阅url的列表

    setState(() {
      loading = false;
    });
  }

  void updatePlaylistFiles() async {
    final files = await PlaylistUtil().getPlayListFiles(basename: true);
    final urls = await PlaylistUtil().getSubUrls();
    urls.addAll(files.map((e) => {'name': e}));
    setState(() => playFiles = urls);
  }

//切换播放文件或订阅
  void onPlayFileChange(String? value) async {
    setState(() {
      playlist = [];
      selectedFilename = value;
    });

    if (value != null) {
      setState(() {
        loading = true;
      });
      final map = jsonDecode(value);
      debugPrint(value);
      LoacalStorage().setJSON(LAST_PLAYLIST_FILE_OR_SUB, map);
      List<PlayListItem> data = [];
      if (map['url'] != null) {
        data = await PlaylistUtil().parsePlaylistSubUrl(map['url']);
        PlaylistUtil().parsePlaylistSubUrl(map['url']).then((list) {
          setState(() => playlist = list);
          LoacalStorage().setJSON(LAST_PLAYLIST_DATA, list);
        });
      } else {
        //本地文件
        data =
            await PlaylistUtil().parsePlaylistFile("playlist/${map['name']}");
      }
      setState(() {
        playlist = data;
        loading = false;
      });
      LoacalStorage().setJSON(LAST_PLAYLIST_DATA, data);
    }
  }

  //state发生变化时会回调该方法,可以是class
  //也可以是InheritedWidget,即其实际所属的组件(上面那个组件)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  //父组件发生变化时，会调用该方法，随后调用 build 方法重新渲染，用的少
  @override
  void didUpdateWidget(covariant VideoPlaylist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && playFiles.length < 1) {
      _initData();
    }
  }

  //组件被从父节点移除时回调的方法，如果没插入到其他节点会随后调用dispose完全释放
  //如果该组件被移除，但是仍然被组件关联，则不会随后释放并调用dispose
  @override
  void deactivate() {
    super.deactivate();
  }

  //完全释放该组件时调用,不建议做本组件的内存操作，可以移除其他组件或者保存的内容
  @override
  void dispose() {
    super.dispose();
  }

  //debug情况下调用，每次热重载都会回调
  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 30,
            width: 200,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            color: Colors.black87,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                dropdownWidth: 220,
                onMenuStateChange: (isOpen) {
                  updatePlaylistFiles();
                },
                hint:
                    Text('选择播放列表', style: TextStyle(color: Colors.purple[100])),
                value: selectedFilename,
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  onPlayFileChange(value);
                },
                itemHeight: 30,
                dropdownMaxHeight: getDeviceHeight(context) - 50.0,
                //on: updatePlaylistFiles,
                style: const TextStyle(color: Colors.white),
                items: playFiles.map<DropdownMenuItem<String>>((v) {
                  return DropdownMenuItem<String>(
                    value: jsonEncode(v),
                    child: Wrap(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 4, 0),
                        child: Icon(
                          v['url'] != null
                              ? Icons.insert_link_outlined
                              : Icons.file_present_outlined,
                          size: 12,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          v['name'],
                          //overflow: TextOverflow.ellipsis,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      )
                    ]),
                  );
                }).toList(),
              ),
            )),
        Expanded(
            child: Container(
          width: 200,
          child: playlist.length > 0
              ? PlGroupPanel(
                  data: playlist,
                  onUrlTap: (e) {
                    widget.onUrlTap(e);
                  },
                )
              : (widget.visible && loading
                  ? Spinning()
                  : SizedBox(
                      width: 0,
                    )),
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
              color: Colors.black87,
              border:
                  Border(left: BorderSide(color: Colors.white54, width: 1))),
        ))
      ],
    );
  }
}
