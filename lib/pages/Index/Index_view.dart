import 'package:flutter/material.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/pages/Index/Index_controller.dart';
import 'package:vvibe/pages/home/home_view.dart';
import 'package:vvibe/pages/login/login_view.dart';
import 'package:vvibe/pages/splash/splash_view.dart';
import 'package:get/get.dart';

class IndexPage extends GetView<IndexController> {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GetBuilder<IndexController>(builder: (_) {
      return Center(
          child: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: controller.textureId == null
            ? SplashPage()
            : Texture(
                textureId: controller.textureId!,
                filterQuality: FilterQuality.high,
              ),
      ));
    }));
/*     return Obx(() => Scaffold(
          body: controller.isloadWelcomePage.isTrue
              ? SplashPage()
              : Global.isOfflineLogin
                  ? HomePage()
                  : LoginPage(),
        )); */
  }
}
