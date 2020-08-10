import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  VideoPreview(this.recordedFilePath);

  final String recordedFilePath;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.recordedFilePath));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _controller.setLooping(true);
      await _controller.initialize();
      await _controller.play();
      // setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = _controller?.value?.aspectRatio ?? 0;
    return Scaffold(
      appBar: _appBar(context),
      body: AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Video Camera',
        style:
            Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
