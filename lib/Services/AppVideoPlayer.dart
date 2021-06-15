import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:deeformity/Shared/constants.dart';
//import 'package:chewie/chewie.dart';

class AppVideoPlayer extends StatefulWidget {
  final String assetURL;
  final File assetFile;
  final String assetName;
  final MediaAssetSource assetSource;
  final bool flipHeightAndWidth;
  AppVideoPlayer(
      {this.assetURL,
      this.assetSource,
      this.assetFile,
      this.assetName,
      this.flipHeightAndWidth = false});
  @override
  _AppVideoPlayerState createState() {
    return _AppVideoPlayerState();
  }
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController _controller;
  //ChewieController _chewieController;
  bool showControls = true;

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
      // _chewieController = ChewieController(videoPlayerController: _controller);
      // _chewieController.enterFullScreen();
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
    //_chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  double get aspectRatio => _controller.value?.aspectRatio;

  Widget build(BuildContext context) {
    if (_controller != null && _controller.value.isInitialized) {
      print(_controller.value.size?.height);
    }
    return _controller != null && _controller.value.isInitialized
        ? GestureDetector(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: FittedBox(
                    //§fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                showControls
                    ? Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _controller.value.isPlaying
                                    ? IconButton(
                                        icon: Icon(CupertinoIcons.pause_circle),
                                        onPressed: () {
                                          setState(() {
                                            _controller.pause();
                                          });
                                        },
                                        color: Colors.white,
                                      )
                                    : _controller.value.position !=
                                            _controller.value.duration
                                        ? IconButton(
                                            icon: Icon(CupertinoIcons
                                                .play_circle_fill),
                                            onPressed: () {
                                              setState(() {
                                                _controller.play();
                                              });
                                            },
                                            color: Colors.white,
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.replay),
                                            onPressed: () {
                                              setState(() {
                                                _controller
                                                    .seekTo(Duration.zero);
                                                _controller.play();
                                              });
                                            },
                                            color: Colors.white,
                                          ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
            onTap: () {
              setState(() {
                showControls = !showControls;
              });
            },
          )
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
