import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.70,
              ),
              itemCount: _filteredCards.length,
              itemBuilder: (context, index) {
                return FlashcardTile(
                  card: _filteredCards[index],
                  onDelete: widget.onDelete,
                  onEdit: widget.onEdit,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}