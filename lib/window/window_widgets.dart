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

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  bool maximized = false;
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void maximizeOrRestore() {
    setState(() {});
  }

  maximize() async {
    final _maximized = await windowManager.isMaximized();
    setState(() {
      maximized = !_maximized;
    });
    if (_maximized) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  minimize() {
    windowManager.minimize();
  }

  close() {
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WinButton(
          hoverColor: Colors.grey[700],
          icon: Icons.horizontal_rule_sharp,
          onPressed: minimize,
        ),
        WinButton(
          icon:maximized?Icons.filter_none: Icons.rectangle_outlined,
          onPressed: maximize,
          iconSize: maximized?16:18,
        ),
        WinButton(
          hoverColor: Colors.red,
          icon: Icons.close,
          onPressed: close,
        ),
      ],
    );
  }
}

class WinButton extends StatefulWidget {
  WinButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.hoverColor,
      this.iconSize});

  final IconData icon;
  final Function onPressed;
  final Color? hoverColor;
  final double? iconSize;
  @override
  State<WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<WinButton> {
  bool hovered = false;
  void onHover(PointerEvent details) {
    setState(() {
      hovered = true;
    });
  }

  void onExit(PointerEvent details) {
    setState(() {
      hovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: MouseRegion(
          onEnter: onHover,
          onExit: onExit,
          child: Container(
              width: 10 + CUS_WIN_TITLEBAR_HEIGHT,
              height: CUS_WIN_TITLEBAR_HEIGHT,
              color: hovered
                  ? (widget.hoverColor ?? Colors.white12)
                  : Colors.transparent,
              child: Icon(
                widget.icon,
                color: hovered ? Colors.white : Colors.grey,
                size: widget.iconSize ?? 20,
              ))),
    );
  }
}

class WindowTitle extends StatefulWidget {
  WindowTitle({Key? key, this.title, this.icon, this.visible})
      : super(key: key);
  final String? title;
  final String? icon;
  final bool? visible;
  @override
  _WindowTitleState createState() => _WindowTitleState();
}

class _WindowTitleState extends State<WindowTitle> {
  @override
  void initState() {
    super.initState();
  }

  Widget BarIcon() {
    final defIcon = Image.asset(
      'assets/logo.png',
      height: 25,
    );
    if (widget.icon != null || widget.icon?.isEmpty == true) return defIcon;
    return CachedNetworkImage(
      fit: BoxFit.contain,
      imageUrl: widget.icon!,
      height: 25,
      errorWidget: (context, url, error) => defIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.visible == true
        ? Wrap(children: [
            Padding(padding: const EdgeInsets.only(left: 10), child: BarIcon()),
            Container(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Text(widget.title ?? APP_NAME,
                  style: TextStyle(color: Colors.white70)),
            )
          ])
        : SizedBox();
  }
}

//顶部标题栏
class WindowTitleBar extends StatefulWidget {
  WindowTitleBar({Key? key, this.title, this.icon = '', this.visible = false})
      : super(key: key);
  final String? title;
  final String icon;
  final bool visible;

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  @override
  Widget build(BuildContext context) {
    return widget.visible
        ? GestureDetector(
            onPanStart: (details) {},
            onPanUpdate: (details) {
              windowManager.startDragging();
            },
            onPanEnd: (details) {
              /*  windowManager.setPosition(Offset(
                windowManager.getPosition().dx + _currentPosition.dx,
                windowManager.getPosition().dy + _currentPosition.dy,
              )); */
            },
            child: Container(
              height: widget.visible ? CUS_WIN_TITLEBAR_HEIGHT : 0,
              color: Colors.grey[900],
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: WindowTitle(
                        visible: widget.visible,
                        title: widget.title ?? APP_NAME,
                        icon: widget.icon),
                  ),
                  WindowButtons()
                ],
              ),
            ))
        : SizedBox();
  }
}

//统一窗口包裹器
class WindowScaffold extends StatefulWidget {
  WindowScaffold(
      {super.key,
      required Widget this.child,
      this.title,
      String icon = ''});
  final Widget child;
  final String? title;
  final String? icon = '';
  @override
  State<WindowScaffold> createState() => _WindowScaffoldState();
}

class _WindowScaffoldState extends State<WindowScaffold> with WindowListener {
  bool showTitlebar = true;
  String title = APP_NAME;
  String icon = '';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    eventBus.on("show-title-bar", (arg) {
      setState(() {
        showTitlebar = arg;
      });
    });
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
    return Column(
      children: [
        WindowTitleBar(
          visible: showTitlebar,
          title: title,
          icon: icon,
        ),
        Expanded(child: widget.child)
      ],
    );
  }
}
