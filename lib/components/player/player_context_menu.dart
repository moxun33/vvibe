import 'package:flutter/material.dart';

final List<String> entries = <String>[
  'A',
  'B',
  'C',
  'f',
  'fd',
  'df',
  'df',
  'dffd'
];
final List<int> colorCodes = <int>[600, 500, 100];

class PlayerContextMenu extends StatefulWidget {
  const PlayerContextMenu({Key? key}) : super(key: key);

  @override
  _PlayerContextMenuState createState() => _PlayerContextMenuState();
}

class _PlayerContextMenuState extends State<PlayerContextMenu> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            width: 150,
            height: 200,
            color: Colors.white,
            child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Text('Entry ${entries[index]}'),
                  );
                })));
  }
}
