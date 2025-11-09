import 'package:flutter/material.dart';
import '../services/settings_manager.dart';

class LanguageOptionsPage extends StatefulWidget {
  @override
  State<LanguageOptionsPage> createState() => _LanguageOptionsPageState();
}

class _LanguageOptionsPageState extends State<LanguageOptionsPage> {
  List<Map<String, String>> languages = [
    {"name": "English", "code": "en-US"},
    {"name": "French", "code": "fr-FR"},
    {"name": "Arabic", "code": "ar-SA"},
    {"name": "Hindi", "code": "hi-IN"},
  ];

  String selectedLanguage = "en-US";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  void _loadLanguage() async {
    selectedLanguage = await SettingsManager.getLanguage();
    setState(() {});
  }

  void _saveLanguage(String code) async {
    await SettingsManager.setLanguage(code);
    setState(() {
      selectedLanguage = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Language Options"),backgroundColor: Colors.blue,),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(lang["name"]!),
            trailing: selectedLanguage == lang["code"]
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => _saveLanguage(lang["code"]!),
          );
        },
      ),
    );
  }
}
