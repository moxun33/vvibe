import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

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

  @override
  void initState() {
    super.initState();
    _batchNumCtl.text = '5';
    _toNumCtl.text = '1000';
    _urlTextCtl.text = 'http://113.64.147.[1-255]:808/hls/[1-100]/index.m3u8';
  }

//开始扫描
  void _start() async {
    String urlText = _urlTextCtl.text;
    if (urlText.isEmpty) return;
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

  Widget _genCell(String text,
      {isHeader = false, isLink = false, isStatus = false}) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
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
      _genCell('地区/运营商', isHeader: true),
      _genCell('链接', isHeader: true)
    ]);
  }

  List<TableRow> _tableRowList() {
    return [_genTableHeader(), _genTableHeader()];
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
                        '模板，如 http://113.64.[1-255].[1-25]:808/hls/[1-200]/index.m3u8'),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 90),
              width: 100,
              child: Text('10/100'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 100,
              child: Text('有效：100', style: TextStyle(color: Colors.green)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 100,
              child: Text('无效：100', style: TextStyle(color: Colors.red)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 100,
              child: Text('超时：100'),
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
              child: Text('扫描'),
              onPressed: () {
                _start();
              },
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: Text('导出'),
              onPressed: () {},
            ),
            SizedBox(
              width: 20,
            ),
            OutlinedButton(
              child: Text('清空', style: TextStyle(color: Colors.grey)),
              onPressed: () {},
            ),
            SizedBox(
              width: 20,
            ),
            TextButton(
              child: Text('取消', style: TextStyle(color: Colors.grey)),
              onPressed: () {},
            ),
            SizedBox(
              width: 20,
            ),
            Tooltip(
              child: Icon(
                Icons.question_mark_outlined,
                color: Colors.orangeAccent,
              ),
              message: '支持IPV6。支持3组变量，变量用[]表示。',
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
