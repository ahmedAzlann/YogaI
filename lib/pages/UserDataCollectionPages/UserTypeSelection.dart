import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:yogai/pages/HomePage.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  @override
  _UserTypeSelectionScreenState createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String selectedType = "General"; // Default selection
  int currentPage = 1;
  int totalPages = 6;


  void goToNextScreen() {
    print("Selected User Type: $selectedType");
    Navigator.pushNamed(context, '/MainGoalSelectionPage');
    // TODO: Navigate to next data collection page (Focus Area Selection)
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
      backgroundColor: Colors.white,
      appBar: buildProgressAppBar(
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedType = "General";
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: selectedType == "General" ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 40, color: selectedType == "General" ? Colors.white : Colors.black),
                      SizedBox(width: 20),
                      Text(
                        "General User",
                        style: TextStyle(
                          fontSize: 20,
                          color: selectedType == "General" ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedType = "Disabled";
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selectedType == "Disabled" ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.accessible, size: 40, color: selectedType == "Disabled" ? Colors.white : Colors.black),
                      SizedBox(width: 20),
                      Text(
                        "Disabled User",
                        style: TextStyle(
                          fontSize: 20,
                          color: selectedType == "Disabled" ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

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
            ],
          ),
        ),
      ),
    );
  }
}
