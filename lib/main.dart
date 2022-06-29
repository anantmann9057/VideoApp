import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_app/components/data_controller.dart';
import 'package:video_app/components/databindings.dart';
import 'package:video_app/home/home_screen.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DataController controller = DataController();
  SharedPreferences prefs = await controller.prefs();
  cameras = await availableCameras();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialBinding: DataBindings(),
    theme: ThemeData.light().copyWith(
      primaryColor: const Color(0xFF11447F),
      appBarTheme: const AppBarTheme(color: Colors.blueGrey),
    ),
    home: const HomeScreen(),
  ));
}
