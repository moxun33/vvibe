import 'package:vvibe/pages/Index/Index_controller.dart';
import 'package:get/get.dart';
import 'package:vvibe/pages/fvp/fvp_controller.dart';
import 'package:vvibe/pages/home/home_controller.dart';
import 'package:vvibe/pages/login/login_controller.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndexController>(() => IndexController());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FvpController>(() => FvpController());
  }
}
