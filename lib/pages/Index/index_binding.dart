import 'package:vvibe/pages/Index/Index_controller.dart';
import 'package:get/get.dart';
import 'package:vvibe/pages/home/home_controller.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndexController>(() => IndexController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
