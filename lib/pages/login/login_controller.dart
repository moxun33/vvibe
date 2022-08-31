import 'package:get/get.dart';
import 'package:vvibe/utils/ffi_util.dart';

class LoginController extends GetxController {
  final count = 0.obs;
  String? ipAddr = '';
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onReady() {
    FfiUtil().getIpInfo('27.47.71.99').then((info) {
      print('get ip info');
      print(info);
      ipAddr = info;
      update();
    });
  }

  @override
  void onClose() {}

  increment() => count.value++;
}
