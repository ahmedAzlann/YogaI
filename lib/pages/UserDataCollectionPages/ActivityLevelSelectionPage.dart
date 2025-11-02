import 'package:flutter/material.dart';
import 'package:yogai/pages/HomePage.dart';

class ActivityLevelSelectionScreen extends StatefulWidget {
  @override
  _ActivityLevelSelectionScreenState createState() => _ActivityLevelSelectionScreenState();
}

class _ActivityLevelSelectionScreenState extends State<ActivityLevelSelectionScreen> {
  String selectedActivityLevel = "";  // No default
  int currentPage = 3;
  int totalPages = 6;
  List<String> activityLevels = [
    "Sedentary",
    "Lightly Active",
    "Active",
    "Very Active",
  ];

  void goToNextScreen() {
    if (selectedActivityLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select your activity level to proceed.")),
      );
      return;
    }

    print("Selected Activity Level: $selectedActivityLevel");
    // TODO: Navigate to next screen (Weekly Goal Screen)
    Navigator.pushNamed(context, '/WeeklyGoalSelectionPage');
  }

  AppBar buildProgressAppBar(BuildContext context, int currentPage, int totalPages, VoidCallback onBack, VoidCallback onSkip) {
    return AppBar(
      leading: currentPage > 0 ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
      ) : SizedBox(width: 48), // Empty space on first page
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
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:buildProgressAppBar(
      context,
      currentPage,
      totalPages,
          () => Navigator.pop(context),  // Back button
          () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Homepage()),
              (route) => false,
        );
      },  // Skip button
    ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What is your activity level?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Tell us how active you are in daily life",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30),

              // Activity Level Options
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
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(20),
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

              // NEXT Button
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
