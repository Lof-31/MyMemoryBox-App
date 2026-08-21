import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class StreakForecastBar extends StatelessWidget {
  final List<Flashcard> cards;
  final List<String> reviewHistory;
  final Map<String, int> dailyDueHistory;
  final bool hasReviewedToday;
  final int streak;

  const StreakForecastBar({
    super.key,
    required this.cards,
    required this.reviewHistory,
    required this.dailyDueHistory,
    required this.hasReviewedToday,
    required this.streak,
  });

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  int _countDueForFutureDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return cards.where((c) {
      final rDate = DateTime(
        c.nextReviewDate.year,
        c.nextReviewDate.month,
        c.nextReviewDate.day,
      );
      return rDate.isAtSameMomentAs(target);
    }).length;
  }

  String _getDayLabel(int offset, DateTime date) {
    if (offset == 0) return 'Today';
    if (offset == 1) return '+1d';
    if (offset == 2) return '+2d';
    if (offset == 3) return '+3d';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);

    final dayOffsets = [-4, -3, -2, -1, 0, 1, 2, 3];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity & Forecast',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 18, color: Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        '$streak d',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dayOffsets.map((offset) {
                final targetDate = DateTime(today.year, today.month, today.day + offset);
                final dateStr = _formatDate(targetDate);
                final bool isPast = offset < 0;
                final bool isToday = offset == 0;

                int count = 0;
                Color dotColor;

                if (isPast) {
                  final bool wasReviewed = reviewHistory.contains(dateStr);
                  final int recordedDue = dailyDueHistory[dateStr] ?? 0;

                  if (wasReviewed || recordedDue == 0) {
                    dotColor = Colors.green.shade600;
                    count = 0;
                  } else {
                    dotColor = Colors.red.shade500;
                    count = recordedDue;
                  }
                } else if (isToday) {
                  count = cards.where((c) => c.isDue).length;
                  if (hasReviewedToday || count == 0) {
                    dotColor = Colors.green.shade600;
                    count = 0;
                  } else {
                    dotColor = Colors.grey.shade400;
                  }
                } else {
                  count = _countDueForFutureDate(targetDate);
                  dotColor = Colors.grey.shade400;
                }

                final label = _getDayLabel(offset, targetDate);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: theme.colorScheme.primary, width: 2.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? theme.colorScheme.primary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}