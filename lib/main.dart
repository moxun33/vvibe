import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/langs/translation_service.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/pages/Index/Index_view.dart';
import 'package:vvibe/pages/Index/index_binding.dart';
import 'package:vvibe/router/app_pages.dart';
import 'package:get/get.dart';

import 'init.dart';

void main() async {
  final theme = await init();

  Global.init().then((e) => runApp(MyApp(theme: theme)));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VVibe',
      theme: theme,
      home: IndexPage(),
      initialBinding: IndexBinding(),
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,
      builder: EasyLoading.init(),
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
    );
  }
}
