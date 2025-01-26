import 'package:flutter/material.dart';

class SettingsWidgets {
  static Widget buildInputRow(TextEditingController controller,
      {String? label,
      InputDecoration? decoration,
      double? inputWidth = 650.0}) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: Text(label ?? '', style: TextStyle(color: Colors.purple))),
        SizedBox(
          width: inputWidth ?? 650.0,
          child: TextField(controller: controller, decoration: decoration),
        )
      ],
    );
  }

  static Widget buildSwitch(
      String label, bool value, Function(bool v) onChanged) {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: SizedBox(
              width: 60,
              child: Text(label, style: TextStyle(color: Colors.purple))),
        ),
        SizedBox(
          width: 80,
          child: Switch(
            value: value, //当前状态
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
