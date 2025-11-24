// lib/pages/UserDataCollectionPages/ActivityLevelSelectionScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogai/widgets/theme.dart';
import 'package:yogai/pages/UserDataCollectionPages/WeeklyGoalSelectionPage.dart';

class ActivityLevelSelectionScreen extends StatefulWidget {
  final String usertype;
  final String selectedGoal;

  const ActivityLevelSelectionScreen({
    super.key,
    required this.usertype,
    required this.selectedGoal,
  });

  @override
  State<ActivityLevelSelectionScreen> createState() =>
      _ActivityLevelSelectionScreenState();
}

class _ActivityLevelSelectionScreenState
    extends State<ActivityLevelSelectionScreen> {
  late String usertype;
  late String selectedGoal;
  String selectedActivityLevel = "";
  final int currentPage = 3;
  final int totalPages = 6;

  final List<Map<String, String>> activityLevels = [
    {"title": "Sedentary", "image": "images/onboarding/seated.png"},
    {"title": "Lightly Active", "image": "images/onboarding/core.png"},
    {"title": "Active", "image": "images/onboarding/armbalance.png"},
    {"title": "Very Active", "image": "images/onboarding/digestion.png"},
  ];

  @override
  void initState() {
    super.initState();
    usertype = widget.usertype;
    selectedGoal = widget.selectedGoal;
  }

  void goToNextScreen() {
    if (selectedActivityLevel.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Please select your activity level",
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    Get.to(
      () => WeeklyGoalSelectionPage(
        usertype: usertype,
        selectedGoal: selectedGoal,
        selectedActivityLevel: selectedActivityLevel,
      ),
    );
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
        minHeight: 6,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.offAllNamed('/home'),
          child: const Text(
            "Skip",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Title - Exactly like your old design
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "How active are you?",
                  style:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: YogAITheme.darkText,
                        height: 1.1,
                      ) ??
                      const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: YogAITheme.darkText,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),

              // PERFECT 2×2 GRID — IDENTICAL TO YOUR OLD DESIGN
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio:
                        0.78, // Same ratio as your old perfect cards
                  ),
                  itemCount: activityLevels.length,
                  itemBuilder: (context, index) {
                    final level = activityLevels[index];
                    final bool isSelected =
                        selectedActivityLevel == level["title"];

                    return GestureDetector(
                      onTap: () => setState(
                        () => selectedActivityLevel = level["title"]!,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? YogAITheme.nextButtonColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? YogAITheme.nextButtonColor.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: isSelected ? 30 : 18,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // IMAGE — FULLY VISIBLE
                            Expanded(
                              flex: 7,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    level["image"]!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.directions_run,
                                      size: 70,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // TITLE
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    level["title"]!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : YogAITheme.darkText,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // NEXT Button — Perfectly placed
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 30, 40, 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YogAITheme.nextButtonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 16,
                    shadowColor: YogAITheme.nextButtonColor.withOpacity(0.6),
                  ),
                  onPressed: goToNextScreen,
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
