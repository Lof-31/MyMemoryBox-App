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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: dueCount > 0 ? Colors.orange : Colors.indigo,
          foregroundColor: Colors.white,
          child: Text('$level'),
        ),
        title: Text('Level $level ($intervalDays ${intervalDays == 1 ? 'day' : 'days'})'),
        subtitle: Text('Total: $totalCards cards'),
        trailing: dueCount > 0
            ? Chip(
          label: Text('$dueCount due'),
          backgroundColor: Colors.orange.shade100,
        )
            : const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }
}