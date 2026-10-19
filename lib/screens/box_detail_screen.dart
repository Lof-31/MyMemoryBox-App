import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_tile.dart';

class BoxDetailScreen extends StatelessWidget {
  final int level;
  /// Live list of all cards, so edits made from this screen show up at once.
  final ValueListenable<List<Flashcard>> cards;
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
    return ValueListenableBuilder<List<Flashcard>>(
      valueListenable: cards,
      builder: (context, cards, _) => _buildBox(context, cards),
    );
  }

  Widget _buildBox(BuildContext context, List<Flashcard> cards) {
    final int intervalDays = pow(2, level).toInt();
    final boxCards = cards.where((c) => c.level == level).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Box $level (${intervalDays}d)')),
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
          : ListView.separated(
              padding: const EdgeInsets.all(12),
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
