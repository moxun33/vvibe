/*
 * @Author: Moxx
 * @Date: 2022-09-03 16:32:43
 * @Last Modified by: Moxx
 * @Last Modified time: 2022-09-10 00:09:36
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/components.dart';
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/utils.dart';

//播放列表的分组折叠面板
class PlGroupPanel extends StatefulWidget {
  const PlGroupPanel(
      {Key? key,
      required this.data,
      //this.expansionCallback,
      required this.forceRefreshPlaylist,
      required this.currentSubConfig,
      required this.onUrlTap})
      : super(key: key);
  final List<PlayListItem> data;
  final Map<String, dynamic> currentSubConfig;
  // final ExpansionPanelCallback? expansionCallback;
  final void Function(PlayListItem item) onUrlTap;
  final void Function() forceRefreshPlaylist;
  @override
  State<PlGroupPanel> createState() => _PlGroupPanelState();
}

class _PlGroupPanelState extends State<PlGroupPanel> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, bool> expanded = new Map();
  Map<String, dynamic> playerSettings = new Map();
  String expandKey = '';
  String searchKey = '';
  List<PlayListItem> playlist = [];
  void toggleExpand(int panelIndex, bool isExpanded, String key) {
    setState(() {
      //  expanded[key] = !isExpanded;
      expandKey = !isExpanded ? '' : key;
    });
    if (!isExpanded) {
      _searchController.clear();
    }
  }

  List<PlayListItem> filterPlaylist(String keyword, List<PlayListItem> list) {
    if (keyword.isEmpty) return widget.data;
    return list.where((PlayListItem element) {
      return expandKey == element.group &&
          element.name.toLowerCase().contains(keyword.toLowerCase());
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
    _init();
  }

  _init() async {
    final plSettings = await LoacalStorage().getJSON(PLAYER_SETTINGS);
    setState(() {
      if (plSettings != null) {
        playerSettings = plSettings as Map<String, dynamic>;
      }
      playlist = widget.data;
    });
  }

  @override
  void didUpdateWidget(covariant PlGroupPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // MyLogger.info('PlGroupPanel didUpdateWidget ${widget.data.length}');

    setState(() {
      playlist = searchKey.isNotEmpty
          ? filterPlaylist(searchKey, widget.data)
          : widget.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = PlaylistUtil().getPlaylistgroups(
          playlist,
        ),
        keyList = groups.keys.toList();
    return SingleChildScrollView(
        child: ExpansionPanelList(
            expandedHeaderPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                        dense: false,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
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
                                  // onSearch(value);
                                }),
                                onChanged: ((value) {
                                  onSearch(value);
                                }),
                              )
                            : SizedBox(height: 0, width: 0),
                        textColor: Colors.white,
                      ),
                      height: isExpanded ? 70 : 20,
                    );
                  },
                  body: expandKey == key
                      ? PlUrlListView(
                          playerSetting: playerSettings,
                          currentSubConfig: widget.currentSubConfig,
                          data: urlList,
                          onUrlTap: widget.onUrlTap,
                          forceRefreshPlaylist: widget.forceRefreshPlaylist)
                      : SizedBox(height: 0, width: 0),
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
      required this.playerSetting,
      required this.currentSubConfig,
      required this.onUrlTap,
      required this.forceRefreshPlaylist})
      : super(key: key);
  final List<PlayListItem> data;
  final Map<String, dynamic> playerSetting;
  final Map<String, dynamic> currentSubConfig;
  final void Function(PlayListItem item) onUrlTap;
  final void Function() forceRefreshPlaylist;
  @override
  _PlUrlListViewState createState() => _PlUrlListViewState();
}

class _PlUrlListViewState extends State<PlUrlListView> {
  PlayListItem? selectedItem;
  @override
  void initState() {
    super.initState();
    _initCacheUrl();
  }

  void _initCacheUrl() async {
    final lastUrl = await LoacalStorage().getJSON(LAST_PLAY_VIDEO_URL);
    if (lastUrl == null) return;
    final urlItem = PlayListItem.fromJson(lastUrl);
    setState(() {
      selectedItem = urlItem;
    });
  }

  void onSelectUrl(PlayListItem e) {
    if ((e.url.isEmpty)) {
      EasyLoading.showError('缺少播放地址或地址错误');
      return;
    }
    widget.onUrlTap(e);
    setState(() {
      selectedItem = e;
    });
  }

  double get maxHeight {
    return getDeviceHeight(context) - 50;
  }

  bool get _showLogo {
    final singleSet =
        PlaylistUtil().isBoolValid(widget.currentSubConfig['showLogo']);
    if (!singleSet && widget.currentSubConfig['type'] != 'file')
      return PlaylistUtil().isBoolValid(widget.playerSetting['showLogo']);
    return singleSet;
  }

  bool get _checkAlive {
    final singleSet = PlaylistUtil()
        .isBoolValid(widget.currentSubConfig['checkAlive'], false);
    if (!singleSet)
      return PlaylistUtil()
          .isBoolValid(widget.playerSetting['checkAlive'], false);
    return singleSet;
  }

  Widget _buildList() {
    if (widget.data.length != 0) {
      final h = widget.data.length * 20.0;
      return ListView.builder(
          shrinkWrap: false,
          itemCount: widget.data.length,
          itemExtent: 20.0,
          cacheExtent: h > maxHeight ? maxHeight : h,
          itemBuilder: (context, index) {
            final e = widget.data[index];
            return PlUrlTile(
                showLogo: _showLogo,
                checkAlive: _checkAlive,
                index: index,
                onSelectUrl: onSelectUrl,
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
    final h = widget.data.length * 20.0 + 2;
    return Container(
        height: h > maxHeight ? maxHeight : h,
        color: Colors.white10,
        child: _buildList());
  }
}

//播放列表标题
class PlUrlTile extends StatefulWidget {
  const PlUrlTile(
      {Key? key,
      required this.url,
      required this.checkAlive,
      required this.showLogo,
      required this.index,
      required this.onSelectUrl,
      required this.forceRefreshPlaylist,
      this.selectedItem})
      : super(key: key);
  final PlayListItem url;
  final int index;
  final bool checkAlive;
  final bool showLogo;
  final void Function(PlayListItem url) onSelectUrl;
  final PlayListItem? selectedItem;
  final void Function() forceRefreshPlaylist;

  @override
  _PlUrlTileState createState() => _PlUrlTileState();
}

class _PlUrlTileState extends State<PlUrlTile>
    with AutomaticKeepAliveClientMixin {
  //PlayListItem? urlItem;
  int? urlStatus;
  bool loading = true;
  CancelToken _cancelToken = CancelToken();
  PingResponse? pingRes;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    /* setState(() {
      urlItem = widget.url;
    }); */

    if (widget.checkAlive) _checkUrlAccessible();
  }

  void _selectUrl(PlayListItem url) {
    widget.onSelectUrl(url);
  }

  //菜单点击
  void _onMenuItemTap(
    BuildContext context,
    MenuItem item,
  ) {
    final value = item.title;

    switch (value) {
      case '复制链接':
        Clipboard.setData(ClipboardData(text: widget.url.url));
        EasyLoading.showSuccess('复制成功');
        break;
      case '强制刷新列表':
        widget.forceRefreshPlaylist();
        break;

      case '用vlc打开':
        launchUrlString('vlc://${widget.url.url}');
        break;
      default:
    }
  }

