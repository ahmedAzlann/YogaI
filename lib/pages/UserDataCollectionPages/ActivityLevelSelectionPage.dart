import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/WeeklyGoalSelectionPage.dart';

class ActivityLevelSelectionScreen extends StatefulWidget {
  final String usertype;
  final String selectedGoal;

  const ActivityLevelSelectionScreen({
    Key? key,
    required this.usertype,
    required this.selectedGoal,
  }) : super(key: key);

  @override
  _ActivityLevelSelectionScreenState createState() => _ActivityLevelSelectionScreenState();
}

class _ActivityLevelSelectionScreenState extends State<ActivityLevelSelectionScreen> {
  late String usertype;
  late String selectedGoal;
  String selectedActivityLevel = "";
  int currentPage = 3;
  int totalPages = 6;

  List<String> activityLevels = [
    "Sedentary",
    "Lightly Active",
    "Active",
    "Very Active",
  ];

  @override
  void initState() {
    super.initState();
    usertype = widget.usertype;
    selectedGoal = widget.selectedGoal;
  }

  void goToNextScreen() {
    if (selectedActivityLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your activity level to proceed.")),
      );
      return;
    }

    print("User Type: $usertype");
    print("Selected Goal: $selectedGoal");
    print("Activity Level: $selectedActivityLevel");

    Get.to(() => WeeklyGoalSelectionPage(
      usertype: usertype,
      selectedGoal: selectedGoal,
      selectedActivityLevel: selectedActivityLevel,
    ));
  }

  AppBar buildProgressAppBar() {
    return AppBar(
      leading: currentPage > 0
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      )
          : const SizedBox(width: 48),
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
      ),
      actions: [
        TextButton(
          onPressed: skipfunction,
          child: const Text("Skip", style: TextStyle(color: Colors.black)),
        ),
      ],
      backgroundColor: Colors.grey[100],
      elevation: 0,
    );
  }

  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => Homepage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildProgressAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your activity level?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tell us how active you are in daily life",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: activityLevels.length,
                  itemBuilder: (context, index) {
                    String level = activityLevels[index];
                    bool isSelected = selectedActivityLevel == level;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedActivityLevel = level;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: goToNextScreen,
                child: const Text(
                  "NEXT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
