import 'dart:math';

class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final int level;
  final DateTime nextReviewDate;
  final bool isReversed;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.level,
    required this.nextReviewDate,
    this.isReversed = false,
  });

  String get promptText => isReversed ? backText : frontText;
  String get answerText => isReversed ? frontText : backText;
  int get intervalInDays => pow(2, level).toInt();

  bool get isDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return reviewDate.isBefore(today) || reviewDate.isAtSameMomentAs(today);
  }

  factory Flashcard.create({
    required String id,
    required String frontText,
    required String backText,
  }) {
    final DateTime now = DateTime.now();
    return Flashcard(
      id: id,
      frontText: frontText,
      backText: backText,
      level: 0,
      isReversed: false,
      nextReviewDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
    );
  }

  Flashcard promote() {
    final newLevel = level < 8 ? level + 1 : 8;
    final nextInterval = pow(2, newLevel).toInt();
    final now = DateTime.now();
    final nextDate = DateTime(now.year, now.month, now.day).add(Duration(days: nextInterval));

    return Flashcard(
      id: id,
      frontText: frontText,
      backText: backText,
      level: newLevel,
      isReversed: !isReversed,
      nextReviewDate: nextDate,
    );
  }

  Flashcard demote() {
    final now = DateTime.now();
    final nextDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return Flashcard(
      id: id,
      frontText: frontText,
      backText: backText,
      level: 0,
      isReversed: false,
      nextReviewDate: nextDate,
    );
  }

  Flashcard copyWith({
    String? frontText,
    String? backText,
    int? level,
    DateTime? nextReviewDate,
    bool? isReversed,
  }) {
    return Flashcard(
      id: id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      level: level ?? this.level,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      isReversed: isReversed ?? this.isReversed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'level': level,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'isReversed': isReversed,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      frontText: map['frontText'] as String,
      backText: map['backText'] as String,
      level: map['level'] as int? ?? 0,
      nextReviewDate: DateTime.parse(map['nextReviewDate'] as String),
      isReversed: map['isReversed'] as bool? ?? false,
    );
  }
}