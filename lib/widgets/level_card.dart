import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'level_badge.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final int totalCards;

  final int maxCards;
  final int dueCount;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.totalCards,
    required this.maxCards,
    required this.dueCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int intervalDays = pow(2, level).toInt();
    final bool isEmpty = totalCards == 0;
    final colors = context.colors;

    return Opacity(
      opacity: isEmpty ? 0.5 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                LevelBadge(level: level, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            intervalDays == 1
                                ? 'Every day'
                                : 'Every $intervalDays days',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (dueCount > 0) ...[
                            _DueBadge(count: dueCount),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '$totalCards ${totalCards == 1 ? 'card' : 'cards'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: maxCards == 0 ? 0 : totalCards / maxCards,
                          minHeight: 8,
                          backgroundColor: colors.surfaceContainerHighest,
                          color: boxColor(colors, level),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  final int count;

  const _DueBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm, size: 14, color: colors.onPrimaryContainer),
          const SizedBox(width: 3),
          Text(
            '$count due',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
