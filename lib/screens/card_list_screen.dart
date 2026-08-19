import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class CardListScreen extends StatelessWidget {
  final List<Flashcard> cards;
  final Function(String id) onDelete;
  final Function(Flashcard updatedCard) onEdit;

  const CardListScreen({
    super.key,
    required this.cards,
    required this.onDelete,
    required this.onEdit,
  });

  void _showEditDialog(BuildContext context, Flashcard card) {
    final frontController = TextEditingController(text: card.frontText);
    final backController = TextEditingController(text: card.backText);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: frontController,
                  decoration: const InputDecoration(labelText: 'Front'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: backController,
                  decoration: const InputDecoration(labelText: 'Back'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updated = card.copyWith(
                    frontText: frontController.text.trim(),
                    backText: backController.text.trim(),
                  );
                  onEdit(updated);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Flashcards'),
      ),
      body: cards.isEmpty
          ? const Center(child: Text('No flashcards created yet.'))
          : ListView.separated(
        itemCount: cards.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final Flashcard card = cards[index];
          return ListTile(
            title: Text(card.frontText),
            subtitle: Text('${card.backText} • Level ${card.level}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, card),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(card.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}