import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Vplayer extends StatefulWidget {
  const Vplayer({Key? key}) : super(key: key);

  @override
  _VplayerState createState() => _VplayerState();
}

class _VplayerState extends State<Vplayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('http://live.metshop.top/douyu/1377142'));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
          ],
        ),
      ),
    );
  }
}
