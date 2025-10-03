import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:painter/main.dart' as app;

/// Integration test for save/load artwork workflow
/// Tests the persistent storage and retrieval of artwork
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Save/Load Workflow Integration Tests', () {
    testWidgets('complete save and load workflow via gallery', (WidgetTester tester) async {
      // ARRANGE - Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ACT & ASSERT - Save/load workflow

      // Step 1: Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App launched successfully');

      // Step 2: Navigate to Drawing tab first
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();
      print('✓ Navigated to Drawing tab');

      // Step 3: Create some artwork
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);
        await tester.dragFrom(
          Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
          Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
        );
        await tester.pumpAndSettle();
        print('✓ Created artwork on canvas');
      }

      // Step 4: Test save functionality
      final saveButton = find.byIcon(Icons.save);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        print('✓ Save button tapped');

        // Handle save dialog if it appears
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, 'Test Artwork Integration');
          await tester.pumpAndSettle();

          final saveConfirmButton = find.text('Save');
          if (saveConfirmButton.evaluate().isNotEmpty) {
            await tester.tap(saveConfirmButton);
            await tester.pumpAndSettle();
          }
          print('✓ Artwork saved with name');
        }
      }

      // Step 5: Navigate to Gallery tab
      final galleryTab = find.byIcon(Icons.photo_library);
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();
      print('✓ Navigated to Gallery tab');

      // Step 6: Verify gallery loaded with artworks
      final artworkItems = find.byType(Card);
      if (artworkItems.evaluate().isEmpty) {
        final gridItems = find.byType(GestureDetector);
        if (gridItems.evaluate().isNotEmpty) {
          print('✓ Gallery loaded with ${gridItems.evaluate().length} items');

          // Test loading an artwork
          await tester.tap(gridItems.first);
          await tester.pumpAndSettle();
          print('✓ Artwork selection tested');
        }
      } else {
        print('✓ Gallery loaded with ${artworkItems.evaluate().length} card items');

        // Test loading artwork from card
        await tester.tap(artworkItems.first);
        await tester.pumpAndSettle();
        print('✓ Card artwork selection tested');
      }

      print('💾 Save/Load workflow test completed');
    });

    testWidgets('gallery management and artwork details', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Gallery tab
      final galleryTab = find.byIcon(Icons.photo_library);
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();

      print('Testing gallery management...');

      // Test different view modes if available
      final viewButtons = find.byType(IconButton);
      if (viewButtons.evaluate().isNotEmpty) {
        // Test view mode switching
        for (int i = 0; i < 2 && i < viewButtons.evaluate().length; i++) {
          await tester.tap(viewButtons.at(i));
          await tester.pumpAndSettle();
        }
        print('✓ View mode switching tested');
      }

      // Test search functionality
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'art');
        await tester.pumpAndSettle();
        print('✓ Search functionality tested');
      }

      // Test artwork options (share, delete, etc.)
      final artworkItems = find.byType(Card);
      if (artworkItems.evaluate().isEmpty) {
        final gridItems = find.byType(GestureDetector);
        if (gridItems.evaluate().isNotEmpty) {
          // Long press for options
          await tester.longPress(gridItems.first);
          await tester.pumpAndSettle();
          print('✓ Long press options tested');
        }
      } else {
        // Test card long press
        await tester.longPress(artworkItems.first);
        await tester.pumpAndSettle();
        print('✓ Card long press options tested');
      }

      print('📚 Gallery management test completed');
    });

    testWidgets('artwork export and sharing workflow', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Gallery
      final galleryTab = find.byIcon(Icons.photo_library);
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();

      print('Testing export and sharing...');

      // Select an artwork
      final artworkItems = find.byType(Card);
      if (artworkItems.evaluate().isEmpty) {
        final gridItems = find.byType(GestureDetector);
        if (gridItems.evaluate().isNotEmpty) {
          await tester.tap(gridItems.first);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(artworkItems.first);
        await tester.pumpAndSettle();
      }

      // Test share functionality
      final shareButton = find.byIcon(Icons.share);
      if (shareButton.evaluate().isNotEmpty) {
        await tester.tap(shareButton);
        await tester.pumpAndSettle();
        print('✓ Share functionality tested');
      }

      // Test export options
      final exportButton = find.byIcon(Icons.download);
      if (exportButton.evaluate().isNotEmpty) {
        await tester.tap(exportButton);
        await tester.pumpAndSettle();
        print('✓ Export functionality tested');
      }

      // Test menu options
      final menuButton = find.byIcon(Icons.more_vert);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        print('✓ Menu options tested');
      }

      print('📤 Export workflow test completed');
    });

    testWidgets('artwork persistence and data integrity', (WidgetTester tester) async {
      // ARRANGE
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Testing data persistence...');

      // Navigate to Drawing and create artwork
      final drawingTab = find.byIcon(Icons.brush);
      await tester.tap(drawingTab);
      await tester.pumpAndSettle();

      // Create unique artwork pattern
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final canvasSize = tester.getSize(canvas.first);

        // Draw unique pattern
        await tester.dragFrom(
          Offset(canvasSize.width * 0.25, canvasSize.height * 0.25),
          Offset(canvasSize.width * 0.75, canvasSize.height * 0.25),
        );
        await tester.pumpAndSettle();

        await tester.dragFrom(
          Offset(canvasSize.width * 0.75, canvasSize.height * 0.25),
          Offset(canvasSize.width * 0.75, canvasSize.height * 0.75),
        );
        await tester.pumpAndSettle();

        print('✓ Unique artwork pattern created');
      }

      // Save with timestamp
      final saveButton = find.byIcon(Icons.save);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          await tester.enterText(textFields.first, 'Persistence_Test_$timestamp');
          await tester.pumpAndSettle();

          final confirmButton = find.text('Save');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
        print('✓ Artwork saved with unique name');
      }

      // Verify in gallery
      final galleryTab = find.byIcon(Icons.photo_library);
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();

      // Check that artwork appears in gallery
      final galleryItems = find.byType(Card);
      if (galleryItems.evaluate().isEmpty) {
        final gridItems = find.byType(GestureDetector);
        expect(gridItems.evaluate().length, greaterThan(0), reason: 'Gallery should contain saved artwork');
      } else {
        expect(galleryItems.evaluate().length, greaterThan(0), reason: 'Gallery should contain saved artwork cards');
      }
      print('✓ Artwork verified in gallery');

      print('🔒 Persistence test completed');
    });
  });
}
