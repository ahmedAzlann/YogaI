import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),

            Text(
              "Last Updated: January 2025\n",
              style: TextStyle(fontSize: 16),
            ),

            Text(
              "Your privacy matters. This Privacy Policy explains how we collect, "
                  "use, store, and protect your information when you use our Yoga App.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "1. Information We Collect",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "- Personal details such as gender, activity level, weight, height.\n"
                  "- Usage data like selected sessions, first day preferences.\n"
                  "- Device information (basic analytics).\n"
                  "- Notifications settings, language preferences.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "2. How We Use Your Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "- To generate personalized yoga plans.\n"
                  "- To send reminders and motivational notifications.\n"
                  "- To improve app performance and user experience.\n"
                  "- To save your fitness preferences locally.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "3. Data Storage & Security",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "- Your data is stored securely using Firebase.\n"
                  "- We do not sell or share personal data with any third party.\n"
                  "- Only essential app services access your stored data.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "4. Notifications Permissions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "We request notification permission to send daily yoga reminders. "
                  "You may disable notifications anytime from your device settings.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "5. Third-Party Content & Media Usage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Some images and demonstration videos used in this app are sourced from "
                  "Yoga Journal. All rights belong to their respective owners. "
                  "We use them for educational and illustrative purposes only.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "6. User Rights",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "- You may request deletion of your data stored in Firebase.\n"
                  "- You can update preferences anytime in the settings.\n"
                  "- You can opt-out of notifications and tracking.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "7. Changes to This Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "We may update this policy occasionally. Any changes will be reflected here.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "8. Disclaimer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "Always listen to your body. Consult a healthcare provider before starting "
                  "any new fitness or yoga routine, especially if you have medical conditions.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 25),
            Text(
              "Contact Us",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "If you have any questions, contact: spitprojectyoga@gmail.com",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
