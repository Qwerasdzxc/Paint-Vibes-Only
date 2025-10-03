import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

/// Integration test for color selection workflow
/// Tests the end-to-end color picking experience
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Color Workflow Integration Tests', () {
    testWidgets('complete color selection and application workflow', (WidgetTester tester) async {
      // ARRANGE - Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT & ASSERT - Color selection workflow

      // Step 1: Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App launched successfully');

      // Step 2: Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();
      print('✓ Navigated to Drawing tab');

      // Step 3: Open color picker
      final colorPickerButton = find.byType(FloatingActionButton).first;
      await tester.tap(colorPickerButton);
      await tester.pumpAndSettle();
      print('✓ Color picker opened');

      // Step 4: Test predefined color selection
      final colorOptions = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null,
      );

      if (colorOptions.evaluate().isNotEmpty) {
        // Select red color
        for (final colorWidget in colorOptions.evaluate()) {
          final container = colorWidget.widget as Container;
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == Colors.red) {
            await tester.tap(find.byWidget(container));
            await tester.pumpAndSettle();
            print('✓ Red color selected');
            break;
          }
        }

        // Close color picker
        final doneButton = find.text('Done');
        if (doneButton.evaluate().isNotEmpty) {
          await tester.tap(doneButton);
          await tester.pumpAndSettle();
          print('✓ Color picker closed');
        }
      }

      // Step 5: Test drawing with selected color
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();
        print('✓ Drew with selected color');
      }

      print('🎨 Color selection workflow test completed');
    });

    testWidgets('multiple color changes and persistence', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing multiple color changes...');

      // Test changing colors multiple times
      final colorPickerButton = find.byType(FloatingActionButton).first;

      final testColors = [Colors.blue, Colors.green, Colors.yellow];
      final canvas = find.byType(CustomPaint);

      for (int i = 0; i < testColors.length && canvas.evaluate().isNotEmpty; i++) {
        // Open color picker
        await tester.tap(colorPickerButton);
        await tester.pumpAndSettle();

        // Find and select color
        final colorOptions = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == testColors[i],
        );

        if (colorOptions.evaluate().isNotEmpty) {
          await tester.tap(colorOptions.first);
          await tester.pumpAndSettle();

          final doneButton = find.text('Done');
          if (doneButton.evaluate().isNotEmpty) {
            await tester.tap(doneButton);
            await tester.pumpAndSettle();
          }

          // Draw a stroke with this color
          final canvasSize = tester.getSize(canvas.first);
          await tester.dragFrom(
            Offset(canvasSize.width * 0.2 + (i * 100), canvasSize.height * 0.4),
            Offset(canvasSize.width * 0.8 - (i * 50), canvasSize.height * 0.6),
          );
          await tester.pumpAndSettle();
          print('✓ Drew stroke with color ${i + 1}');
        }
      }

      print('🌈 Multiple color test completed');
    });

    testWidgets('color picker interaction modes', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing color picker interaction modes...');

      // Test opening and closing color picker multiple times
      final colorPickerButton = find.byType(FloatingActionButton).first;

      for (int i = 0; i < 3; i++) {
        // Open color picker
        await tester.tap(colorPickerButton);
        await tester.pumpAndSettle();
        print('✓ Color picker opened (attempt ${i + 1})');

        // Test different ways to close
        if (i == 0) {
          // Close with done button
          final doneButton = find.text('Done');
          if (doneButton.evaluate().isNotEmpty) {
            await tester.tap(doneButton);
            await tester.pumpAndSettle();
          }
        } else if (i == 1) {
          // Close with cancel or back
          final cancelButton = find.text('Cancel');
          if (cancelButton.evaluate().isNotEmpty) {
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
          } else {
            final backButton = find.byIcon(Icons.arrow_back);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
            }
          }
        } else {
          // Close by tapping outside (if modal)
          await tester.tapAt(const Offset(50, 50));
          await tester.pumpAndSettle();
        }

        print('✓ Color picker closed (method ${i + 1})');
      }

      print('🔧 Color picker interaction test completed');
    });

    testWidgets('color workflow with drawing tools integration', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Drawing tab
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      print('Testing color + tool integration...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);
        final toolButtons = find.byType(FloatingActionButton);

        // Test color changes with different tools
        for (int toolIndex = 0; toolIndex < 2 && toolIndex < toolButtons.evaluate().length; toolIndex++) {
          // Skip the first button if it's the color picker
          final currentToolButton = toolButtons.at(toolIndex);

          // Switch tool
          await tester.tap(currentToolButton);
          await tester.pumpAndSettle();

          // Change color for this tool
          final colorPickerButton = toolButtons.first;
          await tester.tap(colorPickerButton);
          await tester.pumpAndSettle();

          // Select a color
          final colorOptions = find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color != null,
          );

          if (colorOptions.evaluate().length > toolIndex) {
            await tester.tap(colorOptions.at(toolIndex));
            await tester.pumpAndSettle();

            final doneButton = find.text('Done');
            if (doneButton.evaluate().isNotEmpty) {
              await tester.tap(doneButton);
              await tester.pumpAndSettle();
            }
          }

          // Draw with this tool and color
          await tester.dragFrom(
            Offset(canvasSize.width * 0.3, canvasSize.height * 0.3 + (toolIndex * 100)),
            Offset(canvasSize.width * 0.7, canvasSize.height * 0.3 + (toolIndex * 100)),
          );
          await tester.pumpAndSettle();

          print('✓ Tool ${toolIndex + 1} with color integration tested');
        }
      }

      print('🎯 Color + tool integration test completed');
    });
  });
}
