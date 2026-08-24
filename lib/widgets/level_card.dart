import 'dart:math';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final int totalCards;
  final int dueCount;
  final VoidCallback? onTap;

  static const double boxTitleFontSize = 16;
  static const double intervalFontSize = 15;
  static const double cardCountFontSize = 16;
  static const double dueBadgeFontSize = 14;
  static const double levelAvatarFontSize = 14;

  const LevelCard({
    super.key,
    required this.level,
    required this.totalCards,
    required this.dueCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int intervalDays = pow(2, level).toInt();
    final bool hasDue = dueCount > 0;

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: hasDue ? Colors.orange : Colors.indigo,
                foregroundColor: Colors.white,
                child: Text(
                  '$level',
                  style: const TextStyle(
                    fontSize: levelAvatarFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Box $level',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: boxTitleFontSize,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${intervalDays}d)',
                      style: TextStyle(
                        fontSize: intervalFontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$totalCards ${totalCards <= 1 ? 'card' : 'cards'}',
                style: TextStyle(
                  fontSize: cardCountFontSize,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: hasDue ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasDue ? Icons.alarm : Icons.check_circle_outline,
                      size: 16,
                      color: hasDue ? Colors.orange.shade800 : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasDue ? '$dueCount' : '0',
                      style: TextStyle(
                        fontSize: dueBadgeFontSize,
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
      ),
    );
  }
}