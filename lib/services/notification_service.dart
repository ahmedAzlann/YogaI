import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Setup notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(initSettings);

    // Request permissions
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // ✅ Android 13+ Notification Permission via permission_handler
    await Permission.notification.request();

    // ✅ iOS permissions through plugin
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> scheduleDailyReminder(
      int id, DateTime time, String title, String body) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminder',
          channelDescription: 'Daily reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleOneTimeNotification(
      int id, DateTime time, String title, String body) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'one_time_channel',
          'One Time Reminder',
          channelDescription: 'A one-time scheduled notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }

  static int _weekdayFromString(String day) {
    switch (day.toLowerCase()) {
      case "monday": return DateTime.monday;
      case "tuesday": return DateTime.tuesday;
      case "wednesday": return DateTime.wednesday;
      case "thursday": return DateTime.thursday;
      case "friday": return DateTime.friday;
      case "saturday": return DateTime.saturday;
      case "sunday": return DateTime.sunday;
      default: return DateTime.monday;
    }
  }
  static Future<void> scheduleYogaNotifications(
      int sessions, String firstDay, TimeOfDay time) async {

    final weekday = _weekdayFromString(firstDay);

    final now = DateTime.now();
    final todayWeekday = now.weekday;

    int diff = weekday - todayWeekday;
    if (diff < 0) diff += 7;

    DateTime startDate = now.add(Duration(days: diff));

    for (int i = 0; i < sessions; i++) {
      final day = startDate.add(Duration(days: i));

      DateTime scheduledAt = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );

// If scheduled time already passed today → shift to tomorrow
      if (scheduledAt.isBefore(DateTime.now())) {
        scheduledAt = scheduledAt.add(Duration(days: 1));
      }


      await scheduleOneTimeNotification(
        2000 + i,
        scheduledAt,
        "Yoga Reminder",
        "Your session for Day ${i + 1} is ready!",
      );
    }
  }
  static Future<void> testImmediateNotification(NotificationDetails details) async {
    await _notifications.show(
      9999, // random ID
      "Test Notification",
      "If you're seeing this… congratulations, it works.",
      details,
    );
  }


}
