import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/level_card.dart';
import 'create_card_screen.dart';
import 'review_screen.dart';
import 'card_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<Flashcard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _storageService.loadCards();
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
    await _notificationService.syncDailyReminder(_cards);
  }

  Future<void> _deleteCard(String id) async {
    final updatedList = _cards.where((c) => c.id != id).toList();
    await _storageService.saveCards(updatedList);
    _loadCards();
  }

  Future<void> _editCard(Flashcard card) async {
    final updatedList = _cards.map((c) => c.id == card.id ? card : c).toList();
    await _storageService.saveCards(updatedList);
    _loadCards();
  }

  List<Flashcard> get _dueCards => _cards.where((c) => c.isDue).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memory Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'All Cards',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardListScreen(
                    cards: _cards,
                    onDelete: _deleteCard,
                    onEdit: _editCard,
                  ),
                ),
              );
              _loadCards();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _dueCards.isEmpty
                  ? null
                  : () async {
                final result = await Navigator.push<List<Flashcard>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(
                      level: 0,
                      cards: _dueCards,
                    ),
                  ),
                );

                if (result != null && result.isNotEmpty) {
                  final Map<String, Flashcard> updatedMap = {
                    for (final card in result) card.id: card,
                  };
                  final updatedList = _cards.map((card) {
                    return updatedMap[card.id] ?? card;
                  }).toList();

                  await _storageService.saveCards(updatedList);
                }
                _loadCards();
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                _dueCards.isEmpty
                    ? 'No Cards Due'
                    : 'Start Review (${_dueCards.length})',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Memory Boxes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(9, (index) {
              final levelCards = _cards.where((c) => c.level == index).toList();
              final dueCount = levelCards.where((c) => c.isDue).length;
              return LevelCard(
                level: index,
                totalCards: levelCards.length,
                dueCount: dueCount,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await Navigator.push<Flashcard>(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCardScreen(),
            ),
          );

          if (newCard != null) {
            final updatedList = [..._cards, newCard];
            await _storageService.saveCards(updatedList);
            _loadCards();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}