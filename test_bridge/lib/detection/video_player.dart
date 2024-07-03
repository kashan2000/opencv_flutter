import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_info/media_info.dart';
import 'package:video_player/video_player.dart';
import 'package:export_video_frame/export_video_frame.dart';

class VideoProcessor extends StatefulWidget {
  @override
  _VideoProcessorState createState() => _VideoProcessorState();
}

class _VideoProcessorState extends State<VideoProcessor> {
  late VideoPlayerController _controller;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse("https://youtu.be/Ux_kLd7qAcY"), // Replace with your video URL
    )..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processVideoFrames() {

    Stream<File> exportImagesFromFile(
        File file, Duration interval, double radian) async* {
      var mediaInfo = MediaInfo();
      var videoInfo = await mediaInfo.getMediaInfo(file.path);

      var videoLength = Duration(milliseconds: videoInfo["durationMs"]);

      ExportVideoFrame.workOnImages = true;
      for (var i = Duration.zero; i < videoLength; i += interval) {
        var image =
            await ExportVideoFrame.exportImageBySeconds(file, i, radian);
        if (ExportVideoFrame.stopWoringOnImages) {
          break;
        } else {
          yield image;
        }
      }
      ExportVideoFrame.stopWoringOnImages = false;
      ExportVideoFrame.workOnImages = false;
    }

    File videoo = File.fromUri(Uri.parse("https://www.youtube.com/watch?v=Ux_kLd7qAcY"));
    var stramimage = exportImagesFromFile(videoo, const Duration(milliseconds: 10), .2);
    // print("stram image> $stramimage");
    // for (var frame in _controller.value.frames) {
    //   _processFrame(frame); // Process each frame
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Processor'),
      ),
      body: _isPlaying
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : CircularProgressIndicator(),
      floatingActionButton: FloatingActionButton(
        onPressed: _processVideoFrames,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
