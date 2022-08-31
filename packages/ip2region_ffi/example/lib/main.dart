import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ip2region_ffi/ip2region_ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _ip2regionFfiPlugin = Ip2regionFfi();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

/*  platformVersion = await _ip2regionFfiPlugin.getIpInfo(
              '30.34.44.55', File('assets/ip2region.xdb').path) */
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _ip2regionFfiPlugin.getIpInfo(
              '27.47.71.92', File('assets/ip2region.xdb').path) ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
