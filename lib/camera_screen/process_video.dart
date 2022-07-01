import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:video_app/home/home_screen.dart';
import 'package:video_app/video_editor/video_editor.dart';

class ProcessVideo extends StatefulWidget {
  final String fileName, filePath;
  ProcessVideo(this.fileName, this.filePath);

  @override
  State<ProcessVideo> createState() => _ProcessVideoState();
}

class _ProcessVideoState extends State<ProcessVideo> {
  @override
  void initState() {
    super.initState();
    generateFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CircularProgressIndicator(),
      )),
    );
  }

  Future<void> generateFile() async {
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DCIM);

    FFmpegKitConfig.getSafParameterForWrite(widget.filePath)
        .then((safUrl) async {
      //                  '-i $directory/hello.mp4 -i ${value!.path.toString()} -i $downloadsDirectory/thrilllogo.png -filter_complex "[2:v]scale=250x200,[0:v]overlay=0:0,[1:v]overlay=0:0" $safUrl.mp4')
      var mediaQuery = MediaQuery.of(context).size;
      await FFmpegKit.execute(
              '-i $directory/hello.mp4 -i ${widget.filePath} -filter_complex "[0:v]overlay=0:0" -vcodec libx265  -preset ultrafast -s 800x600 $directory/${widget.fileName}.mp4')
          .then((value) {
        var videoFile = File('$directory/${widget.fileName}.mp4');
        Get.off(() => VideoEditor(file: videoFile));
      });
    });
  }
}
