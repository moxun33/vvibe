import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/components/components.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';
import 'package:vvibe/utils/utils.dart';

class EpgChannelDate extends StatefulWidget {
  const EpgChannelDate(
      {Key? key, required this.urlItem, required String this.date})
      : super(key: key);
  final PlayListItem urlItem;
  final String date;
  @override
  _EpgChannelDateState createState() => _EpgChannelDateState();
}

class _EpgChannelDateState extends State<EpgChannelDate> {
  ChannelEpg? data = null;
  @override
  void initState() {
    super.initState();
    getEpgData();
  }

  void getEpgData() async {
    try {
      EasyLoading.show(status: '正在加载节目单');
      ChannelEpg? _data = await EpgUtil()
          .getChannelEpg(widget.urlItem.tvgName, date: widget.date);
      setState(() {
        data = _data;
      });
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('加载节目单失败');
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime _toDateTime(String time) {
    final ymd = widget.date.split('-'), hm = time.split(':');
    return DateTime(int.parse(ymd[0]), int.parse(ymd[1]), int.parse(ymd[2]),
        int.parse(hm[0]), int.parse(hm[1]));
  }

  Widget _setBtn(EpgDatum epg,
      {bool isLive = false, bool played = false, bool toPlay = false}) {
    final canPlayback = true;
    final text = Text(isLive ? '正在直播' : (toPlay ? '未播放' : '已播放'),
        style: TextStyle(
            color: isLive
                ? Colors.purple
                : (toPlay ? Colors.grey[600] : Colors.blue[300])));
    if (played && !isLive && canPlayback) {
      return TextButton(onPressed: () {}, child: text);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: text,
    );
  }

  Widget _EpgRow(EpgDatum epg) {
    DateTime now = DateTime.now();
    DateTime st = _toDateTime(epg.start);
    DateTime et = _toDateTime(epg.end);
    final isLive = now.isAfter(st) && now.isBefore(et),
        played = st.isBefore(now),
        toPlay = et.isAfter(now);
    return Container(
      child: Flex(direction: Axis.horizontal, children: [
        Expanded(
            child: Row(
          children: [
            Text(
              epg.start,
              style: TextStyle(color: Colors.purple),
            ),
            SizedBox(
              width: 20,
            ),
            Text(epg.title),
            SizedBox(
              width: 20,
            ),
            Text(
              '结束时间：${epg.end}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        )),
        SizedBox(
          width: 100,
          child: _setBtn(epg, isLive: isLive, played: played, toPlay: toPlay),
        ),
      ]),
      decoration:
          BoxDecoration(color: isLive ? Colors.grey[100] : Colors.transparent),
    );
  }

  Widget _buildList() {
    List<EpgDatum> _epg = data?.epgData ?? [];
    if (_epg.length != 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _epg.length,
          itemExtent: 25.0,
          cacheExtent: getDeviceHeight(context) - 120.0,
          itemBuilder: (context, index) {
            final e = _epg[index];
            return _EpgRow(e);
          });
    } else {
      return Spinning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }
}
