/*
* @Author: Moxx
* @Date: 2022-09-09 17:00:19  * @Last Modified by:   Moxx
* @Last Modified time: 2022-09-09 17:00:19  @Description:
*/

//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vvibe/utils/color_util.dart';

/* import 'package:json_theme/json_theme.dart';
import 'package:flutter/services.dart';

//根据JSON生成主题

Future<ThemeData> genTheme(
    {String jsonPath = 'assets/light_theme.json'}) async {
  SchemaValidator.enabled = false;
  final themeStr = await rootBundle.loadString(jsonPath);
  final themeJson = jsonDecode(themeStr);
  return ThemeDecoder.decodeThemeData(themeJson)!;
}
 */
ThemeData genTheme() {
  return ThemeData(
      primaryColor: ColorUtil.fromHex(' #A92EFD'),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent);
}
