import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import '../utils/dates.dart';
import 'box_picker_dialog.dart';
import 'level_badge.dart';

class FlashcardTile extends StatelessWidget {
  final Flashcard card;
  /// All saved cards, used to refuse an edit that would create a duplicate.
  final List<Flashcard> allCards;
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
    required this.allCards,
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
    showDialog(
      context: context,
      builder: (ctx) =>
          _EditCardDialog(card: card, allCards: allCards, onEdit: onEdit),
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

/// Owns its text controllers so they are disposed when the dialog closes
/// (after its exit animation, not while the fields are still on screen).
class _EditCardDialog extends StatefulWidget {
  final Flashcard card;
  final List<Flashcard> allCards;
  final Function(Flashcard card) onEdit;

  const _EditCardDialog({
    required this.card,
    required this.allCards,
    required this.onEdit,
  });

  @override
  State<_EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<_EditCardDialog> {
  late final TextEditingController _frontCtrl =
      TextEditingController(text: widget.card.frontText);
  late final TextEditingController _backCtrl =
      TextEditingController(text: widget.card.backText);
  String? _duplicateError;

  @override
  void dispose() {
    _frontCtrl.dispose();
    _backCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_frontCtrl.text.trim().isEmpty || _backCtrl.text.trim().isEmpty) {
      return;
    }
    if (Flashcard.existsIn(
      widget.allCards,
      _frontCtrl.text,
      _backCtrl.text,
      exceptId: widget.card.id,
    )) {
      setState(() => _duplicateError = 'This card already exists');
      return;
    }
    final updated = widget.card.copyWith(
      frontText: _frontCtrl.text.trim(),
      backText: _backCtrl.text.trim(),
    );
    widget.onEdit(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _frontCtrl,
            decoration: const InputDecoration(labelText: 'Front Text'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _backCtrl,
            decoration: InputDecoration(
              labelText: 'Back Text',
              errorText: _duplicateError,
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
