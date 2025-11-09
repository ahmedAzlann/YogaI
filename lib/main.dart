import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// Pages
import 'package:yogai/pages/SplashScreen.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/NavPages/DiscoverPage.dart';
import 'package:yogai/pages/NavPages/ReportPage.dart';
import 'package:yogai/pages/NavPages/SettingsPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/GenderSelectionPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/UserTypeSelection.dart';
import 'package:yogai/pages/UserDataCollectionPages/MainGoalSelectionPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/ActivityLevelSelectionPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/WeeklyGoalSelectionPage.dart';
import 'package:yogai/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  await NotificationService.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/GenderSelectionScreen': (context) => GenderSelectionScreen(),
        '/HomePage': (context) => Homepage(),
        '/UserTypeSelectionScreen': (context) => UserTypeSelectionScreen(),
        '/Discoverpage': (context) => Discoverpage(),
        '/Reportpage': (context) => Reportpage(),
        '/Settingspage': (context) => SettingsPage(),
         },
    );
  }
}
