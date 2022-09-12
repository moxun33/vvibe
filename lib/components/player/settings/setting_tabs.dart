//设置modal的标签页
import 'package:flutter/material.dart';

import 'package:vvibe/components/player/settings/playlist_subscription.dart';

class SettingTabBarView extends StatefulWidget {
  @override
  _SettingTabBarViewState createState() => _SettingTabBarViewState();
}

class _SettingTabBarViewState extends State<SettingTabBarView>
    with TickerProviderStateMixin {
  final tabs = [
    {'value': 'subscribe', 'label': '订阅'},
    {'value': 'player', 'label': '播放器'}
  ];
  late TabController _tabController = TabController(
    length: tabs.length,
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
        onTap: (tab) => print(tab),
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
    return Expanded(
        child: Column(
      children: [
        _buildTabBar(),
        Expanded(
          flex: 1,
          child: TabBarView(
            controller: _tabController,
            children: [
              PlaylistSubscription(),
              Center(child: Text(" ")),
            ],
          ),
        )
      ],
    ));
  }
}