//检查url访问性
  void _checkUrlAccessible() async {
    final url = widget.url;
    if (urlStatus != null) return;

    final res = await PlaylistUtil().checkUrlAccessible(url.url, _cancelToken);

    MyLogger.info(
        '$urlStatus 检测url ${widget.index} ${url.name} ${url.url} 响应 $res');
    if (mounted) {
      setState(() {
        loading = false;
        urlStatus = res['status'];
        pingRes = res['ping'];
      });
    }
  }

  Color _getPingColor(Duration? time) {
    final ms = time?.inMilliseconds ?? 0;
    if (ms > 300 && ms <= 500) {
      return Colors.cyan;
    }
    if (ms > 500 && ms <= 1000) {
      return Colors.blue;
    }
    if (ms > 1000) {
      return Colors.red;
    }
    return Colors.green;
  }

  Widget _getIcon(int? status) {
    final pingTime = pingRes?.time?.inMilliseconds ?? 0;
    final okIcon = Icon(
      Icons.check,
      size: 10,
      color: _getPingColor(pingRes?.time),
    );
    switch (status) {
      case 200:
      case 204:
      case 206:
        return Tooltip(child: okIcon, message: '${pingTime}ms');

      case 504:
        return Tooltip(
          child: Icon(
            Icons.timer_off_outlined,
            size: 8,
            color: Colors.amber[900],
          ),
          message: '超时',
        );
      case 401:
      case 403:
        return Tooltip(
          child: Icon(
            Icons.not_accessible_outlined,
            size: 8,
            color: Colors.pink,
          ),
          message: '禁止访问 ${pingTime}ms',
        );
      case 400:
        return Tooltip(
          child: Icon(
            Icons.airplanemode_active_outlined,
            size: 8,
            color: Colors.lightGreen[200],
          ),
          message: '无法检测 ${pingTime}ms',
        );
      case 405:
      case 422:
        return Tooltip(
          child: pingRes?.time != null
              ? okIcon
              : Icon(
                  Icons.unpublished_rounded,
                  size: 8,
                  color: Colors.yellow[200],
                ),
          message: '拒绝连接 ${pingTime}ms',
        );
      case 500:
      case 502:
        return Tooltip(
          child: Icon(
            Icons.close,
            size: 8,
            color: Colors.red,
          ),
          message: '不可用 ${pingTime}ms',
        );
      case 503:
        return Tooltip(
          child: Icon(
            Icons.linear_scale_rounded,
            size: 8,
            color: Colors.cyan[200],
          ),
          message: '限制连接 ${pingTime}ms',
        );
      case 404:
        return Tooltip(
          child: Icon(
            Icons.question_mark_outlined,
            size: 8,
            color: Colors.orange,
          ),
          message: '不存在 ${pingTime}ms',
        );
      default:
        return loading
            ? SmallSpinning()
            : Tooltip(
                child: Icon(
                  Icons.notification_important_outlined,
                  size: 8,
                  color: Colors.pink,
                ),
                message: '未知 ${pingTime}ms',
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final e = widget.url;
    //  if (e == null) return SizedBox();
    return Container(
        height: 22,
        color: Colors.black12,
        child: ContextMenuRegion(
          onItemSelected: (item) {
            _onMenuItemTap(context, item);
          },
          menuItems: [
            MenuItem(title: '复制链接'),
            MenuItem(title: '强制刷新列表'),
            MenuItem(title: '用vlc打开'),
          ],
          child: TextButton(
            onPressed: () {
              _selectUrl(e);
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 1.0,
              children: [
                widget.checkAlive
                    ? _getIcon(urlStatus)
                    : e.tvgLogo != null && widget.showLogo
                        ? SizedBox(
                            width: 16,
                            child: CachedNetworkImage(
                              fit: BoxFit.contain,
                              imageUrl: widget.url.tvgLogo!,
                              errorWidget: (context, url, error) => Icon(
                                Icons.movie_creation_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          )
                        : Icon(
                            Icons.movie_creation_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                SizedBox(
                    width: PLAYLIST_BAR_WIDTH - 42,
                    child: Tooltip(
                      child: Text(
                        e.name.trim().isNotEmpty ? e.name.trim() : '未知名称',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: e.url == widget.selectedItem?.url
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: e.url == widget.selectedItem?.url
                              ? AppColors.primaryColor
                              : Colors.white,
                        ),
                      ),
                      message: e.name,
                      waitDuration: const Duration(seconds: 1),
                    ))
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _cancelToken.cancel("Request cancelled");
    super.dispose();
  }
}

Widget DanmakuRender(LiveDanmakuItem? data,
    {double fontSize = 20.0, isHackchat = false}) {
  return Tooltip(
      message: data?.name ?? '',
      child: isHackchat
          ? BorderText(text: data?.msg ?? '', fontSize: fontSize)
          : Text(
              data?.msg ?? '',
              style: TextStyle(
                  color: data?.color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize),
            ) /* Row(
              children: [
                CachedNetworkImage(
                    imageUrl: data != null && data.ext != null
                        ? data.ext!['avatar']
                        : '',
                    errorWidget: (context, url, error) => SizedBox(width: 0),
                    imageBuilder: (context, imageProvider) => Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                            width: fontSize,
                            height: fontSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        )),
                Expanded(
                    child: Text(
                  data?.msg ?? '',
                  style: TextStyle(
                      color: data?.color ?? Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize),
                ))
              ],
            ) */
      );
}
