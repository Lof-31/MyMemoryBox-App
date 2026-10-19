import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
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
              color: context.colors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No cards in Box $level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.70,
        ),
        itemCount: boxCards.length,
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