import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/screens/box_detail_screen.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';

void main() {
  testWidgets('box detail follows changes to the card list', (tester) async {
    final cat = Flashcard.create(id: '1', frontText: 'chat', backText: 'cat');
    final dog = Flashcard.create(id: '2', frontText: 'chien', backText: 'dog');
    final cards = ValueNotifier<List<Flashcard>>([cat, dog]);
    addTearDown(cards.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: BoxDetailScreen(
        level: 0,
        cards: cards,
        onDelete: (_) {},
        onEdit: (_) {},
      ),
    ));
    expect(find.text('chat'), findsOneWidget);
    expect(find.text('chien'), findsOneWidget);

    // One card moved to another box, the other deleted.
    cards.value = [cat.moveTo(3)];
    await tester.pump();

    expect(find.text('chat'), findsNothing);
    expect(find.text('chien'), findsNothing);
    expect(find.text('No cards in Box 0'), findsOneWidget);
  });
}
