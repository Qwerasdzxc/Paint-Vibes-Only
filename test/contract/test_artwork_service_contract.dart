import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/core/services/artwork_service.dart';

/// Contract test for IArtworkService interface
/// This test now uses the real implementation to verify it meets the contract
void main() {
  group('IArtworkService Contract Tests', () {
    late IArtworkService service;
    late DrawingCanvas testCanvas;
    late Artwork testArtwork;

    setUp(() async {
      // Now using the real implementation to test if it passes the contract
      service = ArtworkService();

      // Create test canvas for artwork creation
      testCanvas = DrawingCanvas.empty(id: 'test_canvas', dimensions: const Size(800, 600));

      // Create a test artwork for operations that need existing artwork
      testArtwork = await service.createArtwork('Test Artwork', testCanvas);
    });

    group('CRUD Operations', () {
      test('getAllArtworks should return list of artworks', () async {
        final artworks = await service.getAllArtworks();
        expect(artworks, isA<List<Artwork>>());
      });

      test('getArtwork should return artwork by ID', () async {
        const testId = 'test_artwork_id';
        final artwork = await service.getArtwork(testId);
        expect(artwork, anyOf(isA<Artwork>(), isNull));
      });

      test('createArtwork should create new artwork from canvas', () async {
        final canvas = DrawingCanvas.empty(
          id: 'test_canvas',
          dimensions: const Size(800, 600),
          backgroundColor: const Color(0xFFFFFFFF),
        );

        final artwork = await service.createArtwork('Test Artwork', canvas);
        expect(artwork, isA<Artwork>());
        expect(artwork.title, equals('Test Artwork'));
      });

      test('updateArtwork should modify existing artwork', () async {
        final updatedArtwork = testArtwork.copyWith(title: 'Updated Title', description: 'Updated description');

        await service.updateArtwork(updatedArtwork);

        // Verify the artwork was updated
        final retrieved = await service.getArtwork(testArtwork.id);
        expect(retrieved?.title, equals('Updated Title'));
      });

      test('deleteArtwork should remove artwork by ID', () async {
        final result = await service.deleteArtwork(testArtwork.id);
        expect(result, isTrue);

        // Verify artwork was deleted
        final retrieved = await service.getArtwork(testArtwork.id);
        expect(retrieved, isNull);
      });
    });

    group('Gallery Management', () {
      test('getArtworksByTag should return filtered artworks', () async {
        const tag = 'landscape';
        final artworks = await service.getArtworksByTag(tag);
        expect(artworks, isA<List<Artwork>>());
      });

      test('searchArtworks should return matching artworks', () async {
        const query = 'sunset';
        final artworks = await service.searchArtworks(query);
        expect(artworks, isA<List<Artwork>>());
      });

      test('getArtworksSorted should return sorted artworks', () async {
        final artworks = await service.getArtworksSorted(GallerySortOrder.dateCreated);
        expect(artworks, isA<List<Artwork>>());
      });
    });

    group('Artwork Operations', () {
      test('generateThumbnail should create thumbnail image', () async {
        final thumbnail = await service.generateThumbnail(testArtwork.id);
        expect(thumbnail, isA<Uint8List>());
      });

      test('shareArtwork should share artwork externally', () async {
        await service.shareArtwork(testArtwork.id);
        // No exception should be thrown
      });

      test('exportArtwork should export in specified format', () async {
        final exportPath = await service.exportArtwork(testArtwork.id, ExportFormat.png);
        expect(exportPath, isA<String>());
      });
    });

    group('Metadata Management', () {
      test('addTagToArtwork should add tag to artwork', () async {
        const tag = 'nature';
        await service.addTagToArtwork(testArtwork.id, tag);

        // Verify tag was added
        final updated = await service.getArtwork(testArtwork.id);
        expect(updated?.tags, contains(tag));
      });

      test('removeTagFromArtwork should remove tag from artwork', () async {
        const tag = 'temporary';
        // First add a tag
        await service.addTagToArtwork(testArtwork.id, tag);

        // Then remove it
        await service.removeTagFromArtwork(testArtwork.id, tag);

        // Verify tag was removed
        final updated = await service.getArtwork(testArtwork.id);
        expect(updated?.tags, isNot(contains(tag)));
      });

      test('getAllTags should return list of all tags', () async {
        final tags = await service.getAllTags();
        expect(tags, isA<List<String>>());
      });
    });
  });
}
