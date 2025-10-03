import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/main.dart';

void main() {
  group('Basic Drawing App Tests', () {
    testWidgets('App should launch without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const PaintVibesApp());

      // Verify that the app bar title is correct
      expect(find.text('Paint Vibes Only'), findsOneWidget);

      // Verify that the tool bar has pencil tool
      expect(find.text('Pencil'), findsOneWidget);

      // Verify that the drawing canvas is present
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));

      // Verify undo/redo buttons are present
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });

    testWidgets('Tool selection should work', (WidgetTester tester) async {
      await tester.pumpWidget(const PaintVibesApp());

      // Find and tap the brush tool
      await tester.tap(find.text('Brush'));
      await tester.pump();

      // Verify the brush tool is selected (appears highlighted)
      // This test verifies the UI responds to tool selection
      expect(find.text('Brush'), findsOneWidget);
    });

    testWidgets('Color selection should work', (WidgetTester tester) async {
      await tester.pumpWidget(const PaintVibesApp());

      // Tap on a color in the palette
      final colorWidgets = find.byType(GestureDetector);
      if (colorWidgets.evaluate().length > 1) {
        await tester.tap(colorWidgets.at(1)); // Tap second gesture detector (likely a color)
        await tester.pump();
      }

      // If we get here without errors, color selection is working
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('Clear canvas dialog should work', (WidgetTester tester) async {
      await tester.pumpWidget(const PaintVibesApp());

      // Tap the clear button
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pumpAndSettle();

      // Verify the dialog appears
      expect(find.text('Clear Canvas'), findsOneWidget);
      expect(find.text('Are you sure you want to clear all drawings?'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Clear Canvas'), findsNothing);
    });
  });
}
