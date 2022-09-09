import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: new BoxDecoration(
          color: Colors.black87,
        ),
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
