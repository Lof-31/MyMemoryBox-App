import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/models/flashcard.dart';
import 'package:my_memory_box_app/screens/home_screen.dart';
import 'package:my_memory_box_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('card selection hides New Card and ends when leaving the tab',
      (tester) async {
    final card = Flashcard.create(id: '1', frontText: 'chat', backText: 'cat');
    SharedPreferences.setMockInitialValues({
      'flashcards_data': jsonEncode([card.toMap()]),
    });

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Colors.blue, Brightness.light),
      home: const HomeScreen(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Cards'));
    await tester.pumpAndSettle();
    expect(find.text('New Card'), findsOneWidget);

    await tester.tap(find.byTooltip('Select cards'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cancel'), findsOneWidget);
    expect(find.text('New Card'), findsNothing);

    await tester.tap(find.text('Daily Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Cards'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Cancel'), findsNothing);
    expect(find.byTooltip('Select cards'), findsOneWidget);
    expect(find.text('New Card'), findsOneWidget);
  });
}
