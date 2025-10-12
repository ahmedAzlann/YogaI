import 'package:flutter/material.dart';
import 'package:yogai/pages/HomePage.dart';
import 'package:yogai/pages/UserDataCollectionPages/UserTypeSelection.dart';

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;
  int totalPages = 6;
  String selectedGender = "Male"; // Default selection

  List<Map<String, dynamic>> genderOptions = [
    {"gender": "Male", "image": "images/male.png", "color": Colors.blue},
    {"gender": "Female", "image": "images/female.png", "color": Colors.pink},
  ];

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


  void goToHomeScreen() {
    // TODO: Replace with navigation to Home Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,   // Remove all previous routes
    );

  }

  Color getCardBackgroundColor(String gender) {
    return selectedGender == gender
        ? gender == "Male"
        ? Colors.blue
        : Colors.pink
        : Colors.grey[200]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          children: [
            SizedBox(height: 20),

            // Title
            Text(
              "What's your gender?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Let us know you better",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),

            // Swipeable Gender Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: genderOptions.length,
                onPageChanged: (index) {
                  setState(() {
                   // currentPage = index;
                    selectedGender = genderOptions[index]['gender'];
                  });
                },
                itemBuilder: (context, index) {
                  var gender = genderOptions[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = gender['gender'];
                      });
                    },
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: getCardBackgroundColor(gender['gender']),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Image.asset(
                          gender['image'],
                          width: 250,
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 30),

            // NEXT Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/UserTypeSelectionScreen');
                  // TODO: Navigate to next screen in flow
                },
                child: Text(
                  "NEXT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Screen background remains white
    );
  }
}
