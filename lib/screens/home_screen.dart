import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/level_card.dart';
import 'card_list_screen.dart';
import 'create_card_screen.dart';
import 'review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _totalLevels = 8;
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final List<Flashcard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loaded = await _storageService.loadCards();
    setState(() {
      _cards.addAll(loaded);
      _isLoading = false;
    });
    await _notificationService.syncDailyReminder(_cards);
  }

  Future<void> _persistCards() async {
    await _storageService.saveCards(_cards);
    await _notificationService.syncDailyReminder(_cards);
  }

  int _countTotalCardsByLevel(int level) {
    return _cards.where((card) => card.level == level).length;
  }

  int _countDueCardsByLevel(int level) {
    return _cards.where((card) => card.level == level && card.isDue).length;
  }

  List<Flashcard> _getDueCardsByLevel(int level) {
    return _cards.where((card) => card.level == level && card.isDue).toList();
  }

  Future<void> _onLevelSelected(int level) async {
    final List<Flashcard> dueCards = _getDueCardsByLevel(level);

    if (dueCards.isEmpty) {
      return;
    }

    final List<Flashcard>? reviewedCards =
    await Navigator.of(context).push<List<Flashcard>>(
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          level: level,
          cards: dueCards,
        ),
      ),
    );

    if (reviewedCards != null && reviewedCards.isNotEmpty) {
      setState(() {
        for (final updatedCard in reviewedCards) {
          final int index =
          _cards.indexWhere((card) => card.id == updatedCard.id);
          if (index != -1) {
            _cards[index] = updatedCard;
          }
        }
      });
      await _persistCards();
    }
  }

  Future<void> _navigateToCreateCard() async {
    final Flashcard? newCard = await Navigator.of(context).push<Flashcard>(
      MaterialPageRoute(
        builder: (context) => const CreateCardScreen(),
      ),
    );

    if (newCard != null) {
      setState(() {
        _cards.add(newCard);
      });
      await _persistCards();
    }
  }

  void _navigateToCardList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardListScreen(
          cards: _cards,
          onDelete: (id) async {
            setState(() {
              _cards.removeWhere((card) => card.id == id);
            });
            await _persistCards();
          },
          onEdit: (updatedCard) async {
            setState(() {
              final index =
              _cards.indexWhere((card) => card.id == updatedCard.id);
              if (index != -1) {
                _cards[index] = updatedCard;
              }
            });
            await _persistCards();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Memory Box'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: _navigateToCardList,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _totalLevels,
        itemBuilder: (context, index) {
          final int level = index + 1;
          return LevelCard(
            level: level,
            totalCards: _countTotalCardsByLevel(level),
            dueCards: _countDueCardsByLevel(level),
            onTap: () => _onLevelSelected(level),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}