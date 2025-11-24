// lib/pages/SplashScreen.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/UserDataCollectionPages/GenderSelectionPage.dart';
import '../pages/HomePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;
  bool onboardingDone = false;

  @override
  void initState() {
    super.initState();
    startAppFlow();
  }

  Future<void> startAppFlow() async {
    await checkOnboardingStatus();

    // Beautiful splash delay
    await Future.delayed(const Duration(seconds: 3));

    if (onboardingDone) {
      Get.offAll(() => const Homepage());
    } else {
      Get.offAll(() => const GenderSelectionScreen());
    }
  }

  Future<void> checkOnboardingStatus() async {
    prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool('onboarding_done') ?? false;

    // Optional: Auto anonymous sign-in on first launch (recommended)
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/womenSitting.png"),
            fit: BoxFit.cover,
            opacity: 0.95,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  "YogAI",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Colors.black26,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Harness Energy. Conquer Limits. Elevate Life.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
