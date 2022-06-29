import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_app/camera_screen/capture_screen.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final List<File> fileList;

  const PreviewScreen({
    required this.imageFile,
    required this.fileList,
  });
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.imageFile)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller!.setLooping(true);
          _controller!.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CapturesScreen(
                      imageFileList: widget.fileList,
                    ),
                  ),
                );
              },
              child: Text('Go to all captures'),
              style: TextButton.styleFrom(
                primary: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: VideoPlayer(_controller!),
          ),
        ],
      ),
    );
  }
}
