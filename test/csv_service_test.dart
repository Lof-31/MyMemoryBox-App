import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/services/csv_service.dart';

void main() {
  final service = CsvService();

  test('export then import keeps the cards intact', () {
    final cards = [
      Flashcard(
        id: '1',
        frontText: 'Bonjour, "monde"',
        backText: 'Hello;\nworld',
        level: 5,
        nextReviewDate: DateTime(2026, 11, 3),
        isReversed: true,
      ),
      Flashcard(
        id: '2',
        frontText: 'chat',
        backText: 'cat',
        level: 0,
        nextReviewDate: DateTime(2026, 10, 20),
      ),
    ];

    final result = service.parse('﻿${service.encode(cards)}');

    expect(result.invalidRows, 0);
    expect(result.cards.length, 2);
    expect(result.cards[0].frontText, 'Bonjour, "monde"');
    expect(result.cards[0].backText, 'Hello;\nworld');
    expect(result.cards[0].level, 5);
    expect(result.cards[0].nextReviewDate, DateTime(2026, 11, 3));
    expect(result.cards[0].isReversed, true);
    expect(result.cards[1].isReversed, false);
  });

  test('handmade file: ; separator, partial columns, invalid rows', () {
    const csv = 'Back;Front;Level\r\n'
        'cat;chat;3\r\n'
        'dog;chien;\r\n'
        ';vide;1\r\n'
        'bird;oiseau;12\r\n';

    final result = service.parse(csv);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    expect(result.cards.length, 2);
    expect(result.invalidRows, 2);
    expect(result.cards[0].frontText, 'chat');
    expect(result.cards[0].level, 3);
    expect(result.cards[1].level, 0);
    expect(result.cards[1].nextReviewDate, tomorrow);
  });

  test('accepts DD/MM/YYYY dates', () {
    final result = service.parse('front,back,next_review_date\na,b,05/12/2026\n');
    expect(result.cards.single.nextReviewDate, DateTime(2026, 12, 5));
  });
}
