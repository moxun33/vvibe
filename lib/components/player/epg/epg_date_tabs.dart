//设置modal的标签页
import 'package:flutter/material.dart';
import 'package:vvibe/components/player/epg/epg_channel_date.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';

class EpgDateTabsView extends StatefulWidget {
  const EpgDateTabsView(
      {Key? key, required this.urlItem, this.epgUrl, required this.doPlayback})
      : super(key: key);

  final PlayListItem urlItem;
  final String? epgUrl;
  final Function doPlayback;
  @override
  _EpgDateTabsViewState createState() => _EpgDateTabsViewState();
}

class _EpgDateTabsViewState extends State<EpgDateTabsView>
    with TickerProviderStateMixin {
  final tabs = EpgUtil().genWeekDays().map((e) => {'value': e, 'label': e});
  late TabController _tabController = TabController(
    length: tabs.length,
    initialIndex: tabs.length - 1,
    vsync: this,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTabBar() => TabBar(
        onTap: (tab) => {},
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 16),
        isScrollable: true,
        labelColor: Colors.purple,
        indicatorWeight: 3,
        controller: _tabController,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
        unselectedLabelColor: Colors.black87,
        indicatorColor: Colors.purple[300],
        tabs: tabs.map((e) => Tab(text: e['label'])).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          flex: 1,
          child: TabBarView(
            controller: _tabController,
            children: tabs
                .map((e) => EpgChannelDate(
                      epgUrl: widget.epgUrl,
                      doPlayback: widget.doPlayback,
                      urlItem: widget.urlItem,
                      date: e['value']!,
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
