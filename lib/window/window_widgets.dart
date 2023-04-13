import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/services/event_bus.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  final buttonColors = WindowButtonColors(
    //  iconNormal: Colors.white,
    mouseOver: Colors.purple,
    mouseDown: Colors.purple[400],
    /* iconMouseOver: Colors.white ,*/
    /* iconMouseDown: Colors.white */
  );

  final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    //  iconNormal: Colors.white,
    /* iconMouseOver: Colors.purple[100] */
  );
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
          colors: buttonColors,
        ),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(
          colors: closeButtonColors,
        ),
      ],
    );
  }
}

class WindowTitle extends StatefulWidget {
  WindowTitle({Key? key, this.title}) : super(key: key);
  String? title;
  @override
  _WindowTitleState createState() => _WindowTitleState();
}

class _WindowTitleState extends State<WindowTitle> {
  String title = 'VVibe';
  @override
  void initState() {
    super.initState();
    title = widget.title ?? 'VVibe';
    eventBus.on("set-window-title", (arg) {
      // do something
      setState(() {
        title = arg;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: Colors.black));
  }
}

//顶部操作栏
Widget WindowTitleBar({String title = 'VVibe'}) {
  return WindowTitleBarBox(
    child: MoveWindow(
        child: Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black38, width: 1))),
      height: CUS_WIN_TITLEBAR_HEIGHT,
      // color: Color.fromRGBO(40, 40, 40, 1),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Wrap(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 15,
                      width: 20,
                    ),
                    WindowTitle(title: title)
                  ],
                )),
          ),
          WindowButtons()
        ],
      ),
    )),
  );
}

//统一窗口包裹器
Widget WindowScaffold(Widget child, {String title = 'VVibe'}) {
  return Scaffold(
    body: WindowBorder(
        color: Colors.transparent,
        width: 0,
        child: Column(
          children: [WindowTitleBar(title: title), Expanded(child: child)],
        )),
  );
}
