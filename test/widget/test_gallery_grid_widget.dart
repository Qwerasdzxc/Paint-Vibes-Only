import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/gallery/widgets/gallery_grid.dart';
import 'package:painter/shared/models/artwork.dart';

/// Widget test for GalleryGrid widget
/// These tests validate the gallery grid UI behavior
void main() {
  group('GalleryGrid Widget Tests', () {
    late List<Artwork> testArtworks;

    setUp(() {
      testArtworks = [
        Artwork(
          id: 'artwork1',
          title: 'Test Artwork 1',
          description: 'A test artwork',
          thumbnailPath: 'assets/test1.png',
          fullImagePath: 'assets/test1_full.png',
          canvasDataPath: 'data/test1.json',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
          originalSize: const Size(400, 300),
          tags: ['test'],
          isCompleted: true,
          strokeCount: 10,
        ),
        Artwork(
          id: 'artwork2',
          title: 'Test Artwork 2',
          description: 'Another test artwork',
          thumbnailPath: 'assets/test2.png',
          fullImagePath: 'assets/test2_full.png',
          canvasDataPath: 'data/test2.json',
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
          originalSize: const Size(400, 300),
          tags: ['test'],
          isCompleted: true,
          strokeCount: 15,
        ),
      ];
    });

    testWidgets('should render gallery grid widget', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: GalleryGrid(artworks: testArtworks)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(GalleryGrid), findsOneWidget);
    });

    testWidgets('should display artwork thumbnails', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: GalleryGrid(artworks: testArtworks)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test thumbnail rendering
      expect(find.byType(GalleryGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Test Artwork 1'), findsOneWidget);
      expect(find.text('Test Artwork 2'), findsOneWidget);
    });

    testWidgets('should handle artwork selection', (WidgetTester tester) async {
      // ARRANGE
      String? selectedArtwork;
      final testWidget = MaterialApp(
        home: Scaffold(
          body: GalleryGrid(
            artworks: testArtworks,
            onArtworkSelected: (artworkId) {
              selectedArtwork = artworkId;
            },
          ),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // ASSERT - Test artwork selection callback
      expect(find.byType(GalleryGrid), findsOneWidget);
      expect(selectedArtwork, equals('artwork1'));
    });

    testWidgets('should support grid layout customization', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: GalleryGrid(artworks: testArtworks, crossAxisCount: 3)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test grid customization
      expect(find.byType(GalleryGrid), findsOneWidget);
    });

    testWidgets('should show empty state when no artworks', (WidgetTester tester) async {
      // ARRANGE
      const testWidget = MaterialApp(
        home: Scaffold(body: GalleryGrid(artworks: [])),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(GalleryGrid), findsOneWidget);
      expect(find.text('No artworks to display'), findsOneWidget);
    });
  });
}
