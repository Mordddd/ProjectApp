import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Learning Hub smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Learning Hub'), findsOneWidget);
    expect(find.text('Fitur populer'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'sorting');
    await tester.pumpAndSettle();

    expect(find.text('Sorting'), findsOneWidget);
    expect(find.text('Urutkan data angka'), findsOneWidget);
    expect(find.text('Kelola profil dan video anggota'), findsNothing);
  });
}
