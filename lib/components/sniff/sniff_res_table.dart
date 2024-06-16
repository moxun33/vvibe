import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/models/url_sniff_res.dart';
import 'package:vvibe/utils/playlist/sniff_util.dart';

class SniffResTable extends StatelessWidget {
  SniffResTable({Key? key, required this.data, required this.validOnly})
      : super(key: key);
  List<UrlSniffRes> data = [];
  bool validOnly = false;
//渲染状态标签
  Widget _renderStatus(UrlSniffResStatus? status) {
    Color color = Colors.black;
    String text = '';
    switch (status) {
      case UrlSniffResStatus.success:
        color = Colors.green;
        text = '有效';
        break;
      case UrlSniffResStatus.timeout:
        color = Colors.black;
        text = '超时';
        break;
      default:
        color = Colors.red;
        text = '无效';
        break;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: color),
    );
  }

  DataColumn _columnHeader(String text) {
    return DataColumn(
        label: Text(
      text,
      style: TextStyle(fontSize: 16),
    ));
  }

  DataCell _cell(String? text) {
    return DataCell(
      Text(text ?? ''),
    );
  }

  DataCell _urlCell(String? text) {
    return DataCell(Row(
      children: [
        SelectableText(text ?? ''),
        IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text ?? ''));
            },
            icon: Icon(
              Icons.copy,
              size: 14,
            ))
      ],
    ));
  }

  List<UrlSniffRes> _getData(List<UrlSniffRes> list, bool _validOnly) =>
      _validOnly != false
          ? list
              .where((element) => element.status == UrlSniffResStatus.success)
              .toList()
          : list;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: DataTable(
            dataRowHeight: 30,
            columns: [
              _columnHeader('频道'),
              _columnHeader('状态'),
              _columnHeader('分辨率'),
              _columnHeader('地区/运营商'),
              _columnHeader('链接'),
            ],
            rows: _getData(data, validOnly).map((UrlSniffRes e) {
              return DataRow(cells: [
                _cell('${e.index.toString()}号'),
                DataCell(_renderStatus(e.status)),
                _cell(SniffUtil().getVideoSize(e.mediaInfo)),
                _cell(e.ipInfo),
                _urlCell(e.url),
              ]);
            }).toList()));
  }
}
