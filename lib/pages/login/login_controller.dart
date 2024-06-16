import 'package:get/get.dart';

class LoginController extends GetxController {
  final count = 0.obs;
  String ipAddr = '';
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {}

  increment() => count.value++;
}
