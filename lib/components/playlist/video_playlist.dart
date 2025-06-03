/*
 * @Author: Moxx
 * @Date: 2022-09-02 16:32:16
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-10 00:55:23
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:uni_links/uni_links.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/player/settings/play_file_setting_dialog.dart';
import 'package:vvibe/components/playlist/playlist_widgets.dart';
import 'package:vvibe/components/spinning.dart';
import 'package:vvibe/models/playlist_info.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/color_util.dart';
import 'package:vvibe/utils/utils.dart';

class VideoPlaylist extends StatefulWidget {
  const VideoPlaylist({
    Key? key,
    required this.onUrlTap,
    this.visible = false,
  }) : super(key: key);
  final void Function(PlayListItem item,
      {Map<String, dynamic>? subConfig, PlayListInfo? playlistInfo}) onUrlTap;
  final bool visible;
  @override
  _VideoPlaylistState createState() => _VideoPlaylistState();
}

class _VideoPlaylistState extends State<VideoPlaylist> {
  // List<PlayListItem> playlist = [];
  PlayListInfo? playlistInfo;
  List<Map<String, dynamic>>? playFiles = []; //本地、订阅列表
  String? selectedFileId = null;
  Map<String, dynamic>? selectedFile = null;
  bool loading = true;
  PlayListItem? currentPlayUrl;
  StreamSubscription? _unilinksub;
  Uri? initialLinkUri;
  Uri? latestLinkUri;
  Object? err;
  //初始化状态时使用，我们可以在这里设置state状态
  //也可以请求网络数据后更新组件状态
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final Map<String, List<dynamic>> configs =
        await PlaylistUtil().getSubConfigs();
    final urls = (configs['urls'] ?? []);
    final _files = (configs['files'] ?? []);

    urls.addAll(_files);
    setState(() => playFiles = urls as List<Map<String, dynamic>>);
    final lastSelect = await LoacalStorage().getJSON(LAST_PLAYLIST_FILE_OR_SUB);
    if (lastSelect == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    if (plFileExists(urls as List<Map<String, dynamic>>, lastSelect)) {
      onPlayFileChange(lastSelect['id'] ?? '');
    }
    //初始化订阅url的列表

    setState(() {
      loading = false;
    });
    watchPlaylistDir();
    handleIncomingLinks();
    handleInitialUri();
  }

  void handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _unilinksub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          latestLinkUri = uri;
          err = null;
        });
      }, onError: (Object err) {
        print('got err: $err');

        latestLinkUri = null;
        if (err is FormatException) {
          setState(() {
            err = err;
          });
        } else {
          setState(() {
            err = Null;
          });
        }
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).

    try {
      final uri = await getInitialUri();

      print('got initial uri: $uri');
      if (!mounted) return;
      setState(() {
        initialLinkUri = uri;
      });
      initPlaylistByUnilink(uri);
    } on PlatformException {
      // Platform messages may fail but we ignore the exception
      print('falied to get initial uri');
    } on FormatException catch (e) {
      print('malformed initial uri: $e');
      err = e;
    }
  }

// 根据 unilink初始化播放列表文件
  void initPlaylistByUnilink(Uri? uri) {}

  bool plFileExists(List<Map<String, dynamic>> list, Map<String, dynamic>? pl) {
    return pl != null && list.any((e) => e['id'] == pl['id']);
  }

  List<PlayListItem> get playlist {
    final channels = playlistInfo?.channels ?? [];
    final last = channels.where((e) => !blackGroups.contains(e.group)).toList();
    return last;
  }

  Map<String, dynamic> get currentSubFileConf {
    try {
      if (selectedFile?['type'] != 'file') {
        return selectedFile ?? {};
      }
      final map = selectedFile ?? {};
      final String bg = map['blackGroups'] ?? '';
      final bgs = bg.split(',').map((e) => e.trim()).toList();
      final plInfoJson = playlistInfo?.toJson() ?? {};
      return {...map, ...plInfoJson};
    } catch (e) {
      print('$e  currentSubFileConf errors');
      return {};
    }
  }

  List<String> get blackGroups {
    try {
      final map = selectedFile ?? {};
      final String bg = map['blackGroups'] ?? '';
      final bgs = bg.split(',').map((e) => e.trim()).toList();
      return bgs;
    } catch (e) {
      print('$e  bgs errors');
      return [];
    }
  }

  void updatePlaylistFiles() async {
    try {
      final Map<String, dynamic> configs = await PlaylistUtil().getSubConfigs();
      final urls = (configs['urls'] ?? []);
      final List<Map<String, dynamic>> files = (configs['files'] ?? []);
      urls.addAll(files);

      setState(() {
        playFiles = urls;
        /* if (!plFileExists(selectedFilename != null
            ? jsonDecode(selectedFilename ?? '{}')
            : null)) {
          selectedFilename = null;
        } */
      });
    } catch (e) {
      print('$e  updatePlaylistFiles errors');
    }
  }

  Map<String, dynamic> pickPlFile(String? id) {
    try {
      if (id == null) return {};
      final file = playFiles?.where((e) => e['id'] == id).toList().first;
      return file ?? {};
    } catch (e) {
      print('$e  pickPlFile errors');
      return {};
    }
  }

