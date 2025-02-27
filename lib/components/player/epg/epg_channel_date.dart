import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';
import 'package:vvibe/utils/utils.dart';

class EpgChannelDate extends StatefulWidget {
  const EpgChannelDate(
      {Key? key,
      required this.urlItem,
      required String this.date,
      this.epgUrl,
      required this.doPlayback})
      : super(key: key);
  final PlayListItem urlItem;
  final String date;
  final String? epgUrl;
  final Function doPlayback;
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
      await EpgUtil().downloadEpgDataAync(epgUrl: widget.epgUrl);
      final name = widget.urlItem.tvgName!.isNotEmpty
          ? widget.urlItem.tvgName
          : widget.urlItem.name;
      final id = widget.urlItem.tvgId;
      if (name == null || name == '' && (id == null || id == '')) {
        EasyLoading.showError('缺少频道名称，无法获取节目单');
        return;
      }
      EasyLoading.show(status: '正在加载节目单');
      ChannelEpg? _data = await EpgUtil().getChannelDateEpg(id, widget.date);
      if (_data == null) {
        _data = await EpgUtil().getChannelDateEpg(name, widget.date);
      }
      setState(() {
        data = _data;
      });
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('加载节目单失败: ' + e.toString());
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _toSeekTime(DateTime time) {
    return DateFormat('yyyyMMddHHmmss').format(time);
  }

  bool canUrlPlayback() {
    final url = widget.urlItem.url;
    return (widget.urlItem.catchup != null &&
            widget.urlItem.catchupSource != null) ||
        url.indexOf('PLTV') > -1 ||
        url.indexOf('TVOD') > -1;
  }

  String getPlayseek(EpgDatum epg) {
    return _toSeekTime(epg.start) + '-' + _toSeekTime(epg.end);
    //_toSeekTime(epg.start) + '-' + _toSeekTime(epg.end);
  }

  Widget _setBtn(EpgDatum epg,
      {bool isLive = false, bool played = false, bool toPlay = false}) {
    final canPlayback = canUrlPlayback();
    final text = Text(
        isLive ? '正在直播' : (toPlay ? '未播放' : (canPlayback ? '回看' : '已播放')),
        style: TextStyle(
            color: isLive
                ? Colors.purple
                : (toPlay ? Colors.grey[600] : Colors.blue[300])));
    if (played && !isLive && canPlayback) {
      return TextButton(
          onPressed: () {
            widget.doPlayback(getPlayseek(epg));
          },
          child: text);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: text,
    );
  }

  Widget _EpgRow(EpgDatum epg) {
    DateTime now = DateTime.now();
    DateTime st = (epg.start);
    DateTime et = (epg.end);
    final isLive = now.isAfter(st) && now.isBefore(et),
        played = st.isBefore(now),
        toPlay = et.isAfter(now);
    return Container(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Flex(direction: Axis.horizontal, children: [
        Expanded(
            child: Row(
          children: [
            Text(
              DateFormat('HH:mm').format(epg.start),
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
              '结束于：${DateFormat('HH:mm').format(epg.end)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        )),
        SizedBox(
          width: 100,
          child: _setBtn(epg, isLive: isLive, played: played, toPlay: toPlay),
        ),
      ]),
      decoration: BoxDecoration(
          color: isLive ? Colors.grey[100] : Colors.transparent,
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))),
    );
  }

  Widget _buildList() {
    List<EpgDatum> _epg = data?.epg ?? [];
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
      return Center(
        child: SizedBox(
          child: Text('节目单为空'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }
}
