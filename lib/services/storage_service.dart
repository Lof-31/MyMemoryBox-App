import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class StorageService {
  static const String _storageKey = 'flashcards_data';
  static const String _lastReviewDateKey = 'last_daily_review_date';
  static const String _reviewHistoryKey = 'daily_review_history';
  static const String _dailyDueHistoryKey = 'daily_due_history';
  static const String _dailyReviewedCountKey = 'daily_reviewed_count';
  static const String _streakCountKey = 'streak_count';
  static const String _lastStreakDateKey = 'last_streak_date';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _themeColorIndexKey = 'theme_color_index';

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
    final String formattedDate = _formatDate(date);
    await prefs.setString(_lastReviewDateKey, formattedDate);

    final history = await getReviewHistory();
    if (!history.contains(formattedDate)) {
      history.add(formattedDate);
      await prefs.setStringList(_reviewHistoryKey, history);
    }
  }

  Future<List<String>> getReviewHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_reviewHistoryKey) ?? [];
  }

  Future<Map<String, int>> getDailyDueHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_dailyDueHistoryKey);
    if (rawJson == null || rawJson.isEmpty) {
      return {};
    }
    final Map<String, dynamic> decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> saveDailyDueHistory(Map<String, int> history) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyDueHistoryKey, jsonEncode(history));
  }

  Future<Map<String, int>> getDailyReviewedCountHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_dailyReviewedCountKey);
    if (rawJson == null || rawJson.isEmpty) {
      return {};
    }
    final Map<String, dynamic> decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> saveDailyReviewedCount(DateTime date, int count) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String formattedDate = _formatDate(date);
    final history = await getDailyReviewedCountHistory();
    history[formattedDate] = (history[formattedDate] ?? 0) + count;
    await prefs.setString(_dailyReviewedCountKey, jsonEncode(history));
  }

  Future<int> getStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int streak = prefs.getInt(_streakCountKey) ?? 0;
    final String? lastDateStr = prefs.getString(_lastStreakDateKey);

    if (lastDateStr == null) {
      return 0;
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastDate = DateTime.parse(lastDateStr);
    final int diffInDays = today.difference(lastDate).inDays;

    if (diffInDays > 1) {
      await prefs.setInt(_streakCountKey, 0);
      return 0;
    }

    return streak;
  }

  Future<void> incrementStreak(DateTime date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String formattedDate = _formatDate(date);
    final String? lastDateStr = prefs.getString(_lastStreakDateKey);

    if (lastDateStr == formattedDate) {
      return;
    }

    final int currentStreak = await getStreak();
    await prefs.setInt(_streakCountKey, currentStreak + 1);
    await prefs.setString(_lastStreakDateKey, formattedDate);
  }

  Future<TimeOfDay> getReminderTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int hour = prefs.getInt(_reminderHourKey) ?? 9;
    final int minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveReminderTime(TimeOfDay time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);
  }

  Future<int> getThemeColorIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeColorIndexKey) ?? 0;
  }

  Future<void> saveThemeColorIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorIndexKey, index);
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}