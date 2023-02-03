import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/models/channel_epg.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.date),
    );
  }
}
