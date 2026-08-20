import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class CardListScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final Function(String id) onDelete;
  final Function(Flashcard card) onEdit;

  const CardListScreen({
    super.key,
    required this.cards,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String _searchQuery = '';

  List<Flashcard> get _filteredCards {
    if (_searchQuery.trim().isEmpty) {
      return widget.cards;
    }
    final q = _searchQuery.toLowerCase();
    return widget.cards
        .where((c) =>
    c.frontText.toLowerCase().contains(q) ||
        c.backText.toLowerCase().contains(q))
        .toList();
  }

  void _showEditDialog(Flashcard card) {
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
                widget.onEdit(updated);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredCards.isEmpty
                ? Center(
              child: Text(
                widget.cards.isEmpty
                    ? 'No cards created yet.'
                    : 'No cards match your search.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredCards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final card = _filteredCards[index];
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
                                  onPressed: () => _showEditDialog(card),
                                  tooltip: 'Edit Card',
                                ),
                                const SizedBox(width: 8),
                                IconButton.outlined(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => widget.onDelete(card.id),
                                  tooltip: 'Delete Card',
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}