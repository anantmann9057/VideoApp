import 'dart:convert';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:video_app/models/comment_like_response_model.dart';
import 'package:video_app/models/video_comments_model.dart';
import 'package:video_app/models/video_list_model.dart';

class DataController extends GetxController with StateMixin<dynamic> {
  var isButtonEnabled = false.obs;
  var isOtpVisible = false.obs;
  var count = 0.obs;
  var user = ''.obs;
  var selectedIndex = 0.obs;
  var city = 'jaipur'.obs;
  var address = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var pincode = ''.obs;

  bool isProductsLoading = true;
  bool isLoading = true;

  var cartCount = 0.obs;

  var isCategoryLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    getVideos();
  }

  Future<void> generateWaveForm() async {
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    FFmpegKitConfig.getSafParameterForWrite(directory)
        .then((value) async {
      await FFmpegKit.execute(
              'ffmpeg -i $directory/test.mp3 $directory/output.wav')
          .then((session) async {
        var logs = await session.getLogs();
        print(logs.last.getMessage()+logs.last.getLevel().toString()+logs.last.getSessionId().toString());
      });
    });
  }

  Future<void> generateFile(String filePath, String fileName) async {
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DCIM);

    FFmpegKitConfig.getSafParameterForWrite(filePath).then((safUrl) async {
      //
      //         '-i $directory/hello.mp4 -i ${value!.path.toString()} -i $downloadsDirectory/thrilllogo.png -filter_complex "[2:v]scale=250x200,[0:v]overlay=0:0,[1:v]overlay=0:0" $safUrl.mp4')
      await FFmpegKit.execute(
              '-i $directory/hellobyebye.mp4 -i $filePath -filter_complex "[0:v]overlay=0:0" -vcodec libx265  -preset ultrafast -s 800x600 $directory/$fileName.mp4')
          .then((value) async {
        Get.snackbar("Successfull!!", 'Video Converted Successfully Yay!');
        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DCIM);

        File file = File('$directory/hellobyebye.mp4');
        await file.delete();
      });
    });
  }

  Future<VideoListModel> getVideos() async {
    isLoading = true;
    Map data = {};
    var body = json.encode(data);

    var response = await http
        .get(
          Uri.parse('https://9starinfosolutions.com/thrill/api/video/list'),
        )
        .timeout(const Duration(seconds: 60));

    try {
      isLoading = false;
      update();
      return VideoListModel.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading = false;
      update();
      return VideoListModel.fromJson(json.decode(response.body));
    }
  }

  Future<VideoCommentsModel> getVideoComments({String videoId = ''}) async {
    isLoading = true;
    Map data = {};
    var body = json.encode(data);

    var response = await http.post(
        Uri.parse('https://9starinfosolutions.com/thrill/api/video/comments'),
        body: {
          "video_id": videoId,
        },
        headers: {
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYWQzNDJlNTIyZjJhNDY2MmY4N2FiMjVlNDJkYjM5YzYxZTMwZDM1N2U2N2RlN2MwYjUwNjc4ZjU3MDVkYTExOTdjNzI5Yjg0NDdmMzA1ZDgiLCJpYXQiOjE2NTI3ODI5NjYuNjI0NywibmJmIjoxNjUyNzgyOTY2LjYyNDcwNCwiZXhwIjoxNjg0MzE4OTY2LjYxNzYxMSwic3ViIjoiMTIwIiwic2NvcGVzIjpbXX0.h6RuDsOLNiCJFiv--klPwJRUt8OQ-UOu2Dlw_rZDQrt6rEYNEGgRqerNsNWa1L1QBOA2U4hMtt_vV9pmKMeciWeai9CqebGFRPHSQhoPQmkoZEFAi2IV_ZhtFrhpcMsEEJYCDlL-VBYW5fjOAAdXHchIlAwCaR-9sSAGRDEqSkJjDQ5ARiq4lv2Z-w8nC4qOmuvtaEtKzBXs5iHLhBPso0RaDOwEXafb_bqojtgyq8Jd-GNv92VvUVwe_gX3uHNUSBabIm6tlKvxllk_i5iJ-Pc7Q53L1_T5mDrZaoj9tYRrOWki6ehvI4-bG98hPJRj4BiQfzLTz6fcBWQYEoz7gXOYGbvrdcmOf6b7uBzDyDrPFstA14UFwf0eftREFCyVG9YNTddj9BMsCBFI14EfBjFihBN1K9X-BqYrWTnimxNKrKUNW4ur8MTRCT1lyT_VjHhr3jb5CjbqpJm5452a-uMbR4SMKb-qk2-rEcnfAL-tnJMXLOxlC5sBt4t7ZEmrPrZHaRTQUGZ6F7n86DmlPXtUIJGXxV5CatAffCly1Ny5SI1QYrp01mb-Kf3EdYjVY_murs1sg9FEriVEIurQSq395l6MoAE_TyZDO-dBCqE6NSLzaV7xEw322Ir-l4GJakG39Qp0uu5B1mVwWTf1ZWo_gYNKZ-v6pggXnoX3OZs",
          "Accept": "application/json"
        }).timeout(const Duration(seconds: 60));
    try {
      isLoading = false;
      update();
      return VideoCommentsModel.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading = false;
      update();
      return VideoCommentsModel.fromJson(json.decode(response.body));
    }
  }

  Future<CommentLikeResponseModel> likeComment(
      {String commentId = '', String isLiked = ''}) async {
    isLoading = true;
    Map data = {};
    var body = json.encode(data);

    var response = await http.post(
        Uri.parse(
            'https://9starinfosolutions.com/thrill/api/video/comment-like'),
        body: {
          "comment_id": commentId,
          "is_like": isLiked
        },
        headers: {
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYWQzNDJlNTIyZjJhNDY2MmY4N2FiMjVlNDJkYjM5YzYxZTMwZDM1N2U2N2RlN2MwYjUwNjc4ZjU3MDVkYTExOTdjNzI5Yjg0NDdmMzA1ZDgiLCJpYXQiOjE2NTI3ODI5NjYuNjI0NywibmJmIjoxNjUyNzgyOTY2LjYyNDcwNCwiZXhwIjoxNjg0MzE4OTY2LjYxNzYxMSwic3ViIjoiMTIwIiwic2NvcGVzIjpbXX0.h6RuDsOLNiCJFiv--klPwJRUt8OQ-UOu2Dlw_rZDQrt6rEYNEGgRqerNsNWa1L1QBOA2U4hMtt_vV9pmKMeciWeai9CqebGFRPHSQhoPQmkoZEFAi2IV_ZhtFrhpcMsEEJYCDlL-VBYW5fjOAAdXHchIlAwCaR-9sSAGRDEqSkJjDQ5ARiq4lv2Z-w8nC4qOmuvtaEtKzBXs5iHLhBPso0RaDOwEXafb_bqojtgyq8Jd-GNv92VvUVwe_gX3uHNUSBabIm6tlKvxllk_i5iJ-Pc7Q53L1_T5mDrZaoj9tYRrOWki6ehvI4-bG98hPJRj4BiQfzLTz6fcBWQYEoz7gXOYGbvrdcmOf6b7uBzDyDrPFstA14UFwf0eftREFCyVG9YNTddj9BMsCBFI14EfBjFihBN1K9X-BqYrWTnimxNKrKUNW4ur8MTRCT1lyT_VjHhr3jb5CjbqpJm5452a-uMbR4SMKb-qk2-rEcnfAL-tnJMXLOxlC5sBt4t7ZEmrPrZHaRTQUGZ6F7n86DmlPXtUIJGXxV5CatAffCly1Ny5SI1QYrp01mb-Kf3EdYjVY_murs1sg9FEriVEIurQSq395l6MoAE_TyZDO-dBCqE6NSLzaV7xEw322Ir-l4GJakG39Qp0uu5B1mVwWTf1ZWo_gYNKZ-v6pggXnoX3OZs",
          "Accept": "application/json"
        }).timeout(const Duration(seconds: 60));
    try {
      isLoading = false;
      update();
      return CommentLikeResponseModel.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading = false;
      update();
      return CommentLikeResponseModel.fromJson(json.decode(response.body));
    }
  }
}
