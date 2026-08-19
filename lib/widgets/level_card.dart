import 'dart:math';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final int totalCards;
  final int dueCards;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.totalCards,
    required this.dueCards,
    required this.onTap,
  });

  int get _intervalInDays => pow(2, level).toInt();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: dueCards > 0 ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          child: Text('$level'),
        ),
        title: Text(
          'Level $level',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Review interval: $_intervalInDays days'),
        trailing: _buildBadge(),
      ),
    );
  }

  Widget _buildBadge() {
    final Color badgeColor = dueCards > 0 ? Colors.green : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$dueCards / $totalCards ready',
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}