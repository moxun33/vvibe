import 'package:flutter/material.dart';
import 'package:vvibe/components/components.dart';
import 'package:vvibe/components/custom_scaffold.dart';
import 'package:vvibe/pages/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Image.asset('assets/logo.png'),
          ),
        ),
      ),
    );
  }
}
