import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';
import 'package:my_memory_box_app/widgets/review_card.dart';

/// Hôte minimal qui reproduit l'usage de l'écran de révision.
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

  testWidgets('affiche la question, la boîte et le côté, puis se retourne',
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

  testWidgets('le balayage est ignoré tant que la réponse est cachée',
      (tester) async {
    final results = await pumpHost(tester, GlobalKey());

    await tester.drag(find.text('chat'), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(results, isEmpty);
    expect(find.text('chat'), findsOneWidget);
  });

  testWidgets('balayer à droite = retenue, à gauche = oubliée',
      (tester) async {
    final results = await pumpHost(tester, GlobalKey());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('cat'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('balayer à gauche = oubliée', (tester) async {
    final results = await pumpHost(tester, GlobalKey());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('cat'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });

  testWidgets('un petit glissement revient au centre sans répondre',
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

  testWidgets('les boutons déclenchent la même sortie animée', (tester) async {
    final key = GlobalKey<ReviewCardState>();
    final results = await pumpHost(tester, key);
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();

    key.currentState!.swipeAway(true);
    key.currentState!.swipeAway(false); // ignoré : la carte part déjà
    await tester.pumpAndSettle();
    expect(results, [true]);
  });
}
