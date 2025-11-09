import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/settings_manager.dart';


class WorkoutSettingsPage extends StatefulWidget {
  final int restTimer;
  final int prepTimer;
  final bool voiceGuide;
  final bool coachTips;
  final bool soundEffect;
  final Function(int, int, bool, bool, bool) onSave;

  const WorkoutSettingsPage({
    Key? key,
    required this.restTimer,
    required this.prepTimer,
    required this.voiceGuide,
    required this.coachTips,
    required this.soundEffect,
    required this.onSave,
  }) : super(key: key);

  @override
  State<WorkoutSettingsPage> createState() => _WorkoutsettingspageState();
}

class _WorkoutsettingspageState extends State<WorkoutSettingsPage> {


  late int restTimer;
  late int prepTimer;
  late bool voiceGuide;
  late bool coachTips;
  late bool soundEffect;


  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    restTimer = await SettingsManager.getRestTimer();
    prepTimer = await SettingsManager.getPrepTimer();
    voiceGuide = await SettingsManager.getVoiceGuide();
    coachTips = await SettingsManager.getCoachTips();
    soundEffect = await SettingsManager.getSoundEffect();
    setState(() {});
  }


  void saveAndExit() {
    widget.onSave(restTimer, prepTimer, voiceGuide, coachTips, soundEffect);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Workout Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [

          ListTile(
            leading: const Icon(Icons.coffee, color: Colors.brown),
            title: const Text("Rest timer"),
            trailing: DropdownButton<int>(
              value: restTimer,
              items: const [
                DropdownMenuItem(value: 40, child: Text("40s")),
                DropdownMenuItem(value: 45, child: Text("45s")),
                DropdownMenuItem(value: 60, child: Text("60s")),

               ],
                onChanged: (value) async {
                  if (value != null) {
                    await SettingsManager.setRestTimer(value);
                    setState(() => restTimer = value);
                  }
                }

            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.orange),
            title: const Text("Prep timer"),
            trailing: DropdownButton<int>(
              value: prepTimer,
              items: const [
                DropdownMenuItem(value: 15, child: Text("15s")),
                DropdownMenuItem(value: 25, child: Text("25s")),
                DropdownMenuItem(value: 30, child: Text("30s")),
              ],
                onChanged: (value) async {
                  if (value != null) {
                    await SettingsManager.setPrepTimer(value);
                    setState(() => prepTimer = value);
                  }
                }

            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.volume_up, color: Colors.purple),
            title: const Text("Voice Guide"),
            trailing: Switch(
              value: voiceGuide,
              onChanged: (val) async {
                await SettingsManager.setVoiceGuide(val);
                setState(() => voiceGuide = val);
              },
              activeThumbColor: Colors.blue,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.purple),
            title: const Text("Coach Tips"),
            trailing: Switch(
              value: coachTips,
              onChanged: (val) async {
                await SettingsManager.setCoachTips(val);
                setState(() => coachTips = val);
              },
              activeThumbColor: Colors.blue,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.purple),
            title: const Text("Sound Effects"),
            trailing: Switch(
              value: soundEffect,
              onChanged: (val) async {
                await SettingsManager.setSoundEffect(val);
                setState(() => soundEffect = val);
              },
              activeThumbColor: Colors.blue,
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: saveAndExit,
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}