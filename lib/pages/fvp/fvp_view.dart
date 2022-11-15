import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vvibe/utils/utils.dart';
import 'fvp_controller.dart';

class FvpPage extends GetView<FvpController> {
  FvpPage({Key? key}) : super(key: key);
  final TextEditingController _urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GetBuilder<FvpController>(builder: (_) {
      return Container(
          child: Center(
              child: Column(
        children: [
          Row(
            children: [
              Container(
                child: TextField(
                  decoration: InputDecoration(hintText: '请输入视频地址'),
                  controller: _urlController,
                ),
                width: getDeviceWidth(context) / 2,
              ),
              TextButton(
                  child: Text('播放'),
                  onPressed: () => controller.setMedia(_urlController.text)),
              ElevatedButton(
                  child: Text('暂停/播放'),
                  onPressed: () => controller.playOrPause())
            ],
          ),
          Expanded(
            child: controller.textureId == null
                ? Text('初始化中')
                : Texture(
                    textureId: controller.textureId!,
                    filterQuality: FilterQuality.high,
                  ),
          ),
        ],
      )));
    }));
  }
}
