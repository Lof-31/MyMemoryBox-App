import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

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

  void _showEditDialog(BuildContext context, Flashcard card) {
    final frontCtrl = TextEditingController(text: card.frontText);
    final backCtrl = TextEditingController(text: card.backText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontCtrl,
              decoration: const InputDecoration(labelText: 'Front Text'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: backCtrl,
              decoration: const InputDecoration(labelText: 'Back Text'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (frontCtrl.text.trim().isNotEmpty &&
                  backCtrl.text.trim().isNotEmpty) {
                final updated = card.copyWith(
                  frontText: frontCtrl.text.trim(),
                  backText: backCtrl.text.trim(),
                );
                onEdit(updated);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Flashcard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(card.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
          final card = boxCards[index];
          final nextDate = card.nextReviewDate;
          final dateFormatted =
              '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                child: Text('${card.level}'),
              ),
              title: Text(
                card.frontText,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Interval: ${card.intervalInDays}d • Next: $dateFormatted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Answer / Translation:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.backText,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton.outlined(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditDialog(context, card),
                            tooltip: 'Edit Card',
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _confirmDelete(context, card),
                            tooltip: 'Delete Card',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}