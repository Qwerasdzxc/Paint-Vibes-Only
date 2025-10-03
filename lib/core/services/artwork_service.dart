import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/drawing_canvas.dart';

/// Implementation of IArtworkService for managing artwork operations
class ArtworkService implements IArtworkService {
  // In-memory storage for artworks (in a real app, this would use persistent storage)
  final Map<String, Artwork> _artworks = {};
  final Map<String, Set<String>> _tagIndex = {}; // tag -> set of artwork IDs
  final Map<String, String> _artworkData = {}; // artwork ID -> serialized canvas data

  // Storage paths for files (these would be managed by FileService in real implementation)
  final Map<String, Uint8List> _thumbnails = {};
  final Map<String, Uint8List> _fullImages = {};

  @override
  Future<List<Artwork>> getAllArtworks() async {
    return _artworks.values.toList();
  }

  @override
  Future<Artwork?> getArtwork(String artworkId) async {
    return _artworks[artworkId];
  }

  @override
  Future<Artwork> createArtwork(String title, DrawingCanvas canvas) async {
    final now = DateTime.now();
    final artworkId = 'artwork_${now.millisecondsSinceEpoch}';

    // Generate paths for storage
    final thumbnailPath = 'thumbnails/$artworkId.png';
    final fullImagePath = 'images/$artworkId.png';
    final canvasDataPath = 'canvas_data/$artworkId.json';

    // Create artwork instance
    final artwork = Artwork(
      id: artworkId,
      title: title,
      description: 'Created on ${now.day}/${now.month}/${now.year}',
      thumbnailPath: thumbnailPath,
      fullImagePath: fullImagePath,
      canvasDataPath: canvasDataPath,
      createdAt: now,
      lastModified: now,
      originalSize: canvas.dimensions,
      tags: [],
      isCompleted: canvas.strokes.isNotEmpty,
      strokeCount: canvas.strokes.length,
    );

    // Store artwork and canvas data
    _artworks[artworkId] = artwork;
    _artworkData[artworkId] = jsonEncode(canvas.toJson());

    // Generate and store thumbnail
    await _generateAndStoreThumbnail(artworkId, canvas);

    return artwork;
  }

  @override
  Future<void> updateArtwork(Artwork artwork) async {
    if (!_artworks.containsKey(artwork.id)) {
      throw ArtworkNotFoundException(artwork.id);
    }

    final updatedArtwork = artwork.copyWith(lastModified: DateTime.now());
    _artworks[artwork.id] = updatedArtwork;

    // Update tag index
    _updateTagIndex(artwork.id, artwork.tags);
  }

  @override
  Future<bool> deleteArtwork(String artworkId) async {
    if (!_artworks.containsKey(artworkId)) {
      return false;
    }

    final artwork = _artworks[artworkId]!;

    // Remove from tag index
    for (final tag in artwork.tags) {
      _tagIndex[tag]?.remove(artworkId);
      if (_tagIndex[tag]?.isEmpty ?? false) {
        _tagIndex.remove(tag);
      }
    }

    // Remove all associated data
    _artworks.remove(artworkId);
    _artworkData.remove(artworkId);
    _thumbnails.remove(artworkId);
    _fullImages.remove(artworkId);

    return true;
  }

  @override
  Future<List<Artwork>> getArtworksByTag(String tag) async {
    final artworkIds = _tagIndex[tag] ?? <String>{};
    return artworkIds.map((id) => _artworks[id]).where((artwork) => artwork != null).cast<Artwork>().toList();
  }

