import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogai/pages/UserDataCollectionPages/ActivityLevelSelectionPage.dart';
import 'package:yogai/pages/NavPages/DiscoverPage.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/GenderSelectionPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/GeneratingPlanPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/MainGoalSelectionPage.dart';
import 'package:yogai/pages/NavPages/ReportPage.dart';
import 'package:yogai/pages/NavPages/SettingsPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/PhysicalStatsInputScreen.dart';
import 'package:yogai/pages/SplashScreen.dart';
import 'package:yogai/pages/UserDataCollectionPages/PlanReadyPage.dart';
import 'package:yogai/pages/UserDataCollectionPages/UserTypeSelection.dart';
import 'package:yogai/pages/UserDataCollectionPages/WeeklyGoalSelectionPage.dart';
//flutter packages
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // or light
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/GenderSelectionScreen': (context) => GenderSelectionScreen(),
        '/HomePage': (context) => Homepage(),
        '/UserTypeSelectionScreen': (context) => UserTypeSelectionScreen(),
        '/Discoverpage': (context) => Discoverpage(),
        '/Reportpage': (context) => Reportpage(),
        '/Settingspage': (context) => SettingsPage(),
        '/MainGoalSelectionPage': (context) => MainGoalSelectionScreen(),
        '/ActivityLevelSelectionPage': (context) => ActivityLevelSelectionScreen(),
        '/WeeklyGoalSelectionPage': (context) => WeeklyGoalSelectionPage(),
        '/PhysicalStatsInputScreen': (context) => PhysicalStatsInputScreen(),
        '/GeneratingPlanPage': (context) => GeneratingPlanScreen(),
        '/PlanReadyPage': (context) => PlanReadyScreen()
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
