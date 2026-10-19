import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/screens/review_screen.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';

void main() {
  testWidgets('system back mid-session returns the answers given so far',
      (tester) async {
    final cards = [
      Flashcard.create(id: '1', frontText: 'chat', backText: 'cat'),
      Flashcard.create(id: '2', frontText: 'chien', backText: 'dog'),
    ];
    List<Flashcard>? result;

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await Navigator.push<List<Flashcard>>(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewScreen(cards: cards),
              ),
            );
          },
          child: const Text('start'),
        ),
      ),
    ));
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remembered'));
    await tester.pumpAndSettle();
    expect(find.text('Card 2 / 2'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ReviewScreen), findsNothing);
    expect(result, isNotNull);
    expect(result!.map((c) => c.id), ['1']);
    expect(result!.single.level, 1);
  });
}
