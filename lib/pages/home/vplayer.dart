import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:vvibe/components/playlist/video_playlist.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/utils/screen_device.dart';

class Vplayer extends StatefulWidget {
  const Vplayer({Key? key}) : super(key: key);

  @override
  _VplayerState createState() => _VplayerState();
}

class _VplayerState extends State<Vplayer> {
  VideoPlayerController? _controller;
  bool playListShowed = true;
  @override
  void initState() {
    super.initState();
    // startPlay(PlayListItem(url: 'http://live.metshop.top/douyu/1377142'));
  }

  startPlay(PlayListItem? item) {
    if (item == null || item.url == null) return;
    if (_controller?.value?.isInitialized != null) _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(item.url!));

    _controller?.addListener(() {
      setState(() {});
    });
    _controller?.setLooping(true);
    _controller?.initialize().then((_) => setState(() {}));
    _controller?.play();
  }

  //播放url改变
  void onPlayUrlChange(PlayListItem item) async {
    if (item.url == null) return;
    startPlay(item);
  }

  @override
  void dispose() {
    _controller?.dispose();
  }

  Widget _buildCover() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 50,
          children: [
            SizedBox(
                width: 200,
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  imageUrl: '',
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/logo.png'),
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getDeviceWidth(context),
      color: Colors.black12,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
                flex: 4,
                child: _controller != null &&
                        _controller?.value.isInitialized == true
                    ? Stack(alignment: Alignment.bottomCenter, children: [
                        AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: Container(
                                color: Colors.black12,
                                child: VideoPlayer(_controller!))),
                        VideoProgressIndicator(
                          _controller!,
                          colors: VideoProgressColors(
                              playedColor: AppColors.primaryColor),
                          allowScrubbing: true,
                        ),
                      ])
                    : _buildCover()),
            Container(
                width: playListShowed ? PLAYLIST_BAR_WIDTH : 0,
                child: VideoPlaylist(
                  visible: playListShowed,
                  onUrlTap: onPlayUrlChange,
                )),
          ]),
        ],
      ),
    );
  }
}
