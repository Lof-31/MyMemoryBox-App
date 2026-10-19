import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';

class StreakForecastBar extends StatelessWidget {
  final List<Flashcard> cards;
  final List<String> reviewHistory;
  final Map<String, int> dailyDueHistory;
  final Map<String, int> dailyReviewedCountHistory;
  final bool hasReviewedToday;

  const StreakForecastBar({
    super.key,
    required this.cards,
    required this.reviewHistory,
    required this.dailyDueHistory,
    required this.dailyReviewedCountHistory,
    required this.hasReviewedToday,
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
    final colors = context.colors;
    final appColors = context.appColors;

    final dayOffsets = [-4, -3, -2, -1, 0, 1, 2, 3];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                Color textColor;

                if (isPast) {
                  final bool wasReviewed = reviewHistory.contains(dateStr);
                  final int recordedDue = dailyDueHistory[dateStr] ?? 0;
                  final int reviewedCount = dailyReviewedCountHistory[dateStr] ?? 0;

                  if (wasReviewed || recordedDue == 0) {
                    dotColor = appColors.success;
                    textColor = appColors.onSuccess;
                    count = reviewedCount;
                  } else {
                    dotColor = colors.error;
                    textColor = colors.onError;
                    count = recordedDue;
                  }
                } else if (isToday) {
                  final int dueToday = cards.where((c) => c.isDue).length;
                  final int reviewedToday = dailyReviewedCountHistory[dateStr] ?? 0;

                  if (hasReviewedToday || dueToday == 0) {
                    dotColor = appColors.success;
                    textColor = appColors.onSuccess;
                    count = reviewedToday;
                  } else {
                    dotColor = colors.surfaceContainerHighest;
                    textColor = colors.onSurfaceVariant;
                    count = dueToday;
                  }
                } else {
                  count = _countDueForFutureDate(targetDate);
                  dotColor = colors.surfaceContainerHighest;
                  textColor = colors.onSurfaceVariant;
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
                            ? Border.all(color: colors.primary, width: 2.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: textColor,
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
                        color: isToday ? colors.primary : colors.onSurfaceVariant,
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