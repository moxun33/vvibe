import 'package:get/get.dart';
import 'fvp_controller.dart';

class FvpBinding extends Bindings {
    @override
    void dependencies() {
    Get.lazyPut<FvpController>(() => FvpController());
    }
}
