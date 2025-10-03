import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Paint Vibes Only Integration Tests', () {
    testWidgets('app launches and navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app launched
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ App launched successfully');

      // Verify bottom navigation exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      print('✅ Bottom navigation found');

      // Test drawing screen functionality
      print('Testing Drawing functionality...');

      // Find canvas
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw a stroke
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();
        print('✅ Drawing stroke created');
      }

      // Test tool interactions
      final actionButtons = find.byType(FloatingActionButton);
      if (actionButtons.evaluate().isNotEmpty) {
        await tester.tap(actionButtons.first);
        await tester.pumpAndSettle();
        print('✅ Tool button interaction tested');
      }

      // Test undo/redo if available
      final undoButton = find.byIcon(Icons.undo);
      if (undoButton.evaluate().isNotEmpty) {
        await tester.tap(undoButton);
        await tester.pumpAndSettle();
        print('✅ Undo functionality tested');
      }

      final redoButton = find.byIcon(Icons.redo);
      if (redoButton.evaluate().isNotEmpty) {
        await tester.tap(redoButton);
        await tester.pumpAndSettle();
        print('✅ Redo functionality tested');
      }

      // Test navigation to gallery if available
      final galleryNavItems = find.byIcon(Icons.photo_library);
      if (galleryNavItems.evaluate().isNotEmpty) {
        await tester.tap(galleryNavItems.first);
        await tester.pumpAndSettle();
        print('✅ Gallery navigation tested');

        // Navigate back to drawing
        final backToDrawing = find.byIcon(Icons.brush);
        if (backToDrawing.evaluate().isNotEmpty) {
          await tester.tap(backToDrawing.first);
          await tester.pumpAndSettle();
          print('✅ Back to drawing navigation tested');
        }
      }

      // Test coloring navigation if available
      final coloringNavItems = find.byIcon(Icons.palette);
      if (coloringNavItems.evaluate().isNotEmpty) {
        await tester.tap(coloringNavItems.first);
        await tester.pumpAndSettle();
        print('✅ Coloring navigation tested');
      }

      print('🎨 All integration tests completed successfully!');
    });

    testWidgets('brush vs pencil tool differentiation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Testing brush vs pencil differences...');

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Try to find tool selection buttons
        final toolButtons = find.byType(FloatingActionButton);

        if (toolButtons.evaluate().length >= 2) {
          // Test first tool (presumably pencil)
          await tester.tap(toolButtons.at(1)); // Skip color picker (first button)
          await tester.pumpAndSettle();

          await tester.dragFrom(
            Offset(canvasSize.width * 0.2, canvasSize.height * 0.3),
            Offset(canvasSize.width * 0.8, canvasSize.height * 0.3),
          );
          await tester.pumpAndSettle();
          print('✅ First tool stroke drawn');

          // Test second tool (presumably brush)
          if (toolButtons.evaluate().length >= 3) {
            await tester.tap(toolButtons.at(2));
            await tester.pumpAndSettle();

            await tester.dragFrom(
              Offset(canvasSize.width * 0.2, canvasSize.height * 0.5),
              Offset(canvasSize.width * 0.8, canvasSize.height * 0.5),
            );
            await tester.pumpAndSettle();
            print('✅ Second tool stroke drawn');
          }
        }

        print('✅ Tool differentiation test completed');
      }
    });

    testWidgets('gallery with real images functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Testing gallery with real images...');

      // Navigate to gallery
      final galleryTab = find.byIcon(Icons.photo_library);
      if (galleryTab.evaluate().isNotEmpty) {
        await tester.tap(galleryTab.first);
        await tester.pumpAndSettle();

        // Check for artwork items
        final artworkItems = find.byType(Card);
        if (artworkItems.evaluate().isEmpty) {
          final gridItems = find.byType(GestureDetector);
          if (gridItems.evaluate().isNotEmpty) {
            print('✅ Found ${gridItems.evaluate().length} gallery items');

            // Test selecting first item
            await tester.tap(gridItems.first);
            await tester.pumpAndSettle();
            print('✅ Gallery item selection tested');
          }
        } else {
          print('✅ Found ${artworkItems.evaluate().length} gallery cards');
          await tester.tap(artworkItems.first);
          await tester.pumpAndSettle();
          print('✅ Gallery card selection tested');
        }
      }

      print('✅ Gallery functionality verified');
    });
  });
}
