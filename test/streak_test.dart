import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime day(int offset) =>
      DateTime(today.year, today.month, today.day + offset);
  String fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void lastReviewed(int offset, int streak) {
    SharedPreferences.setMockInitialValues({
      'streak_count': streak,
      'last_streak_date': fmt(day(offset)),
    });
  }

  test('days with nothing due keep the streak going', () async {
    lastReviewed(-3, 5);
    final streak = await StorageService().getStreak(isFreeDay: (_) => true);
    expect(streak, 8);

    // Already counted: a second call doesn't count the days again.
    expect(await StorageService().getStreak(isFreeDay: (_) => true), 8);
  });

  test('a missed day with cards due still breaks the streak', () async {
    lastReviewed(-3, 5);
    final busy = day(-1);
    final streak = await StorageService()
        .getStreak(isFreeDay: (d) => d != busy);
    expect(streak, 0);
  });

  test('a day with cards due today does not break the streak yet', () async {
    lastReviewed(-2, 5);
    final streak = await StorageService()
        .getStreak(isFreeDay: (d) => d != today);
    expect(streak, 6);
  });

  test('free days do not start a streak from zero', () async {
    lastReviewed(-3, 0);
    expect(await StorageService().getStreak(isFreeDay: (_) => true), 0);
  });
}
