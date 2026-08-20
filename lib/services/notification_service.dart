import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/flashcard.dart';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final StorageService _storageService = StorageService();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> syncDailyReminder(List<Flashcard> cards, {TimeOfDay? customTime}) async {
    final bool hasDueCards = cards.any((c) => c.isDue);

    if (!hasDueCards) {
      await _notificationsPlugin.cancel(0);
      return;
    }

    final TimeOfDay reminderTime = customTime ?? await _storageService.getReminderTime();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_review_channel',
      'Daily Review Reminders',
      channelDescription: 'Notifications to remind you to review your flashcards',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Memory Box Review',
      'You have flashcards due for review today!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}