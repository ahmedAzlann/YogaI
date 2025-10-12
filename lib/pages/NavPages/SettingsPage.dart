import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  void _showBackupRestoreSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              Image.asset("images/icongoogle.png", height: 80),
              SizedBox(height: 20),
              Text(
                "Backup & Restore",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Securely backup and restore your yoga data with Google.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,

                ),
                onPressed: () {
                  // Trigger Google Account Picker
                  print("Continue with Google tapped");
                },
                child: Text("Continue with Google"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlayStore() async {
    const url = "https://play.google.com/store/apps/details?id=com.example.yogaapp";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yogaapp.com',
      query: 'subject=Yoga App Feedback',
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    }
  }

  void _shareApp() {
    print("Show share options bottom sheet");
    // Use share_plus package in a real implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ListTile(
            leading: Icon(Icons.backup, color: Colors.blue),
            title: Text("Backup & Restore"),
            onTap: () => _showBackupRestoreSheet(context),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.fitness_center, color: Colors.green),
            title: Text("Workout Settings"),
            subtitle: Text("Gender, Rest Counter, Countdown, Sound Options"),
            onTap: () {
              print("Open Workout Settings");
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.settings, color: Colors.orange),
            title: Text("General Settings"),
            subtitle: Text("Reminder, Keep Screen On, Privacy Policy"),
            onTap: () {
              print("Open General Settings");
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.language, color: Colors.purple),
            title: Text("Language Options"),
            subtitle: Text("English, French, Arabic, etc."),
            onTap: () {
              print("Open Language Options");
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text("Rate Us"),
            onTap: _openPlayStore,
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.feedback, color: Colors.red),
            title: Text("Feedback"),
            onTap: _sendFeedback,
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.share, color: Colors.blueGrey),
            title: Text("Share with Friends"),
            onTap: _shareApp,
          ),
        ],
      ),
    );
  }
}
