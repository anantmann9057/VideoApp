import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart'
    show OpacityTransition, SwipeTransition, AnimatedInteractiveViewer;
import 'package:image_downloader/image_downloader.dart';
import 'package:video_app/home/home_screen.dart';
import 'package:video_app/video_editor/crop_screen.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  VideoEditor({required this.file, required this.filterUrl});

  final File file;
  String filterUrl;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(seconds: 60))
      ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  //crop screen
  void _openCropScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CropScreen(controller: _controller)));

  //export video
  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
      onProgress: (stats, value) => _exportingProgress.value = value,
      onError: (e, s) => _exportText = "Error on export video :(",
      onCompleted: (file) async {
        _isExporting.value = false;
        if (!mounted) return;

        _exportText = "Video success export!";
        setState(() => _exported = true);

        Future.delayed(const Duration(seconds: 2),
            () => setState(() => _exported = false));

        File videoFile = File(file.path);

        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DCIM);

        String fileFormat = videoFile.path.split('.').last;

        await videoFile
            .copy(
          '$directory/hellobyebye.$fileFormat',
        )
            .then((value) async {
          await file.delete();
        });

        _downloadImage(widget.filterUrl);
      },
    );
  }

  //download image to process with ffmpeg
  void _downloadImage(String url) async {
    try {
      // Saved with this method.

      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }

      // Below is a method of obtaining saved image information.
      var fileName = await ImageDownloader.findName(imageId);
      var path = await ImageDownloader.findPath(imageId);
      var size = await ImageDownloader.findByteSize(imageId);
      var mimeType = await ImageDownloader.findMimeType(imageId);

      Get.to(() => const HomeScreen());

      await controller.generateFile(path!, fileName!).then((value) {
        // File(path).delete();
      });

      //dispose controller before moving to processing screen
    } on PlatformException catch (error) {
      print(error);
    }
  }

  //export cover
  void _exportCover() async {
    setState(() => _exported = false);
    await _controller.extractCover(
      onError: (e, s) => _exportText = "Error on cover exportation :(",
      onCompleted: (cover) {
        if (!mounted) return;

        _exportText = "Cover exported! ${cover.path}";

        // showDialog(
        //   context: context,
        //   builder: (_) => Padding(
        //     padding: const EdgeInsets.all(30),
        //     child: Center(child: Image.memory(cover.readAsBytesSync())),
        //   ),
        // );

        setState(() => _exported = true);
        Future.delayed(const Duration(seconds: 2),
                () => setState(() => _exported = false))
            .then((value) => Get.to(HomeScreen()));
      },
    );
  }

  //main layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.initialized
          ? SafeArea(
              child: Stack(children: [
              Column(children: [
                _topNavBar(),
                Expanded(
                    child: DefaultTabController(
                        length: 2,
                        child: Column(children: [
                          Expanded(
                              child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Stack(alignment: Alignment.center, children: [
                                Container(
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      return Container(
                                        width: constraints.maxWidth / .5,
                                        height: constraints.maxHeight,
                                        alignment: Alignment.topCenter,
                                        child: CropGridViewer(
                                          controller: _controller,
                                          showGrid: false,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                //filter image
                                IgnorePointer(
                                  ignoring: true,
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      return Container(
                                        alignment: Alignment.topCenter,
                                        child: CachedNetworkImage(
                                          width: constraints.maxWidth / 1.4,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          fit: BoxFit.fitHeight,
                                          imageUrl: widget.filterUrl,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                //play button
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) => OpacityTransition(
                                    visible: !_controller.isPlaying,
                                    child: GestureDetector(
                                      onTap: _controller.video.play,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              //cover
                              Stack(
                                children: [
                                  CoverViewer(controller: _controller),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: LayoutBuilder(
                                      builder: (BuildContext context,
                                          BoxConstraints constraints) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: CachedNetworkImage(
                                            width: constraints.maxWidth / 1.4,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            fit: BoxFit.fitHeight,
                                            imageUrl: widget.filterUrl,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                          //bottom tabs layout
                          Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(children: [
                                TabBar(
                                  indicatorColor: Colors.black,
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                Icons.content_cut,
                                                color: Colors.black,
                                              )),
                                          Text(
                                            'Trim',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                Icons.video_label,
                                                color: Colors.black,
                                              )),
                                          Text(
                                            'Cover',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ]),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: _trimSlider()),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ],
                                  ),
                                )
                              ])),
                          _customSnackBar(),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, __) => OpacityTransition(
                              visible: export,
                              child: AlertDialog(
                                backgroundColor: Colors.black,
                                title: ValueListenableBuilder(
                                  valueListenable: _exportingProgress,
                                  builder: (_, double value, __) => Text(
                                    "Exporting video ${(value * 100).ceil()}%",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ])))
              ])
            ]))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(
                  Icons.rotate_left,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(
                  Icons.rotate_right,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _openCropScreen,
                icon: const Icon(
                  Icons.crop,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _exportCover,
                icon: const Icon(
                  Icons.save_alt,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _exportVideo,
                icon: const Icon(
                  Icons.save,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  const SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            controller: _controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
                controller: _controller,
                margin: const EdgeInsets.only(top: 10))),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
