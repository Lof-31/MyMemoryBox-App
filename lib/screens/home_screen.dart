import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/level_card.dart';
import 'create_card_screen.dart';
import 'review_screen.dart';
import 'card_list_screen.dart';
import 'settings_screen.dart';

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
  bool _hasReviewedToday = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cards = await _storageService.loadCards();
    final lastReviewDateStr = await _storageService.getLastDailyReviewDate();

    final DateTime now = DateTime.now();
    final String todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      _cards = cards;
      _hasReviewedToday = (lastReviewDateStr == todayStr);
      _isLoading = false;
    });

    await _notificationService.syncDailyReminder(_cards);
  }

  Future<void> _deleteCard(String id) async {
    final updatedList = _cards.where((c) => c.id != id).toList();
    await _storageService.saveCards(updatedList);
    _loadData();
  }

  Future<void> _editCard(Flashcard card) async {
    final updatedList = _cards.map((c) => c.id == card.id ? card : c).toList();
    await _storageService.saveCards(updatedList);
    _loadData();
  }

  List<Flashcard> get _dueCards => _cards.where((c) => c.isDue).toList();

  Widget _buildBoxesView() {
    final bool canReview = !_hasReviewedToday && _dueCards.isNotEmpty;

    String buttonLabel;
    if (_hasReviewedToday) {
      buttonLabel = 'Daily Review Completed';
    } else if (_dueCards.isEmpty) {
      buttonLabel = 'No Cards Due';
    } else {
      buttonLabel = 'Start Review (${_dueCards.length})';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memory Box'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: canReview
                  ? () async {
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
                  await _storageService.saveLastDailyReviewDate(DateTime.now());
                }
                _loadData();
              }
                  : null,
              icon: Icon(_hasReviewedToday ? Icons.check : Icons.play_arrow),
              label: Text(buttonLabel),
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
              final dueCount = _hasReviewedToday
                  ? 0
                  : levelCards.where((c) => c.isDue).length;
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
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = [
      _buildBoxesView(),
      CardListScreen(
        cards: _cards,
        onDelete: _deleteCard,
        onEdit: _editCard,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.all_inbox_outlined),
            selectedIcon: Icon(Icons.all_inbox),
            label: 'My Boxes',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'My Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}