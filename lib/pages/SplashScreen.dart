import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/UserDataCollectionPages/GenderSelectionPage.dart';
import '../pages/HomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;
  bool onboardingDone = false;
  User? user;

  @override
  void initState() {
    super.initState();
    startAppFlow();
  }

  Future<void> startAppFlow() async {
    await checkUserFlow();

    // Add delay for splash effect
    await Future.delayed(const Duration(seconds: 3));

    if (user != null && onboardingDone) {
      Get.offAll(() => Homepage());
    } else {
      Get.offAll(() => GenderSelectionScreen());
    }
  }

  Future<void> checkUserFlow() async {
    prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool('onboarding_done') ?? false;
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/womenSitting.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                "YogaAI",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Harness Energy. Conquer Limits. Elevate Life.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
