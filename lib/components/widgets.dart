/*
 * @Author: moxun33
 * @Date: 2022-09-13 21:40:49
 * @LastEditors: moxun33
 * @LastEditTime: 2023-02-12 17:35:37
 * @FilePath: \vvibe\lib\components\widgets.dart
 * @Description: 一些小组件
 * @qmj
 */

//有边框的文字
import 'package:flutter/material.dart';

class BorderText extends StatelessWidget {
  BorderText({Key? key, required this.text, fontSize}) : super(key: key);
  String text;
  double? fontSize;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Implement the stroke
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..color = Colors.purple,
          ),
        ),
        // The text inside
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
