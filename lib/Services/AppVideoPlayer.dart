import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:chewie/chewie.dart';

class AppVideoPlayer extends StatefulWidget {
  final String assetURL;
  final File assetFile;
  final String assetName;
  final MediaAssetSource assetSource;
  AppVideoPlayer(
      {this.assetURL, this.assetSource, this.assetFile, this.assetName});
  @override
  _AppVideoPlayerState createState() {
    return _AppVideoPlayerState();
  }
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController _chewieController;

  @override
  void initState() {
    switch (widget.assetSource) {
      case MediaAssetSource.network:
        _controller = VideoPlayerController.network(widget.assetURL);
        break;
      case MediaAssetSource.file:
        _controller = VideoPlayerController.file(widget.assetFile);
        break;
      case MediaAssetSource.asset:
        _controller = VideoPlayerController.asset(widget.assetName);
        break;

      default:
        _controller = VideoPlayerController.network("");
        break;
    }
    _controller.initialize().then((_) {
      _chewieController = ChewieController(videoPlayerController: _controller);
      setState(() {});
    });
    // _controller = VideoPlayerController.network(widget.assetURL)
    //   ..initialize().then((_) {
    //     setState(() {});
    //   });
    //_controller.initialize();
    super.initState();
  }

  @override
  dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  double get aspectRatio => _controller.value?.aspectRatio;

  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController.videoPlayerController.value.isInitialized
        ? AspectRatio(
            aspectRatio:
                _chewieController.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController))
        : Loading();
    // return _controller != null && _controller.value != null
    //     ? Stack(
    //         alignment: AlignmentDirectional.bottomCenter,
    //         children: [
    //           _controller.value.isInitialized
    //               ? AspectRatio(
    //                   aspectRatio: _controller.value.aspectRatio,
    //                   child: VideoPlayer(_controller),
    //                 )
    //               : Loading(),
    //           Container(
    //             padding: EdgeInsets.only(left: 30, right: 30),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 IconButton(
    //                   onPressed: () {
    //                     setState(() {
    //                       _controller.seekTo(Duration.zero);
    //                     });
    //                   },
    //                   icon: Icon(
    //                     CupertinoIcons.backward_end,
    //                   ),
    //                 ),
    //                 IconButton(
    //                   onPressed: () {
    //                     setState(() {
    //                       _controller.value.isPlaying
    //                           ? _controller.pause()
    //                           : _controller.play();
    //                     });
    //                   },
    //                   icon: Icon(
    //                     _controller.value.isPlaying
    //                         ? CupertinoIcons.pause_circle
    //                         : CupertinoIcons.play_circle,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       )
    //     : SizedBox();
  }
}
