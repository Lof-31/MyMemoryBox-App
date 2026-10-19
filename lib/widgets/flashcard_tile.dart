import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import '../utils/dates.dart';
import 'box_picker_dialog.dart';
import 'level_badge.dart';

class FlashcardTile extends StatelessWidget {
  final Flashcard card;
  final Function(String id) onDelete;
  final Function(Flashcard card) onEdit;

  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelectToggle;

  final VoidCallback? onLongPress;

  static const double cardFontSize = 14.0;

  const FlashcardTile({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onEdit,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectToggle,
    this.onLongPress,
  });

  static String dueLabel(int daysLeft) {
    if (daysLeft <= 0) return 'Today';
    if (daysLeft == 1) return 'Tomorrow';
    return 'in ${daysLeft}d';
  }

  void _showEditDialog(BuildContext context) {
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

  Future<void> _showMoveDialog(BuildContext context) async {
    final level = await showBoxPickerDialog(context, currentLevel: card.level);
    if (level != null) onEdit(card.moveTo(level));
  }

  void _confirmDelete(BuildContext context) {
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
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
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

  void _showActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Card'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: const Text('Move Card'),
              onTap: () {
                Navigator.pop(ctx);
                _showMoveDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.colors.error),
              title: Text('Delete Card',
                  style: TextStyle(color: context.colors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(
      card.nextReviewDate.year,
      card.nextReviewDate.month,
      card.nextReviewDate.day,
    );
    final int daysLeft = daysBetween(today, reviewDate);

    final bool isDue = daysLeft <= 0;
    final colors = context.colors;

    final Widget status = selectionMode
        ? Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: isSelected ? colors.primary : colors.outline,
          )
        : Text(
            dueLabel(daysLeft),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDue ? FontWeight.bold : FontWeight.w600,
              color: isDue ? colors.primary : colors.onSurfaceVariant,
            ),
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isSelected ? colors.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: selectionMode ? onSelectToggle : () => _showActionModal(context),
        onLongPress: selectionMode ? null : onLongPress,
        child: _buildRow(colors, status),
      ),
    );
  }

  Widget _buildRow(ColorScheme colors, Widget status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          LevelBadge(level: card.level),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.frontText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  card.backText,
                  style: TextStyle(
                    fontSize: cardFontSize,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          status,
        ],
      ),
    );
  }
}
