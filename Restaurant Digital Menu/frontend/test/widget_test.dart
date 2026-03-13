// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_digital_menu/main.dart';
import 'package:restaurant_digital_menu/state/app_state.dart';

void main() {
  testWidgets('App launches and shows Spice Garden', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const RestaurantMenuApp(),
      ),
    );
    // Initial frame — splash screen visible
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance past the 3-second splash auto-navigate timer
    await tester.pump(const Duration(seconds: 4));

    // Advance past dish-card stagger timers (max: 60 + 15×70 = 1110 ms)
    // plus the 400 ms entrance animation
    await tester.pump(const Duration(milliseconds: 1600));
  });
}
