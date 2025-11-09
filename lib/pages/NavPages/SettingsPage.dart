import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../../services/settings_manager.dart';
import '../../settingspage/GeneralSettingsPage.dart';
import '../../settingspage/LanguageOptionsPage.dart';
import '../../settingspage/WorkoutSettingsPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
late int restTimer ;
 late int prepTimer ;
  bool voiceGuide = true;
  bool coachTips = true;
  bool soundEffect = true;


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

void openWorkoutSettings() async {
  int rest = await SettingsManager.getRestTimer();
  int prep = await SettingsManager.getPrepTimer();

  Get.to(() => WorkoutSettingsPage(
    restTimer: rest,
    prepTimer: prep,
    voiceGuide: voiceGuide,
    coachTips: coachTips,
    soundEffect: soundEffect,
    onSave: (rest, prep, voice, coach, sound) {
      setState(() {
        restTimer = rest;
        prepTimer = prep;
        voiceGuide = voice;
        coachTips = coach;
        soundEffect = sound;
      });
    },
  ));
}


  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'spitprojectyoga@gmail.com',
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
void initState() {
  super.initState();

}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
            onTap: openWorkoutSettings,
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.settings, color: Colors.orange),
            title: Text("General Settings"),
            subtitle: Text("Reminder, Keep Screen On, Privacy Policy"),
            onTap: () {
              Get.to(() => GeneralSettingsPage());
            },
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.language, color: Colors.purple),
            title: Text("Language Options"),
            subtitle: Text("English, French, Arabic, etc."),
            onTap: () => Get.to(() => LanguageOptionsPage()),
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





