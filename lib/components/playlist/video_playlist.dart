/*
 * @Author: Moxx 
 * @Date: 2022-09-02 16:32:16 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-03 19:46:10
 */
import 'package:flutter/material.dart';
import 'package:vvibe/components/playlist/playlist_widgets.dart';
import 'package:vvibe/models/playlist_item.dart';

import '../../utils/playlist/playlist_util.dart';

class VideoPlaylist extends StatefulWidget {
  const VideoPlaylist({Key? key, required this.onUrlTap}) : super(key: key);
  final void Function(PlayListItem item) onUrlTap;

  @override
  _VideoPlaylistState createState() => _VideoPlaylistState();
}

class _VideoPlaylistState extends State<VideoPlaylist> {
  List<PlayListItem> playlist = [];

  //初始化状态时使用，我们可以在这里设置state状态
  //也可以请求网络数据后更新组件状态
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PlaylistUtil().parsePlaylistFile("playlist/bilibili.m3u").then((value) {
      setState(() => playlist = value);
    });
  }

  //state发生变化时会回调该方法,可以是class
  //也可以是InheritedWidget,即其实际所属的组件(上面那个组件)
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  //父组件发生变化时，会调用该方法，随后调用 build 方法重新渲染，用的少
  @override
  void didUpdateWidget(covariant VideoPlaylist oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  //组件被从父节点移除时回调的方法，如果没插入到其他节点会随后调用dispose完全释放
  //如果该组件被移除，但是仍然被组件关联，则不会随后释放并调用dispose
  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  //完全释放该组件时调用,不建议做本组件的内存操作，可以移除其他组件或者保存的内容
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  //debug情况下调用，每次热重载都会回调
  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PlGroupPanel(
        data: playlist,
        onUrlTap: (e) {
          widget.onUrlTap(e);
        },
      ),
      height: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
          color: Colors.black87,
          border: Border(left: BorderSide(color: Colors.white54, width: 1))),
    );
  }
}
