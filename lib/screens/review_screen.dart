import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import '../widgets/review_card.dart';

class ReviewScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const ReviewScreen({
    super.key,
    required this.cards,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late List<Flashcard> _reviewCards;
  final List<Flashcard> _updatedCards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  final GlobalKey<ReviewCardState> _cardKey = GlobalKey<ReviewCardState>();

  int _correctCount = 0;
  int _failedCount = 0;
  late final DateTime _startTime;
  Duration _sessionDuration = Duration.zero;
  bool _isSessionFinished = false;

  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _reviewCards = List.from(widget.cards);
    _startTime = DateTime.now();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 50));
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _triggerVictoryCelebration() async {
    HapticFeedback.mediumImpact();
    _confettiController.play();
    try {
      await _audioPlayer.play(AssetSource('sounds/victory.mp3'));
    } catch (e) {
      debugPrint('Error playing victory sound: $e');
    }
  }

  void _toggleCardFlip() {
    HapticFeedback.selectionClick();
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _onAnswer(bool success) {
    if (success) {
      HapticFeedback.lightImpact();
      _correctCount++;
    } else {
      HapticFeedback.mediumImpact();
      _failedCount++;
    }

    final currentCard = _reviewCards[_currentIndex];
    final updatedCard = success ? currentCard.promote() : currentCard.demote();
    _updatedCards.add(updatedCard);

    if (_currentIndex + 1 < _reviewCards.length) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _sessionDuration = DateTime.now().difference(_startTime);
        _isSessionFinished = true;
      });
      _triggerVictoryCelebration();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${seconds}s';
  }

  Widget _buildSummaryView() {
    final theme = Theme.of(context);
    final total = _reviewCards.length;
    final accuracy = total > 0 ? ((_correctCount / total) * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Review Completed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job keeping your memory fresh.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: context.appColors.success, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                '$_correctCount',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Promoted',
                                style: TextStyle(
                                    fontSize: 12, color: context.colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.replay_outlined,
                                  color: context.colors.error, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                '$_failedCount',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Demoted',
                                style: TextStyle(
                                    fontSize: 12, color: context.colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.timer_outlined,
                                  color: theme.colorScheme.primary, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                _formatDuration(_sessionDuration),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Time Spent',
                                style: TextStyle(
                                    fontSize: 12, color: context.colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Success Rate',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$accuracy%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accuracy >= 70
                                  ? context.appColors.success
                                  : context.appColors.streak,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, _updatedCards);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 35,
              minBlastForce: 10,
              emissionFrequency: 0.0,
              numberOfParticles: 100,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                for (var level = 0; level <= 8; level += 2)
                  boxColor(context.colors, level),
                context.appColors.success,
                context.appColors.streak,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Any way of leaving the screen (system back button, iOS back gesture,
    // app bar arrow) must hand the answers given so far back to the caller.
    return PopScope<List<Flashcard>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _updatedCards);
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_reviewCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(
          child: Text('No cards available to review.'),
        ),
      );
    }

    if (_isSessionFinished) {
      return _buildSummaryView();
    }

    final card = _reviewCards[_currentIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_currentIndex + 1} / ${_reviewCards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _reviewCards.length,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor:
              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ReviewCard(
                key: _cardKey,
                card: card,
                showAnswer: _showAnswer,
                onTap: _toggleCardFlip,
                onSwiped: _onAnswer,
              ),
            ),
            const SizedBox(height: 24),
            if (_showAnswer)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.errorContainer,
                        foregroundColor: context.colors.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _cardKey.currentState?.swipeAway(false),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close),
                          SizedBox(width: 8),
                          Text('Forgot',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.appColors.success,
                        foregroundColor: context.appColors.onSuccess,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _cardKey.currentState?.swipeAway(true),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check),
                          SizedBox(width: 8),
                          Text('Remembered',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _toggleCardFlip,
                  child: const Text('Show Answer',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}