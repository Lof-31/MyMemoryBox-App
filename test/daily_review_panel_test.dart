import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';
import 'package:my_memory_box_app/widgets/daily_review_panel.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Flashcard card(String id, int level, int daysFromToday) => Flashcard(
        id: id,
        frontText: 'front $id',
        backText: 'back $id',
        level: level,
        nextReviewDate: today.add(Duration(days: daysFromToday)),
      );

  Future<void> pumpPanel(
    WidgetTester tester, {
    required List<Flashcard> cards,
    bool hasReviewedToday = false,
    int reviewedToday = 0,
    int? correctToday,
    VoidCallback? onStart,
  }) {
    return tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: Scaffold(
        body: SingleChildScrollView(
          child: DailyReviewPanel(
            cards: cards,
            hasReviewedToday: hasReviewedToday,
            reviewedToday: reviewedToday,
            correctToday: correctToday,
            onStartReview: onStart ?? () {},
          ),
        ),
      ),
    ));
  }

  testWidgets('cartes à revoir : nombre, durée, répartition et bouton',
      (tester) async {
    var started = false;
    await pumpPanel(
      tester,
      cards: [
        card('a', 0, 0),
        card('b', 0, -2),
        card('c', 0, 0),
        card('d', 2, 0),
        card('e', 3, 5),
      ],
      onStart: () => started = true,
    );

    expect(find.text('4'), findsOneWidget);
    expect(find.text('cards to review'), findsOneWidget);
    expect(find.text('≈ 1 min'), findsOneWidget);
    expect(find.text('× 3'), findsOneWidget);
    expect(find.text('× 1'), findsOneWidget);

    await tester.tap(find.text('Start Review'));
    expect(started, isTrue);
  });

  testWidgets('révision faite : bilan du jour et prochaine échéance',
      (tester) async {
    await pumpPanel(
      tester,
      cards: [card('a', 1, 1), card('b', 1, 1), card('c', 0, 1), card('d', 4, 9)],
      hasReviewedToday: true,
      reviewedToday: 4,
      correctToday: 3,
    );

    expect(find.text('Review done!'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('3 cards'), findsOneWidget);
    expect(find.text('Start Review'), findsNothing);
  });

  testWidgets('rien à revoir : prochaine échéance dans plusieurs jours',
      (tester) async {
    await pumpPanel(tester, cards: [card('a', 3, 4), card('b', 3, 8)]);

    expect(find.text('Nothing to review today'), findsOneWidget);
    expect(find.text('In 4 days'), findsOneWidget);
    expect(find.text('1 card'), findsOneWidget);
  });

  testWidgets('aucune carte', (tester) async {
    await pumpPanel(tester, cards: []);
    expect(find.text('No cards yet'), findsOneWidget);
  });
}
