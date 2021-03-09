import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:deeformity/Shared/loading.dart';

class AppVideoPlayer extends StatefulWidget {
  final String assetURL;
  AppVideoPlayer(this.assetURL);
  @override
  _AppVideoPlayerState createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.assetURL)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.initialize();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Center(
                child: Loading(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying
            ? CupertinoIcons.pause_circle
            : CupertinoIcons.play),
      ),
    );
  }
}
