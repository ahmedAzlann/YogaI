import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/MainGoalSelectionPage.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  @override
  _UserTypeSelectionScreenState createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String selectedType = "General"; // Default
  int currentPage = 1;
  int totalPages = 6;

  Future<void> skipfunction() async {
    final prefs = await SharedPreferences.getInstance();

    // If user is already logged in, skip re-signing
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => Homepage());
  }

  void goToNextScreen() {
    print("Selected User Type: $selectedType");
    Get.to(() => MainGoalSelectionScreen(selectedType));
  }

  AppBar buildProgressAppBar(
      BuildContext context,
      int currentPage,
      int totalPages,
      VoidCallback onBack,
      VoidCallback onSkip,
      ) {
    return AppBar(
      leading: currentPage > 0
          ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
      )
          : SizedBox(width: 48),
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text("Skip", style: TextStyle(color: Colors.black)),
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
      appBar: buildProgressAppBar(
        context,
        currentPage,
        totalPages,
            () => Navigator.pop(context),
        skipfunction,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select your type",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "This helps us recommend exercises suited for you",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40),

              // Option Cards
              _buildOptionCard(
                label: "General User",
                icon: Icons.person,
                type: "General",
              ),
              SizedBox(height: 20),
              _buildOptionCard(
                label: "Disabled User",
                icon: Icons.accessible,
                type: "Disabled",
              ),

              Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: goToNextScreen,
                child: Text(
                  "NEXT",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String label,
    required IconData icon,
    required String type,
  }) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() => selectedType = type);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: isSelected ? Colors.white : Colors.black),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