//切换播放文件或订阅
  void onPlayFileChange(String? id, {bool? forceRefresh = false}) async {
    final Map<String, dynamic> file = pickPlFile(id);
    setState(() {
      playlistInfo = null;
      selectedFile = file;
      selectedFileId = id;
    });

    if (id == null) return;
    setState(() {
      loading = true;
    });
    final map = file;

    LoacalStorage().setJSON(LAST_PLAYLIST_FILE_OR_SUB, map);
    PlayListInfo? data = await PlaylistUtil()
        .parsePlayListsDrill(map['url'] ?? map['name'], config: map);
    if (!mounted) return;
    setState(() {
      playlistInfo = data;
      loading = false;
    });

    LoacalStorage().setJSON(LAST_PLAYLIST_DATA, data);
  }

  //菜单点击
  void _onMenuItemTap(
      BuildContext context, MenuItem item, Map<String, dynamic> file) {
    final value = item.title;

    switch (value) {
      case '编辑文件':
        PlaylistUtil().launchFile(file['name']);
        break;

      case '播放设置':
        showDialog(
            context: context,
            builder: (context) {
              return PlayFileSettingDialog(
                file: file,
              );
            });
        break;
      case '强制刷新':
        forceRefreshPlaylist(file['id']);
        break;
      default:
    }
  }

  forceRefreshPlaylist([String? id]) {
    onPlayFileChange(id ?? selectedFileId, forceRefresh: true);
  }

  _onUrlTap(PlayListItem e) {
    setState(() {
      currentPlayUrl = e;
    });
    widget.onUrlTap(e,
        playlistInfo: playlistInfo, subConfig: selectedFile ?? {});
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
    if (widget.visible && playFiles != null && playFiles!.length < 1) {
      _initData();
    }
  }

  void watchPlaylistDir() async {
    final dir = await PlaylistUtil().getPlayListDir();
    dir.watch(events: FileSystemEvent.all).listen((FileSystemEvent event) {
      print('playlist dir change event: ${event.type}');
      updatePlaylistFiles();
    });
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
    _unilinksub?.cancel();
  }

  //debug情况下调用，每次热重载都会回调
  @override
  void reassemble() {
    super.reassemble();
  }

  Widget MenuItemRow(Map<String, dynamic> v) {
    return Wrap(children: [
      Padding(
        padding: const EdgeInsets.only(top: 3, right: 4),
        child: Icon(
          v['url'] != null ? Icons.link_outlined : Icons.file_present_outlined,
          size: 12,
          color: Colors.white,
        ),
      ),
      SizedBox(
        width: 170,
        child: Text(
          v['name'],
          //overflow: TextOverflow.ellipsis,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 30,
            width: PLAYLIST_BAR_WIDTH,
            padding: const EdgeInsets.fromLTRB(5, 1, 5, 0),
            color: Colors.white12,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                dropdownStyleData: DropdownStyleData(
                  width: 220,
                  decoration: BoxDecoration(
                      color: ColorUtil.fromHex('#3D3D3D'),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white24,
                          spreadRadius: 0,
                          blurRadius: 10,
                        ),
                      ]),
                ),
                onMenuStateChange: (isOpen) {
                  updatePlaylistFiles();
                },
                value: selectedFileId,
                hint: Text(
                    playFiles != null && playFiles!.length > 0
                        ? '选择播放列表'
                        : '播放列表为空',
                    style: TextStyle(
                        color: playFiles != null && playFiles!.length > 0
                            ? Colors.white
                            : Colors.redAccent)),
                iconStyleData:
                    IconStyleData(icon: const Icon(Icons.keyboard_arrow_down)),
                onChanged: (String? value) {
                  onPlayFileChange(value);
                },
                menuItemStyleData: MenuItemStyleData(height: 20),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                items: playFiles?.map<DropdownMenuItem<String>>((obj) {
                  return DropdownMenuItem<String>(
                      value: obj['id'] ?? jsonEncode(obj),
                      key: ObjectKey(obj),
                      child: ContextMenuRegion(
                        onItemSelected: (item) {
                          _onMenuItemTap(context, item, obj);
                        },
                        menuItems: obj['url'] == null
                            ? [
                                MenuItem(title: '编辑文件'),
                                MenuItem(title: '播放设置'),
                                MenuItem(title: '强制刷新'),
                              ]
                            : [MenuItem(title: '强制刷新')],
                        child: MenuItemRow(obj),
                      ));
                }).toList(),
              ),
            )),
        Expanded(
            child: Container(
          width: PLAYLIST_BAR_WIDTH,
          child: playlist.length > 0
              ? PlGroupPanel(
                  data: playlist,
                  currentSubConfig: currentSubFileConf,
                  onUrlTap: _onUrlTap,
                  forceRefreshPlaylist: forceRefreshPlaylist,
                )
              : (widget.visible && loading
                  ? Spinning()
                  : SizedBox(
                      width: 0,
                    )),
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
              color: Colors.white10,
              border:
                  Border(left: BorderSide(color: Colors.white12, width: 1))),
        ))
      ],
    );
  }
}
