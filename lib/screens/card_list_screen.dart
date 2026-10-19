import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../widgets/box_picker_dialog.dart';
import '../widgets/flashcard_tile.dart';

enum CardSortType {
  reviewDate,
  boxLevel,
  alphabetical,
  creationDate,
}

class CardListScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final Function(String id) onDelete;
  final Function(Flashcard card) onEdit;
  final Function(Set<String> ids) onDeleteMany;
  final Function(Set<String> ids, int level) onMoveMany;

  const CardListScreen({
    super.key,
    required this.cards,
    required this.onDelete,
    required this.onEdit,
    required this.onDeleteMany,
    required this.onMoveMany,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String _searchQuery = '';
  CardSortType _selectedSortType = CardSortType.reviewDate;
  bool _isAscending = true;
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  void didUpdateWidget(CardListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Retire de la sélection les cartes qui n'existent plus
    final existingIds = widget.cards.map((c) => c.id).toSet();
    _selectedIds.retainWhere(existingIds.contains);
  }

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
    });
  }

  void _toggleSelectAll(List<Flashcard> visibleCards) {
    final visibleIds = visibleCards.map((c) => c.id);
    setState(() {
      if (visibleIds.every(_selectedIds.contains)) {
        _selectedIds.removeAll(visibleIds);
      } else {
        _selectedIds.addAll(visibleIds);
      }
    });
  }

  Future<void> _moveSelected() async {
    final levels = widget.cards
        .where((c) => _selectedIds.contains(c.id))
        .map((c) => c.level)
        .toSet();
    final level = await showBoxPickerDialog(
      context,
      title: _selectedIds.length > 1
          ? 'Move ${_selectedIds.length} Cards'
          : 'Move Card',
      currentLevel: levels.length == 1 ? levels.first : null,
    );
    if (level == null) return;
    widget.onMoveMany(Set.from(_selectedIds), level);
    _exitSelection();
  }

  void _confirmDeleteSelected() {
    final count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcards'),
        content: Text(
          'Are you sure you want to delete $count card${count > 1 ? 's' : ''}?',
        ),
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
              widget.onDeleteMany(Set.from(_selectedIds));
              _exitSelection();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(List<Flashcard> visibleCards) {
    if (!_isSelecting) {
      return AppBar(
        title: const Text('My Cards'),
        actions: [
          if (widget.cards.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _isSelecting = true),
              icon: const Icon(Icons.checklist_rounded),
              label: const Text('Select cards'),
            ),
        ],
      );
    }

    final bool allVisibleSelected = visibleCards.isNotEmpty &&
        visibleCards.every((c) => _selectedIds.contains(c.id));
    final bool hasSelection = _selectedIds.isNotEmpty;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Cancel',
        onPressed: _exitSelection,
      ),
      title: Text('${_selectedIds.length} selected'),
      actions: [
        IconButton(
          icon: Icon(allVisibleSelected
              ? Icons.deselect_rounded
              : Icons.select_all_rounded),
          tooltip: allVisibleSelected ? 'Deselect all' : 'Select all',
          onPressed: visibleCards.isEmpty
              ? null
              : () => _toggleSelectAll(visibleCards),
        ),
        IconButton(
          icon: const Icon(Icons.drive_file_move_outlined),
          tooltip: 'Move',
          onPressed: hasSelection ? _moveSelected : null,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline,
              color: hasSelection ? Colors.red : null),
          tooltip: 'Delete',
          onPressed: hasSelection ? _confirmDeleteSelected : null,
        ),
      ],
    );
  }

  List<Flashcard> get _processedCards {
    List<Flashcard> list = List.from(widget.cards);

    // 1. Filtrage par recherche
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
      c.frontText.toLowerCase().contains(q) ||
          c.backText.toLowerCase().contains(q))
          .toList();
    }

    // 2. Application du critère de tri
    switch (_selectedSortType) {
      case CardSortType.reviewDate:
        list.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
        break;
      case CardSortType.boxLevel:
        list.sort((a, b) => a.level.compareTo(b.level));
        break;
      case CardSortType.alphabetical:
        list.sort((a, b) =>
            a.frontText.toLowerCase().compareTo(b.frontText.toLowerCase()));
        break;
      case CardSortType.creationDate:
        break;
    }

    // 3. Application du sens (Ascendant / Descendant)
    if (!_isAscending) {
      list = list.reversed.toList();
    }

    return list;
  }

  String _getSortTypeLabel(CardSortType type) {
    switch (type) {
      case CardSortType.reviewDate:
        return 'Date de révision';
      case CardSortType.boxLevel:
        return 'Niveau de boîte';
      case CardSortType.alphabetical:
        return 'Ordre alphabétique';
      case CardSortType.creationDate:
        return 'Date de création';
    }
  }

  IconData _getSortTypeIcon(CardSortType type) {
    switch (type) {
      case CardSortType.reviewDate:
        return Icons.calendar_today_rounded;
      case CardSortType.boxLevel:
        return Icons.layers_outlined;
      case CardSortType.alphabetical:
        return Icons.sort_by_alpha_rounded;
      case CardSortType.creationDate:
        return Icons.schedule_rounded;
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final primaryColor = Theme.of(context).colorScheme.primary;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poignée de glissement
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // En-tête avec titre et sélecteur Croissant / Décroissant
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trier par',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.arrow_upward_rounded, size: 16),
                            label: Text('Croissant', style: TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.arrow_downward_rounded, size: 16),
                            label: Text('Décroissant', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        selected: {_isAscending},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setModalState(() {
                            _isAscending = newSelection.first;
                          });
                          this.setState(() {});
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Options de tri
                  ...CardSortType.values.map((type) {
                    final bool isSelected = _selectedSortType == type;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.2)
                            : Border.all(color: Colors.transparent, width: 1.2),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getSortTypeIcon(type),
                            size: 20,
                            color: isSelected ? primaryColor : Colors.grey.shade700,
                          ),
                        ),
                        title: Text(
                          _getSortTypeLabel(type),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
                            : null,
                        onTap: () {
                          setModalState(() {
                            _selectedSortType = type;
                          });
                          this.setState(() {});
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // Bouton OK pour fermer la modale
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final processedCards = _processedCards;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: _buildAppBar(processedCards),
      body: Column(
        children: [
          // Barre de recherche et bouton de tri
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search cards...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _showSortModal,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 4),
                          Icon(
                            _isAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Grille des cartes
          Expanded(
            child: processedCards.isEmpty
                ? Center(
              child: Text(
                widget.cards.isEmpty
                    ? 'No cards created yet.'
                    : 'No cards match your search.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 80),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.70,
              ),
              itemCount: processedCards.length,
              itemBuilder: (context, index) {
                final card = processedCards[index];
                return FlashcardTile(
                  card: card,
                  onDelete: widget.onDelete,
                  onEdit: widget.onEdit,
                  selectionMode: _isSelecting,
                  isSelected: _selectedIds.contains(card.id),
                  onSelectToggle: () => _toggleSelected(card.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}