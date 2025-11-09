import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsManager {
  static const String languageKey = "tts_language";
  static const String restTimerKey = "rest_timer";
  static const String prepTimerKey = "prep_timer";
  static const String voiceGuideKey = "voice_guide";
  static const String coachTipsKey = "coach_tips";
  static const String soundEffectKey = "sound_effect";
  static const String reminderHourKey = "reminder_hour";
  static const String reminderMinuteKey = "reminder_minute";

  // ✅ REST
  static Future<void> setRestTimer(int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(restTimerKey, value);
  }

  static Future<int> getRestTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(restTimerKey) ?? 40;
  }

  // ✅ PREP
  static Future<void> setPrepTimer(int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(prepTimerKey, value);
  }

  static Future<int> getPrepTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prepTimerKey) ?? 15;
  }

  // ✅ VOICE GUIDE
  static Future<void> setVoiceGuide(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(voiceGuideKey, value);
  }

  static Future<bool> getVoiceGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(voiceGuideKey) ?? true;
  }

  // ✅ COACH TIPS
  static Future<void> setCoachTips(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(coachTipsKey, value);
  }

  static Future<bool> getCoachTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(coachTipsKey) ?? true;
  }

  // ✅ SOUND EFFECT
  static Future<void> setSoundEffect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(soundEffectKey, value);
  }

  static Future<bool> getSoundEffect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundEffectKey) ?? true;
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(languageKey, lang);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? "en-US";
  }

  static Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(reminderHourKey, time.hour);
    prefs.setInt(reminderMinuteKey, time.minute);
  }

  static Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(reminderHourKey) ?? 8;
    final minute = prefs.getInt(reminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }


}
