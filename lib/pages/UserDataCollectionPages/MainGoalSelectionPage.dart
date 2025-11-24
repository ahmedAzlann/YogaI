// lib/pages/UserDataCollectionPages/MainGoalSelectionScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogai/widgets/theme.dart';
import 'package:yogai/pages/UserDataCollectionPages/ActivityLevelSelectionPage.dart';

class MainGoalSelectionScreen extends StatefulWidget {
  final String usertype;
  const MainGoalSelectionScreen(this.usertype, {super.key});

  @override
  State<MainGoalSelectionScreen> createState() =>
      _MainGoalSelectionScreenState();
}

class _MainGoalSelectionScreenState extends State<MainGoalSelectionScreen> {
  late String usertype;
  String selectedGoal = "";
  final int currentPage = 2;
  final int totalPages = 6;

  final List<Map<String, String>> goals = [
    {"title": "Be Flexible", "image": "images/onboarding/seated.png"},
    {"title": "Stay Healthy", "image": "images/onboarding/core.png"},
    {"title": "Lose Weight", "image": "images/onboarding/twisting.png"},
    {"title": "Skill Improvement", "image": "images/onboarding/lback.png"},
  ];

  @override
  void initState() {
    super.initState();
    usertype = widget.usertype;
  }

  void goToNextScreen() {
    if (selectedGoal.isEmpty) {
      Get.snackbar(
        "Hold on!",
        "Please select your main goal to continue",
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }
    Get.to(
      () => ActivityLevelSelectionScreen(
        usertype: usertype,
        selectedGoal: selectedGoal,
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

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Your main goal?",
                  style:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: YogAITheme.darkText,
                        height: 1.1,
                      ) ??
                      const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: YogAITheme.darkText,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),

              // PERFECT 2×2 GRID — SAME AS YOUR OLD BEAUTIFUL DESIGN
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.78, // Perfect square-ish card
                  ),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final bool isSelected = selectedGoal == goal["title"];

                    return GestureDetector(
                      onTap: () =>
                          setState(() => selectedGoal = goal["title"]!),
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
                            // IMAGE — FULLY VISIBLE, NO CROPPING
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
                                    goal["image"]!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.self_improvement,
                                      size: 60,
                                      color: Colors.grey,
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
                                    goal["title"]!,
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

              // NEXT Button — Always visible, no overflow
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
