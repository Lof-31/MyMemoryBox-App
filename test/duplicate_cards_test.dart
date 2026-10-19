import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/screens/create_card_screen.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';
import 'package:my_memory_box_app/widgets/flashcard_tile.dart';

void main() {
  final cat = Flashcard.create(id: '1', frontText: 'chat', backText: 'cat');
  final dog = Flashcard.create(id: '2', frontText: 'chien', backText: 'dog');

  Widget app(Widget home) => MaterialApp(
        theme: buildAppTheme(Colors.blue, Brightness.light),
        home: home,
      );

  test('existsIn ignores case, spaces and the edited card itself', () {
    expect(Flashcard.existsIn([cat], ' Chat ', 'CAT'), isTrue);
    expect(Flashcard.existsIn([cat], 'chat', 'kitty'), isFalse);
    expect(Flashcard.existsIn([cat], 'chat', 'cat', exceptId: '1'), isFalse);
  });

  testWidgets('creating a card that already exists is refused',
      (tester) async {
    await tester.pumpWidget(app(CreateCardScreen(existingCards: [cat])));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Chat');
    await tester.enterText(fields.at(1), 'cat ');
    await tester.tap(find.text('Save Flashcard'));
    await tester.pump();

    expect(find.text('This card already exists'), findsOneWidget);
    expect(find.byType(CreateCardScreen), findsOneWidget);
  });

  testWidgets('editing a card into a duplicate is refused', (tester) async {
    Flashcard? edited;
    await tester.pumpWidget(app(Scaffold(
      body: FlashcardTile(
        card: dog,
        allCards: [cat, dog],
        onDelete: (_) {},
        onEdit: (c) => edited = c,
      ),
    )));

    await tester.tap(find.text('chien'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Card'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'chat');
    await tester.enterText(fields.at(1), 'cat');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('This card already exists'), findsOneWidget);
    expect(edited, isNull);

    // Keeping its own text is not a duplicate.
    await tester.enterText(fields.at(0), 'Chien');
    await tester.enterText(fields.at(1), 'dog');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(edited?.frontText, 'Chien');
  });
}
