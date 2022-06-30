// import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:video_app/components/constant.dart';
import 'package:video_app/components/data_controller.dart';
import 'package:video_app/models/video_comments_model.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

var visible = false.obs;
var isliked = false.obs;
var commentsLikes = 0.obs;
var controller = Get.find<DataController>();
var isFollowing = '+ Follow'.obs;
List<Data> commentsList = [];

class VideoApp extends StatefulWidget {
  final String url, description, songName, songDescription, profileImage;
  final int likes, comments, id;
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  VideoApp(
    this.url,
    this.description,
    this.songName,
    this.songDescription,
    this.profileImage,
    this.likes,
    this.comments,
    this.id,
    this.pageIndex,
    this.currentPageIndex,
    this.isPaused,
  );

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoApp> {
  VideoPlayerController? _controller;
  AnimationController? lottieContoller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    setVideoPlayer();
  }

  Future<VideoPlayerController> setVideoPlayer() async {
    _controller =  VideoPlayerController.network(widget.url)
      ..initialize
      ..setLooping(false);
    initialized = true;
    setState(() {});
    return _controller!;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageIndex == widget.currentPageIndex &&
        !widget.isPaused &&
        initialized) {
      _controller?.play();
    } else {
      _controller?.pause();
    }
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Center(
          child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Center(
              child: GestureDetector(
                  onTapUp: (details) => setState(() {
                        _controller!.play();
                      }),
                  onDoubleTap: () {
                    setState(() {
                      visible.value = true;
                      Future.delayed(const Duration(seconds: 2), () {
                        // Here you can write your code
                        setState(() {
                          visible.value = false;
                        });
                      });
                    });
                  },
                  onTapDown: (pressed) {
                    setState(() {
                      _controller!.pause;
                    });
                  },
                  child: VideoPlayer(_controller!))),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  fit: StackFit.loose,
                  alignment: Alignment.bottomCenter,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        widget.profileImage == 'null'
                            ? profileUrl + 'profile_images1655296950.jpg'
                            : profileUrl + widget.profileImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                likeButton(),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    getComments(widget.id.toString());
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
                      Text(
                        widget.comments.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Icon(
                  Icons.deck_outlined,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            child: Obx((() => Visibility(
                  visible: visible.value,
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/private_files/lf30_kpak4iic.json',
                  ),
                ))),
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10),
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.description == 'null' ? '' : widget.description,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(3.0)),
                          child: Obx((() => Text(
                                isFollowing.value,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.songName == 'null' ? '' : widget.songName,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.songDescription == 'null'
                        ? ''
                        : widget.songDescription,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              )),
          Container(
            alignment: Alignment.bottomCenter,
            child: VideoProgressIndicator(
              _controller!, //controller
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.blueGrey.shade200,
                backgroundColor: Colors.blueGrey,
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget likeButton() {
    return LikeButton(
      countPostion: CountPostion.bottom,
      crossAxisAlignment: CrossAxisAlignment.center,
      size: 30,
      likeCount: 0,
      circleColor: const CircleColor(start: Colors.red, end: Colors.red),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: Colors.red,
        dotSecondaryColor: Colors.red,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          FontAwesomeIcons.heart,
          color: isLiked ? Colors.red : Colors.white,
          size: 30,
        );
      },
      countBuilder: (count, isLiked, text) {
        count = widget.likes;
        var color = isLiked ? Colors.red : Colors.white;
        Widget result;
        if (count == 0) {
          result = Text(
            count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          );
        } else
          result = Text(
            count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          );
        return result;
      },
    );
  }

  Widget commentLikeButton(int commentLikes, String commentId) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: LikeButton(
        onTap: (isLiked) {
          return !isLiked
              ? likeComment(commentId, 1.toString())
              : likeComment(commentId, 0.toString());
        },
        countPostion: CountPostion.bottom,
        crossAxisAlignment: CrossAxisAlignment.center,
        size: 20,
        likeCount: widget.likes,
        circleColor: const CircleColor(start: Colors.red, end: Colors.red),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Colors.red,
          dotSecondaryColor: Colors.red,
        ),
        likeBuilder: (bool isLiked) {
          return Icon(
            FontAwesomeIcons.heartPulse,
            color: isLiked ? Colors.red : Colors.grey,
            size: 15,
          );
        },
        countBuilder: (count, isLiked, text) {
          var color = isLiked ? Colors.red : Colors.grey;
          Widget result;
          if (commentLikes == 0) {
            result = Text(
              commentLikes.toString(),
              style: TextStyle(color: color),
            );
          } else
            result = Text(
              commentLikes.toString(),
              style: TextStyle(color: color),
            );
          return result;
        },
      ),
    );
  }

  Widget commentsSection() {
    List<Widget> commentsWidgetList = [];
    commentsList.forEach((element) => commentsWidgetList.add(
          Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              element.avatar==null?
                                profileUrl + element.avatar.toString():avatarPlaceholder)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        element.name.toString(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: Text(
                        element.comment.toString(),
                        textAlign: TextAlign.start,
                      )),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Expanded(
                            child: commentLikeButton(
                                element.commentLikeCounter!,
                                element.id.toString())),
                      )
                    ],
                  ),
                 const Divider(
                    thickness: 1,
                  )
                ],
              )),
        ));
    return Container(
      child: Column(
        children: commentsWidgetList,
      ),
    );
  }

  void getComments(String videoId) async {
    var comments = await controller.getVideoComments(videoId: videoId);
    if (mounted) {
      setState(() {
        print(comments.message);
        if (comments.data != null) {
          commentsList = comments.data!;

          showBarModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: commentsSection(),
                    ),
                    TextField()
                  ],
                );
              });
        }
      });
    }
  }

  Future<bool> likeComment(String commentId, String isLiked) async {
    var likeCommentData =
        await controller.likeComment(commentId: commentId, isLiked: isLiked);
    if (likeCommentData.status == true) {
      Get.snackbar('Updated Successfully', 'You Liked this comment');
      isliked.value = true;
    } else if (likeCommentData.error == true) {
      Get.snackbar('Something went wrong', likeCommentData.message.toString());
      isliked.value = false;
    }

    return isliked.value;
  }
}
