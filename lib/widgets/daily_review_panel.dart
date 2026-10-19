import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import 'level_badge.dart';

const int _secondsPerCard = 5;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

Map<int, int> _countByLevel(Iterable<Flashcard> cards) {
  final counts = <int, int>{};
  for (final c in cards) {
    counts[c.level] = (counts[c.level] ?? 0) + 1;
  }
  return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
}

class StreakChip extends StatelessWidget {
  final int streak;

  const StreakChip({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: appColors.streakContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 22, color: appColors.streak),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appColors.streak,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            streak == 1 ? 'day' : 'days',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: appColors.streak,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyReviewPanel extends StatelessWidget {
  final List<Flashcard> cards;
  final bool hasReviewedToday;
  final int reviewedToday;

  final int? correctToday;
  final VoidCallback onStartReview;

  const DailyReviewPanel({
    super.key,
    required this.cards,
    required this.hasReviewedToday,
    required this.reviewedToday,
    required this.correctToday,
    required this.onStartReview,
  });

  @override
  Widget build(BuildContext context) {
    final dueCards = cards.where((c) => c.isDue).toList();

    if (hasReviewedToday) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusBanner(
            icon: Icons.check_circle_rounded,
            title: 'Review done!',
            subtitle: 'Come back tomorrow to keep your streak going.',
            background: context.appColors.successContainer,
            foreground: context.appColors.onSuccessContainer,
          ),
          const SizedBox(height: 12),
          _TodayStats(reviewed: reviewedToday, correct: correctToday),
          const SizedBox(height: 12),
          _UpcomingCard(cards: cards),
        ],
      );
    }

    if (dueCards.isNotEmpty) {
      return _DueCard(dueCards: dueCards, onStartReview: onStartReview);
    }

    if (cards.isEmpty) {
      return _StatusBanner(
        icon: Icons.style_outlined,
        title: 'No cards yet',
        subtitle: 'Tap "New Card" to create your first flashcard.',
        background: context.colors.surfaceContainer,
        foreground: context.colors.onSurface,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBanner(
          icon: Icons.done_all_rounded,
          title: 'Nothing to review today',
          subtitle: 'All your cards are up to date.',
          background: context.colors.surfaceContainer,
          foreground: context.colors.onSurface,
        ),
        const SizedBox(height: 12),
        _UpcomingCard(cards: cards),
      ],
    );
  }
}

class _DueCard extends StatelessWidget {
  final List<Flashcard> dueCards;
  final VoidCallback onStartReview;

  const _DueCard({required this.dueCards, required this.onStartReview});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int minutes =
        ((dueCards.length * _secondsPerCard) / 60).ceil().clamp(1, 999);

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TODAY'S REVIEW",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: colors.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${dueCards.length}',
                  style: TextStyle(
                    fontSize: 56,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dueCards.length == 1
                            ? 'card to review'
                            : 'cards to review',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: colors.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '≈ $minutes min',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.onPrimaryContainer
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BoxBreakdown(cards: dueCards, chipColor: colors.surface),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStartReview,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Review'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxBreakdown extends StatelessWidget {
  final Iterable<Flashcard> cards;
  final Color chipColor;

  const _BoxBreakdown({required this.cards, required this.chipColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _countByLevel(cards).entries.map((entry) {
        return Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LevelBadge(level: entry.key, size: 24),
              const SizedBox(width: 6),
              Text(
                '× ${entry.value}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;

  const _StatusBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 44, color: foreground),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: foreground.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayStats extends StatelessWidget {
  final int reviewed;
  final int? correct;

  const _TodayStats({required this.reviewed, required this.correct});

  @override
  Widget build(BuildContext context) {
    final int? rate = (correct != null && reviewed > 0)
        ? ((correct! / reviewed) * 100).round()
        : null;
    final appColors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.style_outlined,
            value: '$reviewed',
            label: reviewed == 1 ? 'card reviewed' : 'cards reviewed',
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.insights_rounded,
            value: rate == null ? '–' : '$rate%',
            label: 'success rate',
            color: rate == null || rate >= 70
                ? appColors.success
                : appColors.streak,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final List<Flashcard> cards;

  const _UpcomingCard({required this.cards});

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final futureDates = cards
        .map((c) => _dateOnly(c.nextReviewDate))
        .where((d) => d.isAfter(today))
        .toList()
      ..sort();
    if (futureDates.isEmpty) return const SizedBox.shrink();

    final nextDate = futureDates.first;
    final nextCards =
        cards.where((c) => _dateOnly(c.nextReviewDate) == nextDate).toList();
    final int daysAway = nextDate.difference(today).inDays;
    final String when = daysAway == 1 ? 'Tomorrow' : 'In $daysAway days';
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_rounded, size: 22, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  when,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${nextCards.length} ${nextCards.length == 1 ? 'card' : 'cards'}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _BoxBreakdown(
              cards: nextCards,
              chipColor: colors.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}
