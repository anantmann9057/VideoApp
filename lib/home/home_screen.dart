import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_app/camera_screen/camera_screen.dart';
import 'package:video_app/components/data_controller.dart';
import 'package:video_app/components/fab_items.dart';
import 'package:video_app/models/video_list_model.dart';
import 'package:video_app/video_editor/video_editor.dart';

import 'package:video_app/components/video_item.dart';
import 'package:get/get.dart';

String _lastSelected = 'TAB: 0';

List<Data> videosList = [];

var controller = Get.find<DataController>();
PreloadPageController? preloadPageController;
int current = 0;
bool isOnPageTurning = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    preloadPageController = PreloadPageController();
    preloadPageController!.addListener(scrollListener);
    getVideos();
  }

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
    if (mounted && file != null) {
      Get.to(VideoEditor(file: File(file.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(CameraScreen());
          // _pickVideo();
        },
        tooltip: 'Increment',
        child: Container(
          child: CachedNetworkImage(
            imageUrl:
                'https://cdn2.iconfinder.com/data/icons/sports-and-games-4-1/48/190-512.png',
          ),
        ),
        elevation: 2.0,
      ),
      bottomNavigationBar: FABBottomAppBar(
        backgroundColor: Colors.black,
        centerItemText: 'Spin',
        color: Colors.white,
        selectedColor: Colors.red,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.menu, text: 'Home'),
          FABBottomAppBarItem(iconData: Icons.layers, text: 'Discover'),
          FABBottomAppBarItem(iconData: Icons.dashboard, text: 'Notification'),
          FABBottomAppBarItem(iconData: Icons.info, text: 'Profile'),
        ],
      ),
      body: Container(
          child: PreloadPageView.builder(
              controller: preloadPageController,
              scrollDirection: Axis.vertical,
              preloadPagesCount: 5,
              itemCount: videosList.length, //Notice this
              itemBuilder: (ctx, index) => VideoApp(
                    'https://thrillvideo.s3.amazonaws.com/test/' +
                        videosList[index].video.toString(),
                    videosList[index].description.toString(),
                    videosList[index].soundName.toString(),
                    videosList[index].soundCategoryName.toString(),
                    videosList[index].user!.avatar.toString(),
                    videosList[index].likes!.toInt(),
                    videosList[index].comments!,
                    videosList[index].id!,
                    index,
                    current,
                    isOnPageTurning,
                  ))),
    );
  }

  void scrollListener() {
    if (isOnPageTurning &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      setState(() {
        current = preloadPageController!.page!.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!).abs() > 0.1) {
        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  void getVideos() async {
    var videos = await controller.getVideos().then((value) => {
          if (mounted)
            {
              setState(() {
                videosList = value.data!;
              })
            }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
