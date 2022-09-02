/*
 * @Author: Moxx 
 * @Date: 2022-09-02 16:32:16 
 * @Last Modified by:   Moxx 
 * @Last Modified time: 2022-09-02 16:32:16 
 */
import 'package:flutter/material.dart';

class VideoPlaylist extends StatefulWidget {
  const VideoPlaylist({Key? key}) : super(key: key);

  @override
  _VideoPlaylistState createState() => _VideoPlaylistState();
}

class _VideoPlaylistState extends State<VideoPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Text("dd"),
      ),
      height: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
        color: Colors.black87,
      ),
    );
  }
}
