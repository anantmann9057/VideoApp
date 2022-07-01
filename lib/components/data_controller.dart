import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:video_app/components/constant.dart';
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
    determinePosition();
    getVideos();
  }

  Future<SharedPreferences> prefs() async {
    return await SharedPreferences.getInstance();
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

  void checkLogin() async {
    var sharedPreferences = await prefs();
    city.value = sharedPreferences.getString('city').toString();
    address.value = sharedPreferences.getString("address").toString();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      placemarks.forEach((element) {
        pincode.value = element.postalCode.toString();

        city.value = element.locality.toString();
        address.value =
            '${element.name.toString()}, ${element.locality.toString()}, ${element.postalCode.toString()}';
      });
    } catch (e) {
      print(e);
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }
}
