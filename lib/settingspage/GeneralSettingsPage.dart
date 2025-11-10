import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogai/settingspage/PrivacyPolicy.dart';
import '../../services/notification_service.dart';
import '../services/settings_manager.dart';
import 'SettingNotification.dart';

class GeneralSettingsPage extends StatefulWidget {
  @override
  _GeneralSettingsPageState createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {

  @override
  void initState() {
    super.initState();

  }

   @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey[100],
       appBar: AppBar(title: Text("General Settings"),backgroundColor: Colors.blue,),
       body: ListView(
         padding: EdgeInsets.all(20),
         children: [
           ListTile(
             leading: Icon(Icons.notifications_active, color: Colors.blue),
             title: const Text("Reminder"),
             onTap: () {
               Get.to(() => Settingnotification());
             },
           ),


           Divider(),
           ListTile(
             leading: Icon(Icons.privacy_tip, color: Colors.blue),
             title: Text("Privacy Policy"),
             onTap: (){
              Get.to(() => PrivacyPolicyPage());
            },
           ),
           Divider(),

         ],
       ),
     );
  }
}
