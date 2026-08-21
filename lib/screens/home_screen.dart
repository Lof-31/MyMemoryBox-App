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
  final Function(int index)? onThemeChanged;

  const HomeScreen({
    super.key,
    this.onThemeChanged,
  });

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

  Future<void> _startReview() async {
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

  Future<void> _openCreateCard() async {
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
  }

  // 1. Onglet Daily Review (tout à gauche)
  Widget _buildDailyReviewView() {
    final bool canReview = !_hasReviewedToday && _dueCards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _hasReviewedToday
                    ? Icons.check_circle_outline
                    : (_dueCards.isEmpty ? Icons.done_all : Icons.school_outlined),
                size: 80,
                color: _hasReviewedToday
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _hasReviewedToday
                    ? 'All Done for Today!'
                    : (_dueCards.isEmpty
                    ? 'No Cards Due'
                    : '${_dueCards.length} Cards Due for Review'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _hasReviewedToday
                    ? 'You have already completed your daily session. Come back tomorrow for the next review.'
                    : (_dueCards.isEmpty
                    ? 'You have no pending cards to review right now.'
                    : 'Review these cards to reinforce your memory and promote them to higher boxes.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: canReview ? _startReview : null,
                icon: Icon(_hasReviewedToday ? Icons.check : Icons.play_arrow),
                label: Text(
                  _hasReviewedToday
                      ? 'Daily Review Completed'
                      : (_dueCards.isEmpty
                      ? 'No Cards Due'
                      : 'Start Review (${_dueCards.length})'),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_daily_review',
        onPressed: _openCreateCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 2. Onglet My Boxes (2e position)
  Widget _buildBoxesView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Boxes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Memory Boxes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(9, (index) {
            final levelCards = _cards.where((c) => c.level == index).toList();
            final dueCount =
            _hasReviewedToday ? 0 : levelCards.where((c) => c.isDue).length;
            return LevelCard(
              level: index,
              totalCards: levelCards.length,
              dueCount: dueCount,
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_boxes_view',
        onPressed: _openCreateCard,
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
      _buildDailyReviewView(),
      _buildBoxesView(),
      CardListScreen(
        cards: _cards,
        onDelete: _deleteCard,
        onEdit: _editCard,
      ),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
      ),
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
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Daily Review',
          ),
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