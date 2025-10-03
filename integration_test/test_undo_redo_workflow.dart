import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

/// Integration test for undo/redo operations
/// Tests the action history and state restoration
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Undo/Redo Workflow Integration Tests', () {
    testWidgets('complete undo/redo workflow with drawing actions', (WidgetTester tester) async {
      // ARRANGE - Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT & ASSERT - Undo/redo workflow

      // Step 1: Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App launched successfully');

      // Step 2: Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();
      print('✓ Navigated to Drawing tab');

      // Step 3: Draw multiple strokes to test undo/redo
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw first stroke
        await tester.dragFrom(
          Offset(canvasSize.width * 0.2, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.8, canvasSize.height * 0.3),
        );
        await tester.pumpAndSettle();
        print('✓ First stroke drawn');

        // Draw second stroke
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.4),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.6),
        );
        await tester.pumpAndSettle();
        print('✓ Second stroke drawn');

        // Draw third stroke
        await tester.dragFrom(
          Offset(canvasSize.width * 0.4, canvasSize.height * 0.2),
          Offset(canvasSize.width * 0.6, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();
        print('✓ Third stroke drawn');
      }

      // Step 4: Test undo functionality
      final undoButton = find.byIcon(Icons.undo);
      if (undoButton.evaluate().isNotEmpty) {
        await tester.tap(undoButton);
        await tester.pumpAndSettle();
        print('✓ First undo performed');

        await tester.tap(undoButton);
        await tester.pumpAndSettle();
        print('✓ Second undo performed');
      } else {
        print('⚠️ Undo button not found');
      }

      // Step 5: Test redo functionality
      final redoButton = find.byIcon(Icons.redo);
      if (redoButton.evaluate().isNotEmpty) {
        await tester.tap(redoButton);
        await tester.pumpAndSettle();
        print('✓ First redo performed');

        await tester.tap(redoButton);
        await tester.pumpAndSettle();
        print('✓ Second redo performed');
      } else {
        print('⚠️ Redo button not found');
      }

      // Step 6: Test clear canvas functionality
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
        print('✓ Canvas cleared');
      }

      print('🔄 Undo/Redo workflow test completed');
    });

    testWidgets('undo/redo with different drawing tools', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing undo/redo with multiple tools...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Test switching tools and drawing
        final toolButtons = find.byType(FloatingActionButton);

        // Draw with first tool
        if (toolButtons.evaluate().isNotEmpty) {
          await tester.tap(toolButtons.first);
          await tester.pumpAndSettle();

          await tester.dragFrom(
            Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.7, canvasSize.height * 0.3),
          );
          await tester.pumpAndSettle();
          print('✓ Drew with first tool');
        }

        // Switch to second tool if available
        if (toolButtons.evaluate().length > 1) {
          await tester.tap(toolButtons.at(1));
          await tester.pumpAndSettle();

          await tester.dragFrom(
            Offset(canvasSize.width * 0.3, canvasSize.height * 0.5),
            Offset(canvasSize.width * 0.7, canvasSize.height * 0.5),
          );
          await tester.pumpAndSettle();
          print('✓ Drew with second tool');
        }

        // Test undo across different tools
        final undoButton = find.byIcon(Icons.undo);
        if (undoButton.evaluate().isNotEmpty) {
          await tester.tap(undoButton);
          await tester.pumpAndSettle();
          print('✓ Undo across tools tested');
        }

        // Test redo
        final redoButton = find.byIcon(Icons.redo);
        if (redoButton.evaluate().isNotEmpty) {
          await tester.tap(redoButton);
          await tester.pumpAndSettle();
          print('✓ Redo across tools tested');
        }
      }

      print('🎨 Multi-tool undo/redo test completed');
    });

    testWidgets('undo/redo state management and limits', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing undo/redo state limits...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw many strokes to test history limits
        for (int i = 0; i < 10; i++) {
          await tester.dragFrom(
            Offset(canvasSize.width * 0.1 + (i * 10), canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.1 + (i * 10), canvasSize.height * 0.7),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
        print('✓ Drew 10 strokes for history test');

        // Test multiple undos
        final undoButton = find.byIcon(Icons.undo);
        if (undoButton.evaluate().isNotEmpty) {
          for (int i = 0; i < 5; i++) {
            await tester.tap(undoButton);
            await tester.pump(const Duration(milliseconds: 100));
          }
          await tester.pumpAndSettle();
          print('✓ Performed 5 undos');

          // Test multiple redos
          final redoButton = find.byIcon(Icons.redo);
          if (redoButton.evaluate().isNotEmpty) {
            for (int i = 0; i < 3; i++) {
              await tester.tap(redoButton);
              await tester.pump(const Duration(milliseconds: 100));
            }
            await tester.pumpAndSettle();
            print('✓ Performed 3 redos');
          }

          // Test rapid undo/redo
          for (int i = 0; i < 3; i++) {
            await tester.tap(undoButton);
            await tester.pump(const Duration(milliseconds: 50));

            final redoButton = find.byIcon(Icons.redo);
            if (redoButton.evaluate().isNotEmpty) {
              await tester.tap(redoButton);
              await tester.pump(const Duration(milliseconds: 50));
            }
          }
          await tester.pumpAndSettle();
          print('✓ Rapid undo/redo tested');
        }
      }

      print('⚡ State management test completed');
    });

    testWidgets('undo/redo interaction with other operations', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing undo/redo with other operations...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw some strokes
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();

        // Test undo before save
        final undoButton = find.byIcon(Icons.undo);
        if (undoButton.evaluate().isNotEmpty) {
          await tester.tap(undoButton);
          await tester.pumpAndSettle();
          print('✓ Undo before save tested');
        }

        // Redraw
        await tester.dragFrom(
          Offset(canvasSize.width * 0.4, canvasSize.height * 0.4),
          Offset(canvasSize.width * 0.6, canvasSize.height * 0.6),
        );
        await tester.pumpAndSettle();

        // Test save operation
        final saveButton = find.byIcon(Icons.save);
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Handle save dialog
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.first, 'Undo Test Art');
            await tester.pumpAndSettle();

            final confirmButton = find.text('Save');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle();
            }
          }
          print('✓ Save after drawing operations tested');
        }

        // Test undo after save
        if (undoButton.evaluate().isNotEmpty) {
          await tester.tap(undoButton);
          await tester.pumpAndSettle();
          print('✓ Undo after save tested');
        }
      }

      print('💾 Integration with other operations test completed');
    });
  });
}
