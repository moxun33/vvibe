/*
 * @Author: Moxx 
 * @Date: 2022-09-03 16:32:43 
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-08 11:47:00
 */

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/utils.dart';

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
  void toggleExpand(int panelIndex, bool isExpanded, String key) {
    setState(() {
      //  expanded[key] = !isExpanded;
      expandKey = isExpanded ? '' : key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = PlaylistUtil().getPlaylistgroups(widget.data),
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
                    return ListTile(
                      isThreeLine: false,
                      title: Text(key),
                      textColor: isExpanded ? Colors.white70 : Colors.white,
                    );
                  },
                  body: PlUrlListView(data: urlList, onUrlTap: widget.onUrlTap),
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
        child: ListView(
      shrinkWrap: true, // use this

      children: widget.data
          .map((e) => Container(
                height: 30,
                color: Colors.black12,
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () {
                      selectUrl(e);
                    },
                    child: SizedBox(
                      child: Text(
                        e.name?.trim() ?? '未知名称',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                      width: 200,
                    )),
              ))
          .toList(),
    ));
  }
}
