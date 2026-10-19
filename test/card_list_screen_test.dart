import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/screens/card_list_screen.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';

void main() {
  testWidgets('clear button empties the search field and the filter',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: CardListScreen(
        cards: [
          Flashcard.create(id: '1', frontText: 'chat', backText: 'cat'),
          Flashcard.create(id: '2', frontText: 'chien', backText: 'dog'),
        ],
        onDelete: (_) {},
        onEdit: (_) {},
        onDeleteMany: (_) {},
        onMoveMany: (_, _) {},
      ),
    ));

    await tester.enterText(find.byType(TextField), 'chat');
    await tester.pump();
    expect(find.text('chien'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(find.text('chat'), findsOneWidget);
    expect(find.text('chien'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
