// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/SplashScreen.dart';
import 'package:yogai/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Local Notifications
  await NotificationService.init();

  // Transparent status bar (premium look)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Optional: Lock to portrait
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'YogAI',
      debugShowCheckedModeBanner: false,

      // THIS IS ALL YOU NEED — NOTHING ELSE
      home: const SplashScreen(),

      // Beautiful fade transitions by default
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      getPages: [
        // Optional: only if you ever use Get.toNamed('/home')
        GetPage(name: '/home', page: () => const Homepage()),
      ],

      // Optional: Global theme (add later if you want)
      theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
    );
  }
}
