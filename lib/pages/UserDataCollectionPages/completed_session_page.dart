import 'package:flutter/material.dart';

import '../NavPages/ReportPage.dart';

class SessionCompletedScreen extends StatelessWidget {
  final String programName;
  final int exerciseCount;
  final double calories;
  final Duration time;

  const SessionCompletedScreen({
    super.key,
    required this.programName,
    required this.exerciseCount,
    required this.calories,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top back button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 600),
                      pageBuilder: (_, animation, __) => const Reportpage(),
                      transitionsBuilder: (_, animation, __, child) {
                        final offset = Tween<Offset>(
                          begin: Offset(-0.2, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));

                        return SlideTransition(
                          position: offset,
                          child: child,
                        );
                      },
                    ),
                        (route) => false,
                  );
                },


              ),
            ),

            // Big title image (replace with your asset)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/finish.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nice, you’ve completed the exercise!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    programName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoBox("Exercises", exerciseCount.toString()),
                      _infoBox("Calories", calories.toStringAsFixed(1)),
                      _infoBox("Time", "${time.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')}"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "How do you feel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _emoji("😵", "Too hard"),
                      _emoji("🙂", "Just right"),
                      _emoji("😴", "Too easy"),
                    ],
                  ),




                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _emoji(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 40)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.black54)),
      ],
    );
  }
}
