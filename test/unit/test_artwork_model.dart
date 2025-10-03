import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/shared/models/artwork.dart';

void main() {
  group('Artwork Tests', () {
    test('should create artwork with required fields', () {
      final artwork = Artwork(
        id: 'test-id',
        title: 'Test Artwork',
        description: 'Test Description',
        thumbnailPath: '/path/to/thumbnail.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(100, 100),
        tags: ['test', 'artwork'],
        isCompleted: false,
        strokeCount: 0,
      );

      expect(artwork.id, 'test-id');
      expect(artwork.title, 'Test Artwork');
      expect(artwork.description, 'Test Description');
      expect(artwork.originalSize.width, 100);
      expect(artwork.originalSize.height, 100);
      expect(artwork.isCompleted, false);
      expect(artwork.strokeCount, 0);
    });

    test('should handle completed and in-progress artwork states', () {
      final inProgressArtwork = Artwork(
        id: 'progress-id',
        title: 'In Progress Drawing',
        description: 'Still working on this',
        thumbnailPath: '/path/to/thumb1.jpg',
        fullImagePath: '/path/to/image1.jpg',
        canvasDataPath: '/path/to/canvas1.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(200, 150),
        tags: ['wip'],
        isCompleted: false,
        strokeCount: 25,
      );

      final completedArtwork = Artwork(
        id: 'completed-id',
        title: 'Finished Artwork',
        description: 'Completed masterpiece',
        thumbnailPath: '/path/to/thumb2.jpg',
        fullImagePath: '/path/to/image2.jpg',
        canvasDataPath: '/path/to/canvas2.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(300, 200),
        tags: ['finished', 'masterpiece'],
        isCompleted: true,
        strokeCount: 150,
      );

      expect(inProgressArtwork.isCompleted, false);
      expect(completedArtwork.isCompleted, true);
      expect(inProgressArtwork.strokeCount, 25);
      expect(completedArtwork.strokeCount, 150);
    });

    test('should validate artwork properties', () {
      final validArtwork = Artwork(
        id: 'valid-id',
        title: 'Valid Artwork',
        description: 'Valid description',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(100, 100),
        tags: ['valid'],
        isCompleted: false,
        strokeCount: 10,
      );

      expect(validArtwork.isValid, true);

      final invalidArtwork = Artwork(
        id: 'invalid-id',
        title: '', // Empty title
        description: 'Invalid description',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(0, 100), // Invalid size
        tags: ['invalid'],
        isCompleted: false,
        strokeCount: -1, // Negative stroke count
      );

      expect(invalidArtwork.isValid, false);
    });

    test('should handle tags and metadata', () {
      final artwork = Artwork(
        id: 'tags-test',
        title: 'Tagged Artwork',
        description: 'Artwork with tags',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(100, 100),
        tags: ['landscape', 'nature', 'digital'],
        isCompleted: true,
        strokeCount: 50,
      );

      expect(artwork.tags.length, 3);
      expect(artwork.tags.contains('landscape'), true);
      expect(artwork.tags.contains('nature'), true);
      expect(artwork.tags.contains('digital'), true);
    });

    test('should handle stroke count progression', () {
      final artwork = Artwork(
        id: 'stroke-test',
        title: 'Stroke Progress',
        description: 'Testing stroke count',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(100, 100),
        tags: ['progress'],
        isCompleted: false,
        strokeCount: 75,
      );

      expect(artwork.strokeCount, 75);

      // Test updating stroke count through copyWith
      final updatedArtwork = artwork.copyWith(strokeCount: 100, isCompleted: true, lastModified: DateTime.now());

      expect(updatedArtwork.strokeCount, 100);
      expect(updatedArtwork.isCompleted, true);
      expect(updatedArtwork.id, artwork.id); // Should preserve original id
    });

    test('should handle creation and modification timestamps', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));

      final artwork = Artwork(
        id: 'timestamp-test',
        title: 'Timestamp Test',
        description: 'Testing timestamps',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: now,
        lastModified: later,
        originalSize: const Size(100, 100),
        tags: ['test'],
        isCompleted: false,
        strokeCount: 0,
      );

      expect(artwork.createdAt, now);
      expect(artwork.lastModified, later);
      expect(artwork.lastModified.isAfter(artwork.createdAt), true);
    });

    test('should convert to and from JSON', () {
      final originalArtwork = Artwork(
        id: 'json-test',
        title: 'JSON Test',
        description: 'Testing JSON serialization',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime(2023, 1, 1, 12, 0, 0),
        lastModified: DateTime(2023, 1, 2, 12, 0, 0),
        originalSize: const Size(150, 200),
        tags: ['json', 'test'],
        isCompleted: true,
        strokeCount: 42,
      );

      final json = originalArtwork.toJson();
      final restoredArtwork = Artwork.fromJson(json);

      expect(restoredArtwork.id, originalArtwork.id);
      expect(restoredArtwork.title, originalArtwork.title);
      expect(restoredArtwork.description, originalArtwork.description);
      expect(restoredArtwork.thumbnailPath, originalArtwork.thumbnailPath);
      expect(restoredArtwork.fullImagePath, originalArtwork.fullImagePath);
      expect(restoredArtwork.canvasDataPath, originalArtwork.canvasDataPath);
      expect(restoredArtwork.createdAt, originalArtwork.createdAt);
      expect(restoredArtwork.lastModified, originalArtwork.lastModified);
      expect(restoredArtwork.originalSize.width, originalArtwork.originalSize.width);
      expect(restoredArtwork.originalSize.height, originalArtwork.originalSize.height);
      expect(restoredArtwork.tags, originalArtwork.tags);
      expect(restoredArtwork.isCompleted, originalArtwork.isCompleted);
      expect(restoredArtwork.strokeCount, originalArtwork.strokeCount);
    });

    test('should handle copyWith method', () {
      final originalArtwork = Artwork(
        id: 'copy-test',
        title: 'Original Title',
        description: 'Original description',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime(2023, 1, 1),
        lastModified: DateTime(2023, 1, 1),
        originalSize: const Size(100, 100),
        tags: ['original'],
        isCompleted: false,
        strokeCount: 10,
      );

      final modifiedArtwork = originalArtwork.copyWith(
        title: 'Modified Title',
        isCompleted: true,
        strokeCount: 25,
        tags: ['modified', 'updated'],
      );

      expect(modifiedArtwork.id, originalArtwork.id);
      expect(modifiedArtwork.title, 'Modified Title');
      expect(modifiedArtwork.description, originalArtwork.description);
      expect(modifiedArtwork.isCompleted, true);
      expect(modifiedArtwork.strokeCount, 25);
      expect(modifiedArtwork.tags, ['modified', 'updated']);
    });

    test('should handle equality comparison', () {
      final artwork1 = Artwork(
        id: 'equality-test',
        title: 'Test',
        description: 'Test description',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime(2023, 1, 1),
        lastModified: DateTime(2023, 1, 1),
        originalSize: const Size(100, 100),
        tags: ['test'],
        isCompleted: false,
        strokeCount: 0,
      );

      final artwork2 = Artwork(
        id: 'equality-test', // Same ID
        title: 'Different Title', // Different title but same ID
        description: 'Different description',
        thumbnailPath: '/different/path/thumb.jpg',
        fullImagePath: '/different/path/image.jpg',
        canvasDataPath: '/different/path/canvas.json',
        createdAt: DateTime(2023, 2, 1),
        lastModified: DateTime(2023, 2, 1),
        originalSize: const Size(200, 200),
        tags: ['different'],
        isCompleted: true,
        strokeCount: 50,
      );

      final artwork3 = Artwork(
        id: 'different-id',
        title: 'Test',
        description: 'Test description',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime(2023, 1, 1),
        lastModified: DateTime(2023, 1, 1),
        originalSize: const Size(100, 100),
        tags: ['test'],
        isCompleted: false,
        strokeCount: 0,
      );

      // Equality is based on ID only
      expect(artwork1, equals(artwork2));
      expect(artwork1, isNot(equals(artwork3)));
      expect(artwork1.hashCode, equals(artwork2.hashCode));
      expect(artwork1.hashCode, isNot(equals(artwork3.hashCode)));
    });

    test('should handle toString method', () {
      final artwork = Artwork(
        id: 'toString-test',
        title: 'String Test',
        description: 'Testing toString',
        thumbnailPath: '/path/to/thumb.jpg',
        fullImagePath: '/path/to/image.jpg',
        canvasDataPath: '/path/to/canvas.json',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        originalSize: const Size(100, 100),
        tags: ['test'],
        isCompleted: false,
        strokeCount: 15,
      );

      final stringRepresentation = artwork.toString();
      expect(stringRepresentation.contains('toString-test'), true);
      expect(stringRepresentation.contains('String Test'), true);
      expect(stringRepresentation.contains('15'), true);
    });
  });
}
