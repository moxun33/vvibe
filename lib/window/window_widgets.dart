import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:vvibe/utils/color_util.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  final buttonColors = WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: AppColors.primaryColor,
      mouseDown: AppColors.primaryColor,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white);

  final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Colors.white,
      iconMouseOver: Colors.purple[100]);
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  windowClosed() {}
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
  final String? title;
  @override
  _WindowTitleState createState() => _WindowTitleState();
}

class _WindowTitleState extends State<WindowTitle> {
  String title = 'VVibe';
  String icon = '';
  @override
  void initState() {
    super.initState();
    title = widget.title ?? 'VVibe';
    eventBus.on("set-window-title", (arg) {
      setState(() {
        title = arg;
      });
    });
    eventBus.on("set-window-icon", (arg) {
      setState(() {
        icon = arg;
      });
    });
  }

  Widget BarIcon() {
    final defIcon = Image.asset(
      'assets/logo.png',
      height: 25,
    );
    if (icon.isEmpty) return defIcon;
    return CachedNetworkImage(
      fit: BoxFit.contain,
      imageUrl: icon,
      height: 30,
      errorWidget: (context, url, error) => defIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Padding(
          padding: const EdgeInsets.only(left: 5, top: 2), child: BarIcon()),
      Container(
        padding: const EdgeInsets.only(left: 10, top: 5),
        child: Text(title, style: TextStyle(color: Colors.white)),
      )
    ]);
  }
}

//顶部操作栏
Widget WindowTitleBar({String title = 'VVibe'}) {
  return WindowTitleBarBox(
    child: MoveWindow(
        child: Container(
      decoration: BoxDecoration(
          color: ColorUtil.fromHex('#3D3D3D'),
          border: Border(top: BorderSide(color: Colors.black38, width: 1))),
      height: CUS_WIN_TITLEBAR_HEIGHT,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: WindowTitle(title: title),
          ),
          WindowButtons()
        ],
      ),
    )),
  );
}

//统一窗口包裹器
class WindowScaffold extends StatefulWidget {
  WindowScaffold(
      {super.key,
      required Widget this.child,
      String title = 'VVibe',
      String icon = ''});
  final Widget child;
  final String? title = 'VVibe';
  final String? icon = '';
  @override
  State<WindowScaffold> createState() => _WindowScaffoldState();
}

class _WindowScaffoldState extends State<WindowScaffold> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowBlur() {
    windowManager.blur();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String e) async {
    // MyLogger.info('window event ${e.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
          color: Colors.transparent,
          width: 0,
          child: Column(
            children: [
              WindowTitleBar(
                title: widget.title ?? 'VVibe',
              ),
              Expanded(child: widget.child)
            ],
          )),
    );
  }
}
