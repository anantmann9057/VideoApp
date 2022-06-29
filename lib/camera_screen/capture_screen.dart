import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:video_app/camera_screen/preview_screen.dart';
import 'package:video_player/video_player.dart';

class CapturesScreen extends StatefulWidget {
  final List<File> imageFileList;

  const CapturesScreen({required this.imageFileList});

  @override
  State<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    widget.imageFileList.forEach((element) {
      _controller = VideoPlayerController.file(element)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _controller!.setLooping(true);
            // _controller!.play();
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Captures',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                for (File imageFile in widget.imageFileList)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(
                                fileList: widget.imageFileList,
                                imageFile: imageFile,
                              ),
                            ),
                          );
                        },
                        child: VideoPlayer(_controller!)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
