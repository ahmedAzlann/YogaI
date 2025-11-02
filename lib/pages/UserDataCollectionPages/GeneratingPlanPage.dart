import 'dart:async';

import 'package:flutter/material.dart';

class GeneratingPlanScreen extends StatefulWidget {
  @override
  _GeneratingPlanScreenState createState() => _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends State<GeneratingPlanScreen> {
  double progress = 0.37;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/PlanReadyPage');
    });
  } // Example static progress value (37%)



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "GENERATING THE PLAN FOR YOU",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Preparing your plan based on your goal...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                    Center(
                      child: Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Text(
                "✓ Analyze your body: 5ft 9in, 165.0lb",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "⟳ Adjust your fitness level: Intermediate",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
