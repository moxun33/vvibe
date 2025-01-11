//设置modal的标签页
import 'package:flutter/material.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/components/player/settings/player_settings.dart';
import 'package:vvibe/components/player/settings/playlist_subscription.dart';

class SettingsTabsView extends StatefulWidget {
  @override
  _SettingsTabsViewState createState() => _SettingsTabsViewState();
}

class _SettingsTabsViewState extends State<SettingsTabsView>
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
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        isScrollable: true,
        labelColor: AppColors.primaryColor,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.center,
        indicatorSize: TabBarIndicatorSize.label,
        controller: _tabController,
        unselectedLabelColor: Colors.black87,
        indicatorColor: AppColors.primaryColor,
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
            children: [PlaylistSubscription(), PlayerSettings()],
          ),
        )
      ],
    );
  }
}
