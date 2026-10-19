import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';
import '../widgets/daily_review_panel.dart';
import '../widgets/level_card.dart';
import '../widgets/streak_forecast_bar.dart';
import 'create_card_screen.dart';
import 'review_screen.dart';
import 'card_list_screen.dart';
import 'box_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int index)? onThemeChanged;
  final Function(ThemeMode mode)? onThemeModeChanged;

  const HomeScreen({super.key, this.onThemeChanged, this.onThemeModeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final StorageService _storageService = StorageService();

  List<Flashcard> _cards = [];
  List<String> _reviewHistory = [];
  Map<String, int> _dailyDueHistory = {};
  Map<String, int> _dailyReviewedCountHistory = {};
  Map<String, int> _dailyCorrectCountHistory = {};
  int _streak = 0;
  bool _isLoading = true;
  bool _hasReviewedToday = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    final cards = await _storageService.loadCards();
    final lastReviewDateStr = await _storageService.getLastDailyReviewDate();
    final history = await _storageService.getReviewHistory();
    final streak = await _storageService.getStreak();
    final dueHistory = await _storageService.getDailyDueHistory();
    final reviewedCountHistory = await _storageService
        .getDailyReviewedCountHistory();
    final correctCountHistory = await _storageService
        .getDailyCorrectCountHistory();

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final String todayStr = _formatDate(today);

    for (int offset = -4; offset < 0; offset++) {
      final pastDate = DateTime(today.year, today.month, today.day + offset);
      final pastDateStr = _formatDate(pastDate);

      final int cumulativeDue = cards.where((c) {
        final rDate = DateTime(
          c.nextReviewDate.year,
          c.nextReviewDate.month,
          c.nextReviewDate.day,
        );
        return rDate.isBefore(pastDate) || rDate.isAtSameMomentAs(pastDate);
      }).length;

      if (!dueHistory.containsKey(pastDateStr) ||
          dueHistory[pastDateStr] == 0) {
        dueHistory[pastDateStr] = cumulativeDue;
      }
    }

    final int todayDue = cards.where((c) => c.isDue).length;
    dueHistory[todayStr] = todayDue;

    await _storageService.saveDailyDueHistory(dueHistory);

    setState(() {
      _cards = cards;
      _reviewHistory = history;
      _dailyDueHistory = dueHistory;
      _dailyReviewedCountHistory = reviewedCountHistory;
      _dailyCorrectCountHistory = correctCountHistory;
      _streak = streak;
      _hasReviewedToday = (lastReviewDateStr == todayStr);
      _isLoading = false;
    });
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

  Future<void> _deleteCards(Set<String> ids) async {
    final updatedList = _cards.where((c) => !ids.contains(c.id)).toList();
    await _storageService.saveCards(updatedList);
    _loadData();
  }

  Future<void> _moveCards(Set<String> ids, int level) async {
    final updatedList = _cards
        .map(
          (c) => ids.contains(c.id) && c.level != level ? c.moveTo(level) : c,
        )
        .toList();
    await _storageService.saveCards(updatedList);
    _loadData();
  }

  Future<int> _importCards(List<Flashcard> imported) async {
    String key(Flashcard c) =>
        '${c.frontText.trim().toLowerCase()}\u0000${c.backText.trim().toLowerCase()}';

    final existingKeys = _cards.map(key).toSet();
    final newCards = imported.where((c) => existingKeys.add(key(c))).toList();
    if (newCards.isEmpty) return 0;

    await _storageService.saveCards([..._cards, ...newCards]);
    _loadData();
    return newCards.length;
  }

  List<Flashcard> get _dueCards => _cards.where((c) => c.isDue).toList();

  Future<void> _startReview() async {
    final int sessionCardCount = _dueCards.length;
    final result = await Navigator.push<List<Flashcard>>(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(level: 0, cards: _dueCards),
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
      await _storageService.saveDailyReviewedCount(
        DateTime.now(),
        sessionCardCount,
      );
      await _storageService.saveDailyCorrectCount(
        DateTime.now(),
        result.where((c) => c.level > 0).length,
      );
      await _storageService.incrementStreak(DateTime.now());
    }
    _loadData();
  }

  Future<void> _openCreateCard() async {
    final newCard = await Navigator.push<Flashcard>(
      context,
      MaterialPageRoute(builder: (context) => const CreateCardScreen()),
    );

    if (newCard != null) {
      final updatedList = [..._cards, newCard];
      await _storageService.saveCards(updatedList);
      _loadData();
    }
  }

  Widget _buildDailyReviewView() {
    final todayStr = _formatDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review'),
        actions: [
          StreakChip(streak: _streak),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          StreakForecastBar(
            cards: _cards,
            reviewHistory: _reviewHistory,
            dailyDueHistory: _dailyDueHistory,
            dailyReviewedCountHistory: _dailyReviewedCountHistory,
            hasReviewedToday: _hasReviewedToday,
          ),
          const SizedBox(height: 16),
          DailyReviewPanel(
            cards: _cards,
            hasReviewedToday: _hasReviewedToday,
            reviewedToday: _dailyReviewedCountHistory[todayStr] ?? 0,
            correctToday: _dailyCorrectCountHistory[todayStr],
            onStartReview: _startReview,
          ),
        ],
      ),
    );
  }

  Widget _buildBoxesView() {
    final countByLevel = List.generate(
      9,
      (level) => _cards.where((c) => c.level == level).length,
    );
    final int maxCards = countByLevel.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('My Boxes')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(9, (index) {
            final dueCount = _hasReviewedToday
                ? 0
                : _cards.where((c) => c.level == index && c.isDue).length;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: index < 8 ? 8 : 0),
                child: LevelCard(
                  level: index,
                  totalCards: countByLevel[index],
                  maxCards: maxCards,
                  dueCount: dueCount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoxDetailScreen(
                          level: index,
                          cards: _cards,
                          onDelete: _deleteCard,
                          onEdit: _editCard,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      _buildDailyReviewView(),
      CardListScreen(
        cards: _cards,
        onDelete: _deleteCard,
        onEdit: _editCard,
        onDeleteMany: _deleteCards,
        onMoveMany: _moveCards,
      ),
      _buildBoxesView(),
      SettingsScreen(
        cards: _cards,
        onThemeChanged: widget.onThemeChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
        onImport: _importCards,
        onDataReset: _loadData,
      ),
    ];

    final bool shouldShowFab = _currentNavIndex == 0 || _currentNavIndex == 1;

    return Scaffold(
      body: IndexedStack(index: _currentNavIndex, children: pages),
      floatingActionButton: shouldShowFab
          ? FloatingActionButton.extended(
              heroTag: 'fab_main_new_card',
              onPressed: _openCreateCard,
              icon: const Icon(Icons.add),
              label: const Text(
                'New Card',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          : null,
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
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'My Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.all_inbox_outlined),
            selectedIcon: Icon(Icons.all_inbox),
            label: 'My Boxes',
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
