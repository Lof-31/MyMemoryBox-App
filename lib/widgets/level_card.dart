import 'dart:math';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final int totalCards;
  final int dueCount;

  const LevelCard({
    super.key,
    required this.level,
    required this.totalCards,
    required this.dueCount,
  });

  @override
  Widget build(BuildContext context) {
    final int intervalDays = pow(2, level).toInt();
    final bool hasDue = dueCount > 0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: hasDue ? Colors.orange : Colors.indigo,
                  foregroundColor: Colors.white,
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${intervalDays} d',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalCards',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalCards <= 1 ? 'card' : 'cards',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasDue ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasDue ? Icons.alarm : Icons.check_circle_outline,
                    size: 13,
                    color: hasDue ? Colors.orange.shade800 : Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasDue ? '$dueCount' : '0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasDue ? Colors.orange.shade900 : Colors.green.shade700,
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