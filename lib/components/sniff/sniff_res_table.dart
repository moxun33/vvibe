import 'package:flutter/material.dart';
import 'package:vvibe/common/values/enum.dart';

class SniffResTable extends StatelessWidget {
  SniffResTable({Key? key, required this.data, required this.validOnly})
      : super(key: key);
  List<dynamic> data = [];
  bool validOnly = false;
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

  DataColumn _columnHeader(String text) {
    return DataColumn(
        label: Text(
      text,
      style: TextStyle(fontSize: 16),
    ));
  }

  DataCell _cell(String? text) {
    return DataCell(Text(text ?? ''));
  }

  List<dynamic> _getData(list, validOnly) => validOnly
      ? list
          .where((element) => element['status'] == UrlSniffResStatus.success)
          .toList()
      : list;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: DataTable(
            columns: [
          _columnHeader('频道'),
          _columnHeader('状态'),
          _columnHeader('分辨率'),
          _columnHeader('地区/运营商'),
          _columnHeader('链接'),
        ],
            rows: _getData(data, validOnly).map((e) {
              return DataRow(cells: [
                _cell(e['']),
                DataCell(_renderStatus(e['status'])),
                _cell(e['']),
                _cell(e['ipInfo']),
                _cell(e['url']),
              ]);
            }).toList()));
  }
}
