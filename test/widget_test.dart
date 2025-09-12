// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clauselens/main.dart';

void main() {
  testWidgets('Clauselens app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Clauselens'), findsOneWidget);

    // Verify that the main headline is displayed
    expect(find.text('Legal Documents'), findsOneWidget);

    // Verify that the gradient text is displayed
    expect(find.text('Simplified..'), findsOneWidget);

    // Verify that the CTA button is displayed
    expect(find.text('Try Clauselens'), findsOneWidget);

    // Verify that the login button is displayed
    expect(find.text('Log in'), findsOneWidget);
  });
}
