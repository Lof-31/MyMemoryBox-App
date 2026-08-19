import 'dart:math';

class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final int level;
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;

  const Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.level = 1,
    required this.nextReviewDate,
    this.lastReviewedAt,
  });

  factory Flashcard.create({
    required String id,
    required String frontText,
    required String backText,
  }) {
    return Flashcard(
      id: id,
      frontText: frontText,
      backText: backText,
      level: 1,
      nextReviewDate: DateTime.now(),
    );
  }

  int get intervalInDays => pow(2, level).toInt();

  bool get isDue => DateTime.now().isAfter(nextReviewDate);

  Flashcard promote({int maxLevel = 8}) {
    final int nextLevel = level < maxLevel ? level + 1 : level;
    final int interval = pow(2, nextLevel).toInt();
    final DateTime now = DateTime.now();
    return copyWith(
      level: nextLevel,
      lastReviewedAt: now,
      nextReviewDate: now.add(Duration(days: interval)),
    );
  }

  Flashcard demote() {
    const int resetLevel = 1;
    final int interval = pow(2, resetLevel).toInt();
    final DateTime now = DateTime.now();
    return copyWith(
      level: resetLevel,
      lastReviewedAt: now,
      nextReviewDate: now.add(Duration(days: interval)),
    );
  }

  Flashcard copyWith({
    String? id,
    String? frontText,
    String? backText,
    int? level,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      level: level ?? this.level,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'level': level,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      frontText: map['frontText'] as String,
      backText: map['backText'] as String,
      level: map['level'] as int,
      nextReviewDate: DateTime.parse(map['nextReviewDate'] as String),
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.parse(map['lastReviewedAt'] as String)
          : null,
    );
  }
}