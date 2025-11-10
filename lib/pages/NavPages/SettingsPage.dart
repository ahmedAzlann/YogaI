import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/settings_manager.dart';
import '../../settingspage/GeneralSettingsPage.dart';
import '../../settingspage/LanguageOptionsPage.dart';
import '../../settingspage/WorkoutSettingsPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int restTimer;
  late int prepTimer;

  bool voiceGuide = true;
  bool coachTips = true;
  bool soundEffect = true;

  bool isLinked = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
    _checkLinkedState();
  }

  Future<void> _loadInitialSettings() async {
    restTimer = await SettingsManager.getRestTimer();
    prepTimer = await SettingsManager.getPrepTimer();
    voiceGuide = await SettingsManager.getVoiceGuide();
    coachTips = await SettingsManager.getCoachTips();
    soundEffect = await SettingsManager.getSoundEffect();
    setState(() {});
  }

  Future<void> _checkLinkedState() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      isLinked = user != null &&
          user.providerData.any((info) => info.providerId == 'google.com');
    });
  }

  void _openPlayStore() async {
    const url =
        "https://play.google.com/store/apps/details?id=com.example.yogaapp";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void openWorkoutSettings() async {
    final rest = await SettingsManager.getRestTimer();
    final prep = await SettingsManager.getPrepTimer();

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
    print("TODO: Share functionality will be added");
  }

  void _showBackupRestoreSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset("images/icongoogle.png", height: 80),
              const SizedBox(height: 20),
              Text(
                isLinked ? "Google Backup Active" : "Backup & Restore",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                isLinked
                    ? "Your data is safely synced with Google."
                    : "Securely backup and restore your yoga data with Google.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              isLinked
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _logoutGoogle,
                child: const Text("Logout"),
              )
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _linkAnonymousToGoogle,
                child: const Text("Continue with Google"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _linkAnonymousToGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(); // ✅ FIXED

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = FirebaseAuth.instance.currentUser;

      await user?.linkWithCredential(credential);

      print("✅ Linked successfully!");

      setState(() => isLinked = true);
    } catch (e) {
      print("❌ Error linking: $e");
    }
  }

  Future<void> _logoutGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      setState(() => isLinked = false);
      print("✅ Logged out successfully");
    } catch (e) {
      print("❌ Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
     /*     ListTile(
            leading: const Icon(Icons.backup, color: Colors.blue),
            title: Text(isLinked ? "Backup Active" : "Backup & Restore"),
            onTap: _showBackupRestoreSheet,
          ),
          Divider(),   */

          ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.green),
            title: const Text("Workout Settings"),
            subtitle: const Text("Rest Counter, Countdown, Sound Options"),
            onTap: openWorkoutSettings,
          ),
          Divider(),

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.orange),
            title: const Text("General Settings"),
            subtitle: const Text("Reminder, Keep Screen On, Privacy Policy"),
            onTap: () => Get.to(() => GeneralSettingsPage()),
          ),
          Divider(),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.purple),
            title: const Text("Language Options"),
            subtitle: const Text("English, French, Arabic"),
            onTap: () => Get.to(() => LanguageOptionsPage()),
          ),
          Divider(),

          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text("Rate Us"),
            onTap: _openPlayStore,
          ),
          Divider(),

          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.red),
            title: const Text("Feedback"),
            onTap: _sendFeedback,
          ),
          Divider(),

          ListTile(
            leading: const Icon(Icons.share, color: Colors.blueGrey),
            title: const Text("Share with Friends"),
            onTap: _shareApp,
          ),
        ],
      ),
    );
  }
}
