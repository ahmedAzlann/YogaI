// lib/pages/UserDataCollectionPages/WeeklyGoalSelectionPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/PhysicalStatsInputScreen.dart';
import 'package:yogai/widgets/theme.dart';

class WeeklyGoalSelectionPage extends StatefulWidget {
  final String usertype;
  final String selectedGoal;
  final String selectedActivityLevel;

  const WeeklyGoalSelectionPage({
    super.key,
    required this.usertype,
    required this.selectedGoal,
    required this.selectedActivityLevel,
  });

  @override
  State<WeeklyGoalSelectionPage> createState() =>
      _WeeklyGoalSelectionPageState();
}

class _WeeklyGoalSelectionPageState extends State<WeeklyGoalSelectionPage> {
  late String usertype;
  late String selectedGoal;
  late String selectedActivityLevel;

  final int currentPage = 4;
  final int totalPages = 6;
  int selectedSessions = 3;

  @override
  void initState() {
    super.initState();
    usertype = widget.usertype;
    selectedGoal = widget.selectedGoal;
    selectedActivityLevel = widget.selectedActivityLevel;
  }

  void goToNextScreen() {
    Get.to(
      () => PhysicalStatsInputScreen(
        usertype: usertype,
        selectedGoal: selectedGoal,
        selectedActivityLevel: selectedActivityLevel,
        selectedSessions: selectedSessions,
        selectedFirstDay: "SUNDAY", // You can make this dynamic later if needed
      ),
    );
  }

  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => const Homepage());
  }

  PreferredSizeWidget buildProgressAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation(YogAITheme.progressColor),
      ),
      actions: [
        TextButton(
          onPressed: skipfunction,
          child: const Text("Skip", style: TextStyle(color: Colors.black87)),
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(decoration: YogAITheme.onboardingGradient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildProgressAppBar(),
      body: Container(
        decoration: YogAITheme.onboardingGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 70),

                // Title
                Text(
                  "How many days per week?",
                  style:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: YogAITheme.darkText,
                      ) ??
                      const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: YogAITheme.darkText,
                      ),
                ),

                const SizedBox(height: 60),

                // GIANT ANIMATED NUMBER — BACK AND BETTER
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 3, end: selectedSessions),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        color: YogAITheme.nextButtonColor,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: YogAITheme.nextButtonColor.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  "days per week",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 60),

                // PREMIUM CUSTOM SLIDER
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: YogAITheme.nextButtonColor,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: YogAITheme.nextButtonColor,
                    overlayColor: YogAITheme.nextButtonColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 18,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 36,
                    ),
                    trackHeight: 10,
                  ),
                  child: Slider(
                    value: selectedSessions.toDouble(),
                    min: 3,
                    max: 7,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        selectedSessions = value.round();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Day Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    final day = i + 3;
                    final isSelected = day == selectedSessions;
                    return Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? YogAITheme.nextButtonColor
                            : Colors.black54,
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // NEXT Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: YogAITheme.nextButtonColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 12,
                      shadowColor: YogAITheme.nextButtonColor.withOpacity(0.5),
                    ),
                    onPressed: goToNextScreen,
                    child: const Text(
                      "NEXT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
