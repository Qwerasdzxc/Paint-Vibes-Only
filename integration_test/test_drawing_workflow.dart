import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

/// Integration test for complete drawing workflow
/// Tests the end-to-end drawing experience
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Drawing Workflow Integration Tests', () {
    testWidgets('complete drawing workflow - navigation and UI interaction', (WidgetTester tester) async {
      // ARRANGE - Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT & ASSERT - Drawing workflow steps

      // Step 1: Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App launched successfully');

      // Step 2: Navigate to Drawing tab (use first brush icon found)
      final drawingTab = find.byIcon(Icons.brush).first;
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();
      print('✓ Navigated to Drawing tab');

      // Step 3: Verify drawing screen loaded
      expect(find.text('Paint Vibes Only'), findsOneWidget);
      print('✓ Drawing screen loaded');

      // Step 4: Test tool selection
      final toolButtons = find.byType(FloatingActionButton);
      if (toolButtons.evaluate().isNotEmpty) {
        await tester.tap(toolButtons.first);
        await tester.pumpAndSettle();
        print('✓ Tool selection tested');
      }

      // Step 5: Test canvas interaction
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();
        print('✓ Canvas drawing interaction tested');
      }

      // Step 6: Test UI controls
      final controlButtons = find.byType(IconButton);
      if (controlButtons.evaluate().isNotEmpty) {
        // Test first available control (likely undo/redo/clear)
        await tester.tap(controlButtons.first);
        await tester.pumpAndSettle();
        print('✓ UI controls tested');
      }

      print('🎨 Drawing workflow test completed successfully');
    });

    testWidgets('drawing with multiple tools and interactions', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to drawing screen
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      // ACT - Multi-tool drawing workflow
      print('Testing multi-tool interactions...');

      // Test different drawing actions
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw multiple strokes
        for (int i = 0; i < 3; i++) {
          await tester.dragFrom(
            Offset(canvasSize.width * 0.2 + (i * 50), canvasSize.height * 0.4),
            Offset(canvasSize.width * 0.8 - (i * 30), canvasSize.height * 0.6),
          );
          await tester.pumpAndSettle();
        }
        print('✓ Multiple strokes drawn');
      }

      // Test tool switching by tapping different buttons
      final actionButtons = find.byType(FloatingActionButton);
      for (int i = 0; i < actionButtons.evaluate().length && i < 3; i++) {
        await tester.tap(actionButtons.at(i));
        await tester.pumpAndSettle();
      }
      print('✓ Tool switching tested');

      print('🎭 Multi-tool workflow test completed successfully');
    });

    testWidgets('UI responsiveness and performance validation', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to drawing screen
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      // ACT - Performance test with rapid interactions
      print('Testing UI responsiveness...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Rapid drawing gestures to test performance
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 5; i++) {
          await tester.dragFrom(
            Offset(canvasSize.width * 0.1 + (i * 20), canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.9 - (i * 20), canvasSize.height * 0.7),
          );
          // Minimal settle time to test responsiveness
          await tester.pump(const Duration(milliseconds: 16)); // ~60fps
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('✓ Rapid drawing completed in ${elapsedMs}ms');

        // Verify reasonable performance (should be under 1 second for 5 strokes)
        expect(elapsedMs, lessThan(1000), reason: 'Drawing should be responsive');
      }

      // Test rapid button tapping
      final buttons = find.byType(FloatingActionButton);
      if (buttons.evaluate().isNotEmpty) {
        for (int i = 0; i < 3; i++) {
          await tester.tap(buttons.first);
          await tester.pump(const Duration(milliseconds: 100));
        }
        print('✓ Rapid button interactions tested');
      }

      print('⚡ Performance validation completed successfully');
    });

    testWidgets('navigation between drawing and other screens', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT - Test navigation flow
      print('Testing navigation flow...');

      // Start at drawing
      final drawingTab = find.byIcon(Icons.brush).first;
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();
      print('✓ At Drawing screen');

      // Navigate to Gallery
      final galleryTab = find.byIcon(Icons.photo_library);
      if (galleryTab.evaluate().isNotEmpty) {
        await tester.tap(galleryTab);
        await tester.pumpAndSettle();
        print('✓ Navigated to Gallery');
      }

      // Navigate to Coloring
      final coloringTab = find.byIcon(Icons.palette);
      if (coloringTab.evaluate().isNotEmpty) {
        await tester.tap(coloringTab);
        await tester.pumpAndSettle();
        print('✓ Navigated to Coloring');
      }

      // Return to Drawing
      final returnDrawingTab = find.byIcon(Icons.brush).first;
      await tester.tap(returnDrawingTab);
      await tester.pumpAndSettle();
      print('✓ Returned to Drawing');

      print('🧭 Navigation flow test completed successfully');
    });
  });
}
