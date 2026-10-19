import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';
import 'level_badge.dart';

class ReviewCard extends StatefulWidget {
  final Flashcard card;
  final bool showAnswer;
  final VoidCallback onTap;

  final ValueChanged<bool> onSwiped;

  const ReviewCard({
    super.key,
    required this.card,
    required this.showAnswer,
    required this.onTap,
    required this.onSwiped,
  });

  @override
  State<ReviewCard> createState() => ReviewCardState();
}

class ReviewCardState extends State<ReviewCard> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _dragController;
  Animation<double>? _dragAnimation;
  double _dragX = 0;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.showAnswer ? 1 : 0,
    );
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        setState(() => _dragX = _dragAnimation?.value ?? _dragX);
      });
  }

  @override
  void didUpdateWidget(ReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _dragController.stop();
      _flipController.value = widget.showAnswer ? 1 : 0;
      _dragX = 0;
      _isLeaving = false;
    } else if (oldWidget.showAnswer != widget.showAnswer) {
      widget.showAnswer ? _flipController.forward() : _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  bool get _canSwipe => widget.showAnswer && !_isLeaving;

  void _animateDragTo(double target, {VoidCallback? onDone}) {
    _dragAnimation = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(parent: _dragController, curve: Curves.easeOut),
    );
    _dragController.forward(from: 0).whenComplete(() => onDone?.call());
  }

  void swipeAway(bool remembered) {
    if (_isLeaving) return;
    _isLeaving = true;
    final width = MediaQuery.sizeOf(context).width;
    _animateDragTo(
      remembered ? width * 1.5 : -width * 1.5,
      onDone: () => widget.onSwiped(remembered),
    );
  }

  void _onDragEnd(DragEndDetails details, double width) {
    if (!_canSwipe) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragX.abs() > width * 0.3 || velocity.abs() > 800) {
      swipeAway((_dragX != 0 ? _dragX : velocity) > 0);
    } else {
      _animateDragTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final progress = (_dragX / (width * 0.5)).clamp(-1.0, 1.0);

      return GestureDetector(
        onTap: _isLeaving ? null : widget.onTap,
        onHorizontalDragUpdate: (details) {
          if (_canSwipe) setState(() => _dragX += details.delta.dx);
        },
        onHorizontalDragEnd: (details) => _onDragEnd(details, width),
        child: Transform.translate(
          offset: Offset(_dragX, 0),
          child: Transform.rotate(
            angle: progress * 0.12,
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, _) {
                final angle = _flipController.value * pi;
                final showingBack = angle > pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: showingBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildFace(isAnswer: true, progress: progress),
                        )
                      : _buildFace(isAnswer: false, progress: 0),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFace({required bool isAnswer, required double progress}) {
    final colors = context.colors;
    final appColors = context.appColors;
    final card = widget.card;
    final bool frontShown = card.isReversed == isAnswer;

    final Color? swipeColor = progress > 0
        ? appColors.success
        : progress < 0
            ? colors.error
            : null;

    return Card(
      elevation: 3,
      color: isAnswer ? colors.surfaceContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    LevelBadge(level: card.level, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Box ${card.level}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${isAnswer ? 'ANSWER' : 'QUESTION'} · ${frontShown ? 'FRONT' : 'BACK'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        isAnswer ? card.answerText : card.promptText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  isAnswer
                      ? '← Forgot  ·  swipe  ·  Remembered →'
                      : 'Tap to reveal the answer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: colors.outline,
                  ),
                ),
              ],
            ),
          ),
          if (swipeColor != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: swipeColor.withValues(alpha: 0.25 * progress.abs()),
                  alignment: progress > 0
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
                  child: Opacity(
                    opacity: progress.abs(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: swipeColor, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        progress > 0 ? 'REMEMBERED' : 'FORGOT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: swipeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
