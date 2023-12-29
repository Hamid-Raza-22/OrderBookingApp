import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'Views/splash_screen.dart';


//Flutter Background

final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "Background Tracking",
  notificationText: "Background Notification",
  notificationImportance: AndroidNotificationImportance.Default,
  notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable'), // Default is ic_launcher from folder mipmap
);


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground.initialize(androidConfig: androidConfig);
  await FlutterBackground.enableBackgroundExecution();
  await Firebase.initializeApp();
  runApp(
      const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen())

  );

}
