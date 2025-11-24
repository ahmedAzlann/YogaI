// lib/pages/UserDataCollectionPages/UserTypeSelectionScreen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/MainGoalSelectionPage.dart';
import 'package:yogai/widgets/theme.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  int selectedIndex = 0;
  final int currentPage = 1;
  final int totalPages = 6;

  final List<Map<String, String>> userTypes = [
    {"title": "General User", "image": "images/seated.png"},
    {"title": "Disabled User", "image": "images/onboarding/disabled.png"},
  ];

  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => const Homepage());
  }

  void goToNextScreen() {
    final selected = selectedIndex == 0 ? "General" : "Disabled";
    Get.to(() => MainGoalSelectionScreen(selected));
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
          onPressed: skipfunction,
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
              const SizedBox(height: 40),

              // Title
              Text(
                "Select your type",
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
              const SizedBox(height: 50),

              // TWO PERFECT CARDS — NO OVERFLOW, FULL IMAGES
              Expanded(
                child: Column(
                  children: List.generate(userTypes.length, (index) {
                    final item = userTypes[index];
                    final isSelected = selectedIndex == index;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: index == 0 ? 0 : 16,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? YogAITheme.nextButtonColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? YogAITheme.nextButtonColor.withOpacity(
                                          0.5,
                                        )
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: isSelected ? 35 : 20,
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
                                      top: Radius.circular(36),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Image.asset(
                                        item["image"]!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) => Icon(
                                          index == 0
                                              ? Icons.person
                                              : Icons.accessible,
                                          size: 80,
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
                                    child: Text(
                                      item["title"]!,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : YogAITheme.darkText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // NEXT Button — Always visible
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
