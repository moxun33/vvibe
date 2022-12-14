import 'package:flutter/material.dart';

//页面加载指示器
class Spinning extends StatefulWidget {
  Spinning({Key? key}) : super(key: key);

  @override
  _SpinningState createState() {
    return _SpinningState();
  }
}

class _SpinningState extends State<Spinning> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);

  // Create an animation with value of type "double"
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget Cirle(Color color) => Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Container(
          width: 40,
          color: Colors.transparent,
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              Icon(
                Icons.filter_vintage_sharp,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
    // This button is used to pause/resume the animation
  }
}

//小尺寸加载指示器
class SmallSpinning extends StatefulWidget {
  const SmallSpinning({Key? key}) : super(key: key);

  @override
  _SmallSpinningState createState() => _SmallSpinningState();
}

class _SmallSpinningState extends State<SmallSpinning>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);

  // Create an animation with value of type "double"
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Icon(
        size: 10,
        Icons.filter_vintage_sharp,
        color: Colors.purple,
      ),
    );
  }
}
