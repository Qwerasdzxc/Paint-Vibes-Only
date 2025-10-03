// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:painter/main.dart';

void main() {
  testWidgets('Paint Vibes app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame with specific size to avoid overflow
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const PaintVibesApp());

    // Verify that the app loads and shows the drawing screen
    expect(find.text('Paint Vibes Only'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
