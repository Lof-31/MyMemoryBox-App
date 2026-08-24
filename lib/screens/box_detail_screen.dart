import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_tile.dart';

class BoxDetailScreen extends StatelessWidget {
  final int level;
  final List<Flashcard> cards;
  final Function(String id) onDelete;
  final Function(Flashcard card) onEdit;

  const BoxDetailScreen({
    super.key,
    required this.level,
    required this.cards,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final int intervalDays = pow(2, level).toInt();
    final boxCards = cards.where((c) => c.level == level).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Box $level (${intervalDays}d)'),
      ),
      body: boxCards.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No cards in Box $level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: boxCards.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return FlashcardTile(
            card: boxCards[index],
            onDelete: onDelete,
            onEdit: onEdit,
          );
        },
      ),
    );
  }
}