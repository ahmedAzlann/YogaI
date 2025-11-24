// lib/pages/UserDataCollectionPages/GenderSelectionScreen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/widgets/theme.dart'; // Make sure this path is correct
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/UserTypeSelection.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  final int totalPages = 6;
  String selectedGender = "Male";

  final List<Map<String, dynamic>> genderOptions = [
    {
      "gender": "Male",
      "image": "images/male.png",
      "gradient": const [Color(0xFFFF8A65), Color(0xFFFF7043)],
    },
    {
      "gender": "Female",
      "image": "images/female.png",
      "gradient": const [Color(0xFFFFD180), Color(0xFFFFB74D)],
    },
  ];

  // Reusable Progress AppBar using your theme
  PreferredSizeWidget buildProgressAppBar() {
    return AppBar(
      leading: currentPage > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            )
          : const SizedBox(width: 48),
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation(YogAITheme.progressColor),
      ),
      actions: [
        TextButton(
          onPressed: skipfunction,
          child: const Text("Skip", style: TextStyle(color: Colors.black87)),
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: YogAITheme.onboardingGradient,
      ), // Your beautiful gradient background!
    );
  }

  // Skip + Anonymous Sign In + Mark Onboarding Done
  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signInAnonymously();
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => const Homepage());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows gradient to go behind AppBar
      appBar: buildProgressAppBar(),
      body: Container(
        decoration: YogAITheme.onboardingGradient, // Full-screen gradient
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40), // Space after AppBar
                // Title
                Text(
                  "What's your gender?",
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
                const SizedBox(height: 8),
                Text(
                  "Let us know you better",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Swipeable Gender Cards (Your Beautiful Design is Back!)
                // FULL PERSON VISIBLE — FINAL FIXED VERSION
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: genderOptions.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectedGender = genderOptions[index]['gender'];
                      });
                    },
                    itemBuilder: (context, index) {
                      final gender = genderOptions[index];
                      final bool isSelected =
                          selectedGender == gender['gender'];

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedGender = gender['gender']);
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20 : 40,
                            vertical: isSelected ? 0 : 30,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? gender['gradient']
                                      : [Colors.grey[300]!, Colors.grey[400]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isSelected
                                                ? (gender['gradient']
                                                      as List<Color>)[1]
                                                : Colors.black26)
                                            .withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Padding(
                                // MAGIC LINE: Adds breathing room inside the card
                                padding: const EdgeInsets.all(32),
                                child: Image.asset(
                                  gender['image'],
                                  fit:
                                      BoxFit.contain, // FULL IMAGE, NO CROPPING
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 180,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Selected Gender Label (Bigger & Bolder)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    selectedGender,
                    key: ValueKey(selectedGender),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: selectedGender == "Male"
                          ? const Color(0xFFFF7043)
                          : const Color(0xFFFFB74D),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // NEXT Button — Premium Look
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
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
                    onPressed: () {
                      Get.to(() => const UserTypeSelectionScreen());
                    },
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

                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
