/*
 * @Author: Moxx 
 * @Date: 2022-09-03 16:32:43 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-10 00:09:36
 */

import 'package:flutter/material.dart';

import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/utils.dart';
import 'package:extended_list/extended_list.dart';

//播放列表的分组折叠面板
class PlGroupPanel extends StatefulWidget {
  const PlGroupPanel(
      {Key? key,
      required this.data,
      this.expansionCallback,
      required this.onUrlTap})
      : super(key: key);
  final List<PlayListItem> data;
  final ExpansionPanelCallback? expansionCallback;
  final void Function(PlayListItem item) onUrlTap;
  @override
  State<PlGroupPanel> createState() => _PlGroupPanelState();
}

class _PlGroupPanelState extends State<PlGroupPanel> {
  Map<String, bool> expanded = new Map();
  String expandKey = '';
  String searchKey = '';
  List<PlayListItem> playlist = [];
  void toggleExpand(int panelIndex, bool isExpanded, String key) {
    setState(() {
      //  expanded[key] = !isExpanded;
      expandKey = isExpanded ? '' : key;
    });
  }

  List<PlayListItem> filterPlaylist(String keyword, List<PlayListItem> list) {
    return list
        .where((PlayListItem element) =>
            element.name != null &&
            expandKey == element.group &&
            element.name!.contains(keyword))
        .toList();
  }

  void onSearch(String keyword) {
    final newList = filterPlaylist(keyword, widget.data);
    print('newList ${newList.length}');
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
                        hoverColor: Colors.purple[100],
                        title: Text(key),
                        subtitle: isExpanded
                            ? TextField(
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    hintText: '搜索',
                                    hintStyle:
                                        TextStyle(color: Colors.white30)),
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                                onChanged: (v) => onSearch(v),
                                onSubmitted: ((value) => onSearch(value)),
                              )
                            : SizedBox(height: 0, width: 0),
                        textColor: isExpanded ? Colors.white70 : Colors.white,
                      ),
                      height: isExpanded ? 60 : 20,
                    );
                  },
                  body: expandKey == key
                      ? PlUrlListView(data: urlList, onUrlTap: widget.onUrlTap)
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
  const PlUrlListView({Key? key, required this.data, required this.onUrlTap})
      : super(key: key);
  final List<PlayListItem> data;
  final void Function(PlayListItem item) onUrlTap;

  @override
  _PlUrlListViewState createState() => _PlUrlListViewState();
}

class _PlUrlListViewState extends State<PlUrlListView> {
  PlayListItem? selectedItem;
  void selectUrl(PlayListItem e) {
    if (e.url == selectedItem?.url) return;
    widget.onUrlTap(e);
    setState(() {
      selectedItem = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: getDeviceHeight(context) - 130,
        child: ExtendedListView.builder(
          itemBuilder: (context, index) {
            if (widget.data.length < index + 1) return SizedBox();
            final e = widget.data[index];
            return Container(
              height: 28,
              color: Colors.black12,
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    selectUrl(e);
                  },
                  child: SizedBox(
                    child: Tooltip(
                      child: Text(
                        e.name?.trim() ?? '未知名称',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: e.url == selectedItem?.url
                              ? FontWeight.bold
                              : FontWeight.w300,
                          color: e.url == selectedItem?.url
                              ? Colors.purple
                              : Colors.white,
                        ),
                      ),
                      message: e.name,
                      waitDuration: Duration(seconds: 1),
                    ),
                    width: 200,
                  )),
            );
          },
          extendedListDelegate: ExtendedListDelegate(

              /// follow max child trailing layout offset and layout with full cross axis extend
              /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
              /// with full cross axis extend
              //  LastChildLayoutType.fullCrossAxisExtend,

              /// as foot at trailing and layout with full cross axis extend
              /// show no more item at trailing when children are not full of viewport
              /// if children is full of viewport, it's the same as fullCrossAxisExtend
              //  LastChildLayoutType.foot,
              lastChildLayoutTypeBuilder: (int index) =>
                  index == widget.data.length
                      ? LastChildLayoutType.foot
                      : LastChildLayoutType.none,
              collectGarbage: (List<int> garbages) {
                //   debugPrint('collect garbage : $garbages');
              },
              viewportBuilder: (int firstIndex, int lastIndex) {
                //   debugPrint('viewport : [$firstIndex,$lastIndex]');
              }),
          itemCount: widget.data.length + 1,
        ));
  }
}
