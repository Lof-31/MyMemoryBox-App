import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class ReviewScreen extends StatefulWidget {
  final int level;
  final List<Flashcard> cards;

  const ReviewScreen({
    super.key,
    required this.level,
    required this.cards,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final List<Flashcard> _dueCards;
  final List<Flashcard> _updatedCards = [];
  int _currentIndex = 0;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _dueCards = List<Flashcard>.from(widget.cards);
  }

  Flashcard get _currentCard => _dueCards[_currentIndex];

  void _revealAnswer() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _handleAnswer({required bool isCorrect}) {
    final Flashcard updatedCard = isCorrect
        ? _currentCard.promote()
        : _currentCard.demote();

    _updatedCards.add(updatedCard);

    if (_currentIndex + 1 < _dueCards.length) {
      setState(() {
        _currentIndex++;
        _isRevealed = false;
      });
    } else {
      Navigator.of(context).pop(_updatedCards);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review Session'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    avatar: Icon(
                      _currentCard.isReversed ? Icons.swap_horiz : Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      _currentCard.isReversed ? 'Reverse (Back ➔ Front)' : 'Standard (Front ➔ Back)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    'Card ${_currentIndex + 1} / ${_dueCards.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentCard.promptText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isRevealed) ...[
                          const Divider(height: 48),
                          Text(
                            _currentCard.answerText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isRevealed)
                FilledButton(
                  onPressed: _revealAnswer,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reveal Answer'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleAnswer(isCorrect: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Incorrect'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _handleAnswer(isCorrect: true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Correct'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}