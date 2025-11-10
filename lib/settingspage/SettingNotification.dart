import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../services/settings_manager.dart';

class Settingnotification extends StatefulWidget {
  @override
  _Settingnotification createState() => _Settingnotification();
}

class _Settingnotification extends State<Settingnotification> {
  TimeOfDay selectedTime = TimeOfDay(hour: 20, minute: 0);
  List<bool> repeatDays = List.filled(7, true);

  int sessions = 7;
  String firstDay = "Monday";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    sessions = prefs.getInt("sessions") ?? 7;
    firstDay = prefs.getString("firstday") ?? "Monday";
    selectedTime = await SettingsManager.getReminderTime();
    setState(() {});
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("sessions", sessions);
    prefs.setString("firstday", firstDay);

    // ADD THIS: persist the chosen time
    await SettingsManager.setReminderTime(selectedTime);

    // Cancel old, then reschedule with the NEW time
    await NotificationService.clearAllNotifications();
    await NotificationService.scheduleYogaNotifications(
      sessions,
      firstDay,
      selectedTime, // pass the actual chosen time
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notifications updated!")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text("Notification"),backgroundColor: Colors.blue,),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text("Reminder Time"),
            trailing: Text(selectedTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (time != null) {
                setState(() => selectedTime = time);
                await SettingsManager.setReminderTime(time);
                // Do NOT schedule here. Let the Save button handle it.
              }
            },
          ),


          Divider(),
          ListTile(
            title: Text("First Day"),
            trailing: DropdownButton<String>(
              value: firstDay,
              items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => firstDay = v!),
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Session Count (Days)"),
            trailing: DropdownButton<int>(
              value: sessions,
              items: [3, 5, 7, 10, 14, 21, 28]
                  .map((n) => DropdownMenuItem(value: n, child: Text("$n days")))
                  .toList(),
              onChanged: (v) => setState(() => sessions = v!),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: _saveSettings,
            child: Text("Save & Update Notifications",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}
