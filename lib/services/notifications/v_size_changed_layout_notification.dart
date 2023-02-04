import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VSizeChangedLayoutNotification extends Notification {
  final Size size;

  VSizeChangedLayoutNotification(this.size);
}

class VSizeChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  const VSizeChangedLayoutNotifier({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _RenderSizeChangedWithCallback createRenderObject(BuildContext context) {
    return _RenderSizeChangedWithCallback(onLayoutChangedCallback: (Size size) {
      VSizeChangedLayoutNotification(size).dispatch(context);
    });
  }
}

class _RenderSizeChangedWithCallback extends RenderProxyBox {
  _RenderSizeChangedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  })  : assert(onLayoutChangedCallback != null),
        super(child);

  final ValueChanged<Size> onLayoutChangedCallback;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (_oldSize != null && size != _oldSize) onLayoutChangedCallback(size);
    _oldSize = size;
  }
}
