/*
* @Author: Moxx
* @Date: 2022-09-09 17:00:19  * @Last Modified by:   Moxx
* @Last Modified time: 2022-09-09 17:00:19  @Description:
*/

//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vvibe/common/colors/colors.dart';

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
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black12,
    primaryColor: AppColors.primaryColor,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}
