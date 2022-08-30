import 'package:dart_vlc/dart_vlc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/langs/translation_service.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/pages/Index/Index_view.dart';
import 'package:vvibe/pages/Index/index_binding.dart';
import 'package:vvibe/router/app_pages.dart';
import 'package:get/get.dart';

import 'package:bruno/bruno.dart';

void main() {
  DartVLC.initialize(useFlutterNativeView: false);
  BrnInitializer.register(
      allThemeConfig: BrnAllThemeConfig(
    // 全局配置
    commonConfig: BrnCommonConfig(brandPrimary: Color(0xFF7866ff)),
  ));

  Global.init().then((e) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VVibe',
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
