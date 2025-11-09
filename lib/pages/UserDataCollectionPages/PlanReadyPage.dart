import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';

import '../../services/notification_service.dart';
import '../../services/settings_manager.dart';

class PlanReadyScreen extends StatefulWidget {
  final String usertype;
  final String selectedGoal;
  final String selectedActivityLevel;
  final int selectedSessions;
  final String selectedFirstDay;
  final double weight;
  final int heightFeet;
  final int heightInch;

  const PlanReadyScreen(
      { Key? key, required this.heightFeet, required this.heightInch, required this.weight, required this.selectedSessions, required this.selectedFirstDay, required this.selectedActivityLevel, required this.usertype, required this.selectedGoal,})
      : super(key: key);

  @override State<PlanReadyScreen> createState() => _PlanReadyScreenState();
}

class _PlanReadyScreenState extends State<PlanReadyScreen> {
  late final user;
  late final prefs;
  bool isLoading = false;
  bool isSuccess = false;

  void goToHomePage(BuildContext context) {
    pushtofirebase();
    // Navigator.pushNamedAndRemoveUntil(context, '/HomePage', (route) => false);
  }


  Future<void> pushtofirebase() async {
    setState(() => isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      user = currentUser ?? await FirebaseAuth.instance.signInAnonymously();
      await FirebaseFirestore.instance.collection('users').doc(
          user.user?.uid ?? currentUser?.uid).set({
        'weight': widget.weight,
        'activitylevel': widget.selectedActivityLevel,
        'usertype': widget.usertype,
        'goal': widget.selectedGoal,
        'sessions': widget.selectedSessions,
        'firstday': widget.selectedFirstDay,
        'heightfeet': widget.heightFeet,
        'heightinch': widget.heightInch,
      });

      prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      final time = await SettingsManager.getReminderTime();
      await NotificationService.scheduleYogaNotifications(
        widget.selectedSessions,
        widget.selectedFirstDay,
        time,
      );


      setState(() {
        isLoading = false;
        isSuccess = true;
      });

      await Future.delayed(Duration(seconds: 2));
      Get.offAll(() => Homepage());
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    }



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Text(
                    "Your plan is ready!",
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We have selected this plan that suits you best",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Image.asset("images/trainer.png", width: 150, height: 150),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FULL BODY 7X4 CHALLENGE",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Start your yoga journey to improve flexibility, balance, and mental well-being. Achieve a healthier body and a calmer mind in just 4 weeks!",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: pushtofirebase,
                    child: Text(
                      "START NOW",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => goToHomePage(context),
                    child: Text(
                      "Go to homepage",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LOADING OVERLAY
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      "Setting up your plan...",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // SUCCESS ANIMATION
          if (isSuccess)
            Container(
              color: Colors.white,
              child: Center(
                child: Lottie.asset('assets/animations/success.json',
                    repeat: false, width: 200, height: 200),

              ),
            ),
        ],
      ),
    );
    //
  }

  


  int getWeekday(String day)  {
    switch (day.toLowerCase()) {
      case "monday": return DateTime.monday;
      case "tuesday": return DateTime.tuesday;
      case "wednesday": return DateTime.wednesday;
      case "thursday": return DateTime.thursday;
      case "friday": return DateTime.friday;
      case "saturday": return DateTime.saturday;
      case "sunday": return DateTime.sunday;
      default: return DateTime.monday;
    }
  }


}