import 'dart:typed_data';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/drawing_canvas.dart';

/// Gallery sort order options
enum GallerySortOrder { dateCreated, dateModified, title, strokeCount }

/// Abstract interface for artwork management service
abstract class IArtworkService {
  // CRUD Operations
  Future<List<Artwork>> getAllArtworks();
  Future<Artwork?> getArtwork(String artworkId);
  Future<Artwork> createArtwork(String title, DrawingCanvas canvas);
  Future<void> updateArtwork(Artwork artwork);
  Future<bool> deleteArtwork(String artworkId);

  // Gallery Management
  Future<List<Artwork>> getArtworksByTag(String tag);
  Future<List<Artwork>> searchArtworks(String query);
  Future<List<Artwork>> getArtworksSorted(GallerySortOrder sortOrder);

  // Artwork Operations
  Future<Uint8List> generateThumbnail(String artworkId);
  Future<void> shareArtwork(String artworkId);
  Future<String> exportArtwork(String artworkId, ExportFormat format);

  // Metadata Management
  Future<void> addTagToArtwork(String artworkId, String tag);
  Future<void> removeTagFromArtwork(String artworkId, String tag);
  Future<List<String>> getAllTags();
}

/// Export format options
enum ExportFormat { png, jpg, svg, pdf }

/// Custom exceptions for artwork operations
class ArtworkNotFoundException implements Exception {
  final String artworkId;
  ArtworkNotFoundException(this.artworkId);

  @override
  String toString() => 'Artwork not found: $artworkId';
}

class ArtworkCreationException implements Exception {
  final String reason;
  ArtworkCreationException(this.reason);

  @override
  String toString() => 'Failed to create artwork: $reason';
}

class ArtworkExportException implements Exception {
  final String artworkId;
  final String reason;
  ArtworkExportException(this.artworkId, this.reason);

  @override
  String toString() => 'Failed to export artwork $artworkId: $reason';
}
