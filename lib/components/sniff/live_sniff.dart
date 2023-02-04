import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vvibe/common/values/enum.dart';

import 'package:vvibe/utils/playlist/sniff_util.dart';

class LiveSniff extends StatefulWidget {
  const LiveSniff({Key? key}) : super(key: key);

  @override
  _LiveSniffState createState() => _LiveSniffState();
}

class _LiveSniffState extends State<LiveSniff> {
  final TextEditingController _urlTextCtl = TextEditingController();
  final TextEditingController _batchNumCtl = TextEditingController();
  final TextEditingController _toNumCtl = TextEditingController();
  bool validOnly = true;
  int total = 0; //总数
  int checked = 0; //已检测
  int success = 0; //有效
  int timeout = 0; //超时
  bool sniffing = false; //扫描中
  bool canceled = false; //已取消
  List<dynamic> data = []; //表格数据
  @override
  void initState() {
    super.initState();
    _batchNumCtl.text = '5';
    _toNumCtl.text = '1000';
    _urlTextCtl.text = 'http://113.64.147.[1-10]:808/hls/[1-11]/index.m3u8';
  }

//开始扫描
  void _start() async {
    String urlText = _urlTextCtl.text;
    if (urlText.isEmpty) return;
    final list = SniffUtil().genUrlsByTpl(urlText);
    if (list.length < 1) return;
    setState(() {
      canceled = false;
      sniffing = true;
      total = list.length;
    });
  }

//取消扫描
  _stop() {
    setState(() {
      canceled = true;
      sniffing = false;
    });
  }

//清空
  _clear() {
    setState(() {
      canceled = false;
      data = [];
      total = 0;
      success = 0;
      timeout = 0;
      checked = 0;
    });
  }

  TableRow _genTableRow(List<Widget> children) {
    return TableRow(
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: Colors.grey)),
        color: Colors.white,
      ),
      children: children,
    );
  }

//渲染状态标签
  Widget _renderStatus(UrlSniffResStatus status) {
    Color color = Colors.black;
    String text = '';
    switch (status) {
      case UrlSniffResStatus.success:
        color = Colors.green;
        text = '有效';
        break;
      case UrlSniffResStatus.timeout:
        color = Colors.orange;
        text = '超时';
        break;
      default:
        break;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: color),
    );
  }

  Widget _genCell(dynamic text,
      {isHeader = false, isLink = false, isStatus = false}) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: isStatus
            ? _renderStatus(text as UrlSniffResStatus)
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isHeader ? 16 : 14),
              ));
  }

  TableRow _genTableHeader() {
    return _genTableRow([
      _genCell('频道', isHeader: true),
      _genCell('状态', isHeader: true),
      _genCell('分辨率', isHeader: true),
      // _genCell('地区/运营商', isHeader: true),
      _genCell('链接', isHeader: true)
    ]);
  }

  List<TableRow> _tableRowList() {
    return [_genTableHeader()];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(children: <Widget>[
        Row(
          children: [
            SizedBox(
              width: 500,
              child: TextField(
                controller: _urlTextCtl,
                decoration: InputDecoration(
                    hintText:
                        '模板，如 http://113.64.[1-255].[1-255]:808/hls/[1-200]/index.m3u8'),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 90),
              width: 60,
              child: Text('${checked}/${total}'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 60,
              child:
                  Text('有效：${success}', style: TextStyle(color: Colors.green)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 60,
              child: Text('无效：${checked > 0 ? total - success - timeout : 0}',
                  style: TextStyle(color: Colors.red)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 100,
              child: Text('超时：${timeout}'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
                value: validOnly,
                onChanged: (v) {
                  setState(() {
                    validOnly = v ?? false;
                  });
                }),
            Text('只看有效'),
            SizedBox(
              width: 100,
            ),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(label: Text('并发数')),
                controller: _batchNumCtl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 100,
            ),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(label: Text('超时(ms)')),
                controller: _toNumCtl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 100,
            ),
            FilledButton(
              child: Text(sniffing ? '扫描中' : '扫描'),
              onPressed: !sniffing
                  ? () {
                      _start();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: Text('导出'),
              onPressed: null,
            ),
            SizedBox(
              width: 20,
            ),
            OutlinedButton(
              child: Text('清空', style: TextStyle(color: Colors.grey)),
              onPressed: !sniffing
                  ? () {
                      _clear();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            TextButton(
              child: Text('取消', style: TextStyle(color: Colors.grey)),
              onPressed: sniffing && !canceled
                  ? () {
                      _stop();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            Tooltip(
              child: Icon(
                Icons.question_mark_outlined,
                color: Colors.orangeAccent,
              ),
              message: '支持3组数字变量，变量用[]表示。目前仅支持http协议',
            )
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Table(
          children: _tableRowList(),
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(3),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        )
      ]),
    );
  }
}
