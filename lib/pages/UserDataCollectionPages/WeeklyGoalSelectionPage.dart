import 'package:flutter/material.dart';
import 'package:yogai/pages/HomePage.dart';

class WeeklyGoalSelectionPage extends StatefulWidget {



  @override
  _WeeklyGoalSelectionPageState createState() => _WeeklyGoalSelectionPageState();
}

class _WeeklyGoalSelectionPageState extends State<WeeklyGoalSelectionPage> {
  late int currentPage = 4;
  int totalPages = 6;

  int selectedSessions = 3;  // Default selection
  String selectedFirstDay = "SUNDAY";

  List<String> weekDays = [
    "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"
  ];

  void goToNextScreen() {
    print("Weekly Goal: $selectedSessions, First day: $selectedFirstDay");
    Navigator.pushNamed(context, '/PhysicalStatsInputScreen');
    // TODO: Navigate to next screen (Physical Stats Input Screen)
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

  void skipDataCollection() {
    print("Skip pressed → Go to Home Screen");
    // TODO: Navigate directly to Home Screen
  }

  void goBack() {
    Navigator.pop(context);
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
                "Set your weekly goal",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "We recommend at least 3 days for a better result.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30),

              // Weekly Goal Buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(7, (index) {
                  int dayCount = index + 1;
                  bool isSelected = selectedSessions == dayCount;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSessions = dayCount;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$dayCount",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 40),

              Text(
                "First day of the week",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Dropdown for first day
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedFirstDay,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: weekDays.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day, style: TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFirstDay = value!;
                    });
                  },
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

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
