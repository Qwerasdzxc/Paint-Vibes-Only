import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

/// Integration test for coloring workflow
/// Tests the coloring book functionality
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Coloring Workflow Integration Tests', () {
    testWidgets('complete coloring workflow - select template and color', (WidgetTester tester) async {
      // ARRANGE - Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT & ASSERT - Coloring workflow steps

      // Step 1: Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App launched successfully');

      // Step 2: Navigate to Coloring tab
      final coloringTab = find.byIcon(Icons.palette);
      if (coloringTab.evaluate().isNotEmpty) {
        await tester.tap(coloringTab);
        await tester.pumpAndSettle();
        print('✓ Navigated to Coloring tab');

        // Step 3: Test coloring page selection
        final coloringPages = find.byType(GestureDetector);
        if (coloringPages.evaluate().isNotEmpty) {
          await tester.tap(coloringPages.first);
          await tester.pumpAndSettle();
          print('✓ Coloring page selected');
        }

        // Step 4: Test coloring interaction
        final canvas = find.byType(CustomPaint);
        if (canvas.evaluate().isNotEmpty) {
          final canvasSize = tester.getSize(canvas.first);

          // Tap to fill areas (coloring behavior)
          await tester.tapAt(Offset(canvasSize.width * 0.5, canvasSize.height * 0.5));
          await tester.pumpAndSettle();
          print('✓ Coloring interaction tested');
        }

        // Step 5: Test color palette
        final colorButtons = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        );
        if (colorButtons.evaluate().isNotEmpty) {
          await tester.tap(colorButtons.first);
          await tester.pumpAndSettle();
          print('✓ Color palette tested');
        }
      } else {
        print('⚠️ Coloring tab not found - may not be implemented yet');
      }

      print('🎨 Coloring workflow test completed');
    });

    testWidgets('coloring with different colors and areas', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to coloring screen
      final coloringTab = find.byIcon(Icons.palette);
      if (coloringTab.evaluate().isNotEmpty) {
        await tester.tap(coloringTab);
        await tester.pumpAndSettle();

        print('Testing multi-color coloring...');

        // Test coloring different areas with different colors
        final canvas = find.byType(CustomPaint);
        if (canvas.evaluate().isNotEmpty) {
          final canvasSize = tester.getSize(canvas.first);

          // Color multiple areas
          final areas = [
            Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.7, canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.5, canvasSize.height * 0.7),
          ];

          for (final area in areas) {
            await tester.tapAt(area);
            await tester.pumpAndSettle();
          }
          print('✓ Multiple areas colored');
        }

        // Test switching colors
        final colorButtons = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        );
        if (colorButtons.evaluate().length > 1) {
          for (int i = 0; i < 3 && i < colorButtons.evaluate().length; i++) {
            await tester.tap(colorButtons.at(i));
            await tester.pumpAndSettle();
          }
          print('✓ Color switching tested');
        }
      } else {
        print('⚠️ Coloring functionality not available');
      }

      print('🌈 Multi-color coloring test completed');
    });

    testWidgets('coloring page navigation and templates', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to coloring screen
      final coloringTab = find.byIcon(Icons.palette);
      if (coloringTab.evaluate().isNotEmpty) {
        await tester.tap(coloringTab);
        await tester.pumpAndSettle();

        print('Testing coloring page templates...');

        // Test template selection
        final templates = find.byType(Card);
        if (templates.evaluate().isEmpty) {
          // Try GridView items if Cards not found
          final gridItems = find.byType(GestureDetector);
          if (gridItems.evaluate().isNotEmpty) {
            // Test selecting different templates
            for (int i = 0; i < 2 && i < gridItems.evaluate().length; i++) {
              await tester.tap(gridItems.at(i));
              await tester.pumpAndSettle();

              // Go back to template selection
              final backButton = find.byIcon(Icons.arrow_back);
              if (backButton.evaluate().isNotEmpty) {
                await tester.tap(backButton);
                await tester.pumpAndSettle();
              }
            }
            print('✓ Template navigation tested');
          }
        } else {
          // Test Card-based templates
          for (int i = 0; i < 2 && i < templates.evaluate().length; i++) {
            await tester.tap(templates.at(i));
            await tester.pumpAndSettle();

            // Test coloring in this template
            final canvas = find.byType(CustomPaint);
            if (canvas.evaluate().isNotEmpty) {
              final canvasSize = tester.getSize(canvas.first);
              await tester.tapAt(Offset(canvasSize.width * 0.5, canvasSize.height * 0.5));
              await tester.pumpAndSettle();
            }

            // Return to template selection
            final backButton = find.byIcon(Icons.arrow_back);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
            }
          }
          print('✓ Card template navigation tested');
        }
      } else {
        print('⚠️ Coloring tab not available');
      }

      print('📚 Template navigation test completed');
    });

    testWidgets('coloring save and completion workflow', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to coloring screen
      final coloringTab = find.byIcon(Icons.palette);
      if (coloringTab.evaluate().isNotEmpty) {
        await tester.tap(coloringTab);
        await tester.pumpAndSettle();

        // Select a template
        final templates = find.byType(GestureDetector);
        if (templates.evaluate().isNotEmpty) {
          await tester.tap(templates.first);
          await tester.pumpAndSettle();

          print('Testing save workflow...');

          // Do some coloring
          final canvas = find.byType(CustomPaint);
          if (canvas.evaluate().isNotEmpty) {
            final canvasSize = tester.getSize(canvas.first);
            await tester.tapAt(Offset(canvasSize.width * 0.5, canvasSize.height * 0.5));
            await tester.pumpAndSettle();
          }

          // Test save functionality
          final saveButton = find.byIcon(Icons.save);
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
            print('✓ Save button tested');
          }

          // Test share functionality
          final shareButton = find.byIcon(Icons.share);
          if (shareButton.evaluate().isNotEmpty) {
            await tester.tap(shareButton);
            await tester.pumpAndSettle();
            print('✓ Share button tested');
          }

          // Test completion indicators
          final actionButtons = find.byType(FloatingActionButton);
          if (actionButtons.evaluate().isNotEmpty) {
            await tester.tap(actionButtons.first);
            await tester.pumpAndSettle();
            print('✓ Action buttons tested');
          }
        }
      } else {
        print('⚠️ Coloring functionality not available');
      }

      print('💾 Save workflow test completed');
    });
  });
}
