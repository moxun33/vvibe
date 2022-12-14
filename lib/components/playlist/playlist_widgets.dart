/*
 * @Author: Moxx 
 * @Date: 2022-09-03 16:32:43 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-10 00:09:36
 */

import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/components.dart';
//import 'package:extended_list/extended_list.dart';

import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/utils.dart';

//播放列表的分组折叠面板
class PlGroupPanel extends StatefulWidget {
  const PlGroupPanel(
      {Key? key,
      required this.data,
      //this.expansionCallback,
      required this.forceRefreshPlaylist,
      required this.onUrlTap})
      : super(key: key);
  final List<PlayListItem> data;
  // final ExpansionPanelCallback? expansionCallback;
  final void Function(PlayListItem item) onUrlTap;
  final void Function() forceRefreshPlaylist;
  @override
  State<PlGroupPanel> createState() => _PlGroupPanelState();
}

class _PlGroupPanelState extends State<PlGroupPanel> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, bool> expanded = new Map();
  String expandKey = '';
  String searchKey = '';
  List<PlayListItem> playlist = [];
  void toggleExpand(int panelIndex, bool isExpanded, String key) {
    setState(() {
      //  expanded[key] = !isExpanded;
      expandKey = isExpanded ? '' : key;
    });
    if (!isExpanded) {
      _searchController.clear();
    }
  }

  List<PlayListItem> filterPlaylist(String keyword, List<PlayListItem> list) {
    if (keyword.isEmpty) return widget.data;
    return list.where((PlayListItem element) {
      return element.name != null &&
          expandKey == element.group &&
          element.name!.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  void onSearch(String keyword) {
    final newList = filterPlaylist(keyword, widget.data);
    if (newList.length < 1) {
      EasyLoading.showInfo('没有搜索结果');
      return;
    }
    setState(() {
      searchKey = keyword;
      playlist = newList;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      playlist = widget.data;
    });
  }

  @override
  void didUpdateWidget(covariant PlGroupPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // debugPrint('PlGroupPanel didUpdateWidget ${widget.data.length}');

    setState(() {
      playlist = searchKey.isNotEmpty
          ? filterPlaylist(searchKey, widget.data)
          : widget.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = PlaylistUtil().getPlaylistgroups(playlist),
        keyList = groups.keys.toList();
    return SingleChildScrollView(
        child: ExpansionPanelList(
            expandedHeaderPadding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            expansionCallback: (i, expanded) =>
                toggleExpand(i, expanded, keyList[i]),
            children: keyList.map<ExpansionPanel>((String key) {
              final urlList = groups[key] ?? [];
              return ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Colors.white10,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      child: ListTile(
                        title: Tooltip(
                          child: Text(
                            key,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                          ),
                          message: key,
                          waitDuration: const Duration(seconds: 1),
                        ),
                        subtitle: isExpanded
                            ? TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                    hintText: '搜索',
                                    hintStyle:
                                        TextStyle(color: Colors.white30)),
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                                onSubmitted: ((value) {
                                  onSearch(value);
                                }),
                              )
                            : SizedBox(height: 0, width: 0),
                        textColor: isExpanded ? Colors.white70 : Colors.white,
                      ),
                      height: isExpanded ? 60 : 20,
                    );
                  },
                  body: expandKey == key
                      ? PlUrlListView(
                          data: urlList,
                          onUrlTap: widget.onUrlTap,
                          forceRefreshPlaylist: widget.forceRefreshPlaylist)
                      : SizedBox(
                          height: 0,
                          width: 0,
                        ),
                  isExpanded: expandKey == key // expanded[key] ?? false,
                  );
            }).toList()));
  }
}

//播放列表的地址列表
class PlUrlListView extends StatefulWidget {
  const PlUrlListView(
      {Key? key,
      required this.data,
      required this.onUrlTap,
      required this.forceRefreshPlaylist})
      : super(key: key);
  final List<PlayListItem> data;
  final void Function(PlayListItem item) onUrlTap;
  final void Function() forceRefreshPlaylist;
  @override
  _PlUrlListViewState createState() => _PlUrlListViewState();
}

class _PlUrlListViewState extends State<PlUrlListView> {
  PlayListItem? selectedItem;

  void selectUrl(PlayListItem e) {
    if (!(e.url != null && e.url!.isNotEmpty)) {
      EasyLoading.showError('缺少播放地址或地址错误');
      return;
    }
    if (e.url == selectedItem?.url) return;
    widget.onUrlTap(e);
    setState(() {
      selectedItem = e;
    });
  }

