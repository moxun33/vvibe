//子窗口

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/langs/translation_service.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:vvibe/services/notifications/v_size_changed_layout_notification.dart';
import 'package:vvibe/window/window_widgets.dart';

class SubWindow extends StatefulWidget {
  const SubWindow(
      {Key? key,
      required this.windowController,
      required this.args,
      required this.title,
      required this.child,
      required this.theme})
      : super(key: key);
  final ThemeData theme;
  final WindowController windowController;
  final Map? args;
  final String title;
  final Widget child;

  @override
  _SubWindowState createState() => _SubWindowState();
}

class _SubWindowState extends State<SubWindow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WindowScaffold(NotificationListener<VSizeChangedLayoutNotification>(
          onNotification: (VSizeChangedLayoutNotification notification) {
            if (notification.size.width < 1200 ||
                notification.size.height < 700) {
              widget.windowController
                ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                ..center();
            }
            return true;
          },
          child: VSizeChangedLayoutNotifier(
              child: Container(
            child: widget.child,
            constraints: BoxConstraints(minWidth: 1200, minHeight: 700),
          )))),
      title: widget.title,
      theme: widget.theme,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      locale: TranslationService.locale,
    );
  }
}
