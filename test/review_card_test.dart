import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';
import 'package:my_memory_box_app/widgets/review_card.dart';

class _Host extends StatefulWidget {
  final Flashcard card;
  final ValueChanged<bool> onSwiped;
  final GlobalKey<ReviewCardState> cardKey;

  const _Host({
    required this.card,
    required this.onSwiped,
    required this.cardKey,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ReviewCard(
            key: widget.cardKey,
            card: widget.card,
            showAnswer: showAnswer,
            onTap: () => setState(() => showAnswer = !showAnswer),
            onSwiped: widget.onSwiped,
          ),
        ),
      ),
    );
  }
}

void main() {
  final card = Flashcard(
    id: '1',
    frontText: 'chat',
    backText: 'cat',
    level: 3,
    nextReviewDate: DateTime.now(),
  );

  Future<List<bool>> pumpHost(
    WidgetTester tester,
    GlobalKey<ReviewCardState> key,
  ) async {
    final results = <bool>[];
    await tester.pumpWidget(
      _Host(card: card, onSwiped: results.add, cardKey: key),
    );
    return results;
  }

  testWidgets('shows question, box and side, then flips',
      (tester) async {
    await pumpHost(tester, GlobalKey());

    expect(find.text('chat'), findsOneWidget);
    expect(find.text('Box 3'), findsOneWidget);
    expect(find.text('QUESTION · FRONT'), findsOneWidget);

    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    expect(find.text('cat'), findsOneWidget);
    expect(find.text('ANSWER · BACK'), findsOneWidget);
  });

  testWidgets('swipe is ignored while the answer is hidden',
      (tester) async {
    final results = await pumpHost(tester, GlobalKey());

    await tester.drag(find.text('chat'), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(results, isEmpty);
    expect(find.text('chat'), findsOneWidget);
  });

  testWidgets('swipe right means remembered',
      (tester) async {
    final results = await pumpHost(tester, GlobalKey());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('cat'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('swipe left means forgot', (tester) async {
    final results = await pumpHost(tester, GlobalKey());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('cat'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });

  testWidgets('a short drag springs back without answering',
      (tester) async {
    final results = await pumpHost(tester, GlobalKey());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    await tester.timedDrag(
      find.text('cat'),
      const Offset(40, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(results, isEmpty);
  });

  testWidgets('buttons trigger the same animated exit', (tester) async {
    final key = GlobalKey<ReviewCardState>();
    final results = await pumpHost(tester, key);
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    key.currentState!.swipeAway(true);
    key.currentState!.swipeAway(false);
    await tester.pumpAndSettle();
    expect(results, [true]);
  });
}
