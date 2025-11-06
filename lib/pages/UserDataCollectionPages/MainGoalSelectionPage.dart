import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/ActivityLevelSelectionPage.dart';

class MainGoalSelectionScreen extends StatefulWidget {
  final String usertype;

  const MainGoalSelectionScreen(this.usertype, {Key? key}) : super(key: key);

  @override
  _MainGoalSelectionScreenState createState() => _MainGoalSelectionScreenState();
}

class _MainGoalSelectionScreenState extends State<MainGoalSelectionScreen> {
  late String usertype;
  String selectedGoal = "";
  int currentPage = 2;
  int totalPages = 6;

  List<String> goals = [
    "Increase Flexibility",
    "Improve Mental Health",
    "Improve Balance",
    "Relaxation & Calmness"
  ];

  @override
  void initState() {
    super.initState();
    usertype = widget.usertype;
  }

  void goToNextScreen() {
    if (selectedGoal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a goal to proceed.")),
      );
      return;
    }

    print("User Type: $usertype");
    print("Selected Goal: $selectedGoal");

    // Navigate to the next onboarding page
    Get.to(() => ActivityLevelSelectionScreen(
        usertype:usertype,
        selectedGoal: selectedGoal
    ));
  }

  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => Homepage());
  }

  AppBar buildProgressAppBar(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildProgressAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your main goal?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose the purpose of your yoga practice",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    String goal = goals[index];
                    bool isSelected = selectedGoal == goal;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGoal = goal;
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
                          goal,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