  Widget _buildList() {
    if (widget.data.length != 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: widget.data.length,
          itemExtent: 25.0,
          cacheExtent: getDeviceHeight(context) - 50.0,
          itemBuilder: (context, index) {
            final e = widget.data[index];
            return PlUrlTile(
                index: index,
                onSelectUrl: selectUrl,
                selectedItem: selectedItem,
                url: e,
                key: ObjectKey(e),
                forceRefreshPlaylist: widget.forceRefreshPlaylist);
          });
    } else {
      return Spinning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: getDeviceHeight(context) - 50,
        color: Colors.white10,
        child: _buildList());
  }
}

//播放列表标题
class PlUrlTile extends StatefulWidget {
  const PlUrlTile(
      {Key? key,
      required this.url,
      required this.index,
      required this.onSelectUrl,
      required this.forceRefreshPlaylist,
      this.selectedItem})
      : super(key: key);
  final PlayListItem url;
  final int index;
  final void Function(PlayListItem url) onSelectUrl;
  final PlayListItem? selectedItem;
  final void Function() forceRefreshPlaylist;

  @override
  _PlUrlTileState createState() => _PlUrlTileState();
}

class _PlUrlTileState extends State<PlUrlTile>
    with AutomaticKeepAliveClientMixin {
  PlayListItem? urlItem;
  int? urlStatus;
  bool loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setState(() {
      urlItem = widget.url;
    });

    _checkUrlAccessible(widget.url);
  }

  void _selectUrl(PlayListItem url) {
    widget.onSelectUrl(url);
  }

  //菜单点击
  void _onMenuItemTap(BuildContext context, MenuItem item, PlayListItem url) {
    final value = item.title;

    switch (value) {
      case '复制链接':
        Clipboard.setData(ClipboardData(text: url.url));
        EasyLoading.showSuccess('复制成功');
        break;
      case '强制刷新列表':
        widget.forceRefreshPlaylist();
        break;
      default:
    }
  }

//检查url访问性
  void _checkUrlAccessible(PlayListItem url) async {
    if (urlStatus != null) return;
    if (url.url == null) {
      setState(() {
        urlStatus = 204;
        loading = false;
      });
      return;
    }

    if (!url.url!.startsWith('http')) {
      setState(() {
        urlStatus = 204;
        loading = false;
      });
      return;
    }

    final status = await PlaylistUtil().checkUrlAccessible(url.url!);
    debugPrint(
        '$urlStatus 检测url ${widget.index} ${url.name} ${url.url!} 响应状态$status');
    if (mounted) {
      setState(() {
        loading = false;
        urlStatus = status;
      });
    }
  }

  Widget _getIcon(int? status) {
    switch (status) {
      case 200:
        return Icon(
          Icons.check,
          size: 10,
          color: Colors.green,
        );
      case 204:
        return SizedBox(
          width: 0,
        );
      case 504:
        return Tooltip(
          child: Icon(
            Icons.timer_off_outlined,
            size: 10,
            color: Colors.amber[900],
          ),
          message: '超时',
        );
      case 403:
        return Tooltip(
          child: Icon(
            Icons.not_accessible_outlined,
            size: 10,
            color: Colors.pink,
          ),
          message: '403禁止',
        );
      case 500:
      case 400:
        return Tooltip(
          child: Icon(
            Icons.close,
            size: 10,
            color: Colors.red,
          ),
          message: '不可用',
        );
      case 404:
        return Tooltip(
          child: Icon(
            Icons.question_mark_outlined,
            size: 10,
            color: Colors.orange,
          ),
          message: '链接不存在',
        );
      default:
        return loading
            ? SmallSpinning()
            : SizedBox(
                width: 0,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final e = urlItem;
    if (e == null) return SizedBox();
    return Container(
        height: 26,
        color: Colors.black12,
        child: ContextMenuRegion(
          onItemSelected: (item) {
            _onMenuItemTap(context, item, e);
          },
          menuItems: [
            MenuItem(title: '复制链接'),
            MenuItem(title: '强制刷新列表'),
          ],
          child: TextButton(
            onPressed: () {
              _selectUrl(e);
            },
            child: Tooltip(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2.0,
                children: [
                  _getIcon(urlStatus),
                  SizedBox(
                    width: PLAYLIST_BAR_WIDTH - 30,
                    child: Text(
                      e.name?.trim() ?? '未知名称',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: e.url == widget.selectedItem?.url
                            ? FontWeight.bold
                            : FontWeight.w300,
                        color: e.url == widget.selectedItem?.url
                            ? Colors.purple
                            : Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              message: e.name,
              waitDuration: const Duration(seconds: 1),
            ),
          ),
        ));
  }
}
