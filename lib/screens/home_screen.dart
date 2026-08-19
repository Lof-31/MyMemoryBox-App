import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../widgets/level_card.dart';
import 'create_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _totalLevels = 8;
  final List<Flashcard> _cards = [];

  int _countTotalCardsByLevel(int level) {
    return _cards.where((card) => card.level == level).length;
  }

  int _countDueCardsByLevel(int level) {
    return _cards.where((card) => card.level == level && card.isDue).length;
  }

  void _onLevelSelected(int level) {
    // Navigate to review session (Step 4)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Memory Box'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
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