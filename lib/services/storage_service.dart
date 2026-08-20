import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class StorageService {
  static const String _storageKey = 'flashcards_data';
  static const String _lastReviewDateKey = 'last_daily_review_date';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';

  Future<List<Flashcard>> loadCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;
    return decodedList
        .map((item) => Flashcard.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCards(List<Flashcard> cards) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> serialized =
    cards.map((card) => card.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(serialized));
  }

  Future<String?> getLastDailyReviewDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastReviewDateKey);
  }

  Future<void> saveLastDailyReviewDate(DateTime date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await prefs.setString(_lastReviewDateKey, formattedDate);
  }

  Future<TimeOfDay> getReminderTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int hour = prefs.getInt(_reminderHourKey) ?? 8;
    final int minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveReminderTime(TimeOfDay time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);
  }
}