  @override
  Future<List<Artwork>> searchArtworks(String query) async {
    if (query.isEmpty) return getAllArtworks();

    final lowerQuery = query.toLowerCase();
    return _artworks.values
        .where(
          (artwork) =>
              artwork.title.toLowerCase().contains(lowerQuery) ||
              artwork.description.toLowerCase().contains(lowerQuery) ||
              artwork.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)),
        )
        .toList();
  }

  @override
  Future<List<Artwork>> getArtworksSorted(GallerySortOrder sortOrder) async {
    final artworks = await getAllArtworks();

    switch (sortOrder) {
      case GallerySortOrder.dateCreated:
        artworks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case GallerySortOrder.dateModified:
        artworks.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case GallerySortOrder.title:
        artworks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case GallerySortOrder.strokeCount:
        artworks.sort((a, b) => b.strokeCount.compareTo(a.strokeCount));
        break;
    }

    return artworks;
  }

  @override
  Future<Uint8List> generateThumbnail(String artworkId) async {
    final existingThumbnail = _thumbnails[artworkId];
    if (existingThumbnail != null) {
      return existingThumbnail;
    }

    // If no cached thumbnail, generate from canvas data
    final canvasDataJson = _artworkData[artworkId];
    if (canvasDataJson != null) {
      final canvasData = jsonDecode(canvasDataJson) as Map<String, dynamic>;
      final canvas = DrawingCanvas.fromJson(canvasData);
      await _generateAndStoreThumbnail(artworkId, canvas);
      return _thumbnails[artworkId]!;
    }

    throw ArtworkNotFoundException(artworkId);
  }

  @override
  Future<void> shareArtwork(String artworkId) async {
    final artwork = _artworks[artworkId];
    if (artwork == null) {
      throw ArtworkNotFoundException(artworkId);
    }

    // In a real implementation, this would use the share_plus package
    // For now, we just simulate the sharing process
    await Future.delayed(const Duration(milliseconds: 500));

    // Could trigger events via EventService here
    print('Sharing artwork: ${artwork.title}');
  }

  @override
  Future<String> exportArtwork(String artworkId, ExportFormat format) async {
    final artwork = _artworks[artworkId];
    if (artwork == null) {
      throw ArtworkNotFoundException(artworkId);
    }

    // Generate export path based on format
    final extension = _getFileExtension(format);
    final exportPath = 'exports/${artwork.id}_export.$extension';

    // In a real implementation, this would convert and save the artwork
    // to the specified format using the appropriate rendering engine
    await Future.delayed(const Duration(seconds: 1));

    return exportPath;
  }

  @override
  Future<void> addTagToArtwork(String artworkId, String tag) async {
    final artwork = _artworks[artworkId];
    if (artwork == null) {
      throw ArtworkNotFoundException(artworkId);
    }

    if (artwork.tags.contains(tag)) {
      return; // Tag already exists
    }

    final updatedTags = List<String>.from(artwork.tags)..add(tag);
    final updatedArtwork = artwork.copyWith(tags: updatedTags, lastModified: DateTime.now());

    _artworks[artworkId] = updatedArtwork;

    // Update tag index
    _tagIndex.putIfAbsent(tag, () => <String>{}).add(artworkId);
  }

  @override
  Future<void> removeTagFromArtwork(String artworkId, String tag) async {
    final artwork = _artworks[artworkId];
    if (artwork == null) {
      throw ArtworkNotFoundException(artworkId);
    }

    if (!artwork.tags.contains(tag)) {
      return; // Tag doesn't exist
    }

    final updatedTags = List<String>.from(artwork.tags)..remove(tag);
    final updatedArtwork = artwork.copyWith(tags: updatedTags, lastModified: DateTime.now());

    _artworks[artworkId] = updatedArtwork;

    // Update tag index
    _tagIndex[tag]?.remove(artworkId);
    if (_tagIndex[tag]?.isEmpty ?? false) {
      _tagIndex.remove(tag);
    }
  }

  @override
  Future<List<String>> getAllTags() async {
    return _tagIndex.keys.toList()..sort();
  }

  // Private helper methods

  Future<void> _generateAndStoreThumbnail(String artworkId, DrawingCanvas canvas) async {
    // In a real implementation, this would render the canvas to an image
    // For now, we create a mock thumbnail
    final thumbnailData = await _renderCanvasToThumbnail(canvas);
    _thumbnails[artworkId] = thumbnailData;
  }

  Future<Uint8List> _renderCanvasToThumbnail(DrawingCanvas canvas) async {
    // Mock implementation - in reality would use Flutter's Canvas/CustomPainter
    // to render the drawing canvas to a thumbnail image

    // Create a simple mock image data (1x1 pixel PNG)
    final mockPngData = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==',
    );

    return Uint8List.fromList(mockPngData);
  }

  void _updateTagIndex(String artworkId, List<String> tags) {
    // Remove artwork from all current tag associations
    _tagIndex.forEach((tag, artworkIds) => artworkIds.remove(artworkId));

    // Add artwork to new tag associations
    for (final tag in tags) {
      _tagIndex.putIfAbsent(tag, () => <String>{}).add(artworkId);
    }

    // Clean up empty tag entries
    _tagIndex.removeWhere((tag, artworkIds) => artworkIds.isEmpty);
  }

  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.png:
        return 'png';
      case ExportFormat.jpg:
        return 'jpg';
      case ExportFormat.svg:
        return 'svg';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }
}

/// Exception thrown when an artwork is not found
class ArtworkNotFoundException implements Exception {
  final String artworkId;
  ArtworkNotFoundException(this.artworkId);

  @override
  String toString() => 'Artwork not found: $artworkId';
}
