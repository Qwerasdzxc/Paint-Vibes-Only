import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/coloring_progress.dart';

import 'package:painter/shared/models/user_gallery.dart';
import 'package:painter/shared/models/color_palette.dart';

/// Manages file system storage operations for the painting app
/// Handles artwork persistence, canvas serialization, and metadata management
class FileStorageManager {
  static const String _artworksDir = 'artworks';
  static const String _coloringDir = 'coloring';
  static const String _settingsDir = 'settings';
  static const String _cacheDir = 'cache';
  static const String _tempDir = 'temp';

  static const String _canvasFileName = 'canvas.json';
  static const String _imageFileName = 'image.png';
  static const String _thumbnailFileName = 'thumbnail.png';
  static const String _metadataFileName = 'metadata.json';

  Directory? _documentsDirectory;
  Directory? _cacheDirectory;

  /// Initialize the storage manager and create directory structure
  Future<void> initialize() async {
    _documentsDirectory = await getApplicationDocumentsDirectory();
    _cacheDirectory = await getTemporaryDirectory();

    // Create directory structure
    await _createDirectoryStructure();
  }

  /// Create the required directory structure
  Future<void> _createDirectoryStructure() async {
    if (_documentsDirectory == null) return;

    final directories = [
      '$_artworksDir',
      '$_coloringDir/pages',
      '$_coloringDir/progress',
      '$_settingsDir',
      '$_cacheDir/thumbnails',
      '$_tempDir',
    ];

    for (final dirPath in directories) {
      final dir = Directory('${_documentsDirectory!.path}/$dirPath');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  /// Save artwork with canvas data and rendered image
  Future<String> saveArtwork(Artwork artwork, DrawingCanvas canvas, Uint8List imageData) async {
    await _ensureInitialized();

    final artworkDir = Directory('${_documentsDirectory!.path}/$_artworksDir/${artwork.id}');
    if (!await artworkDir.exists()) {
      await artworkDir.create(recursive: true);
    }

    // Save canvas data as JSON
    final canvasFile = File('${artworkDir.path}/$_canvasFileName');
    final canvasJson = _serializeCanvas(canvas);
    await canvasFile.writeAsString(json.encode(canvasJson));

    // Save full-resolution image
    final imageFile = File('${artworkDir.path}/$_imageFileName');
    await imageFile.writeAsBytes(imageData);

    // Generate and save thumbnail
    final thumbnailData = await _generateThumbnail(imageData, const Size(200, 200));
    final thumbnailFile = File('${artworkDir.path}/$_thumbnailFileName');
    await thumbnailFile.writeAsBytes(thumbnailData);

    // Update artwork metadata with file paths
    final updatedArtwork = artwork.copyWith(
      canvasDataPath: canvasFile.path,
      fullImagePath: imageFile.path,
      thumbnailPath: thumbnailFile.path,
      lastModified: DateTime.now(),
    );

    // Save artwork metadata
    await _saveArtworkMetadata(updatedArtwork);

    return updatedArtwork.id;
  }

  /// Load artwork by ID
  Future<Artwork?> loadArtwork(String artworkId) async {
    await _ensureInitialized();

    final artworkDir = Directory('${_documentsDirectory!.path}/$_artworksDir/$artworkId');
    if (!await artworkDir.exists()) return null;

    final metadataFile = File('${artworkDir.path}/$_metadataFileName');
    if (!await metadataFile.exists()) return null;

    try {
      final metadataJson = await metadataFile.readAsString();
      final metadata = json.decode(metadataJson);
      return Artwork.fromJson(metadata);
    } catch (e) {
      debugPrint('Error loading artwork metadata: $e');
      return null;
    }
  }

  /// Load canvas data for artwork
  Future<DrawingCanvas?> loadCanvasData(String artworkId) async {
    await _ensureInitialized();

    final canvasFile = File('${_documentsDirectory!.path}/$_artworksDir/$artworkId/$_canvasFileName');
    if (!await canvasFile.exists()) return null;

    try {
      final canvasJson = await canvasFile.readAsString();
      final canvasData = json.decode(canvasJson);
      return _deserializeCanvas(canvasData);
    } catch (e) {
      debugPrint('Error loading canvas data: $e');
      return null;
    }
  }

  /// Get all artworks metadata
  Future<List<Artwork>> getAllArtworks() async {
    await _ensureInitialized();

    final artworksDir = Directory('${_documentsDirectory!.path}/$_artworksDir');
    if (!await artworksDir.exists()) return [];

    final artworks = <Artwork>[];
    await for (final entity in artworksDir.list()) {
      if (entity is Directory) {
        final artworkId = entity.uri.pathSegments.last;
        final artwork = await loadArtwork(artworkId);
        if (artwork != null) {
          artworks.add(artwork);
        }
      }
    }

    return artworks;
  }

  /// Delete artwork and all associated files
  Future<bool> deleteArtwork(String artworkId) async {
    await _ensureInitialized();

    final artworkDir = Directory('${_documentsDirectory!.path}/$_artworksDir/$artworkId');
    if (!await artworkDir.exists()) return false;

    try {
      await artworkDir.delete(recursive: true);
      return true;
    } catch (e) {
      debugPrint('Error deleting artwork: $e');
      return false;
    }
  }

  /// Save coloring progress
  Future<void> saveColoringProgress(ColoringProgress progress, DrawingCanvas canvas, Uint8List imageData) async {
    await _ensureInitialized();

    final progressDir = Directory('${_documentsDirectory!.path}/$_coloringDir/progress/${progress.id}');
    if (!await progressDir.exists()) {
      await progressDir.create(recursive: true);
    }

    // Save canvas state
    final canvasFile = File('${progressDir.path}/$_canvasFileName');
    final canvasJson = _serializeCanvas(canvas);
    await canvasFile.writeAsString(json.encode(canvasJson));

    // Save progress image
    final imageFile = File('${progressDir.path}/$_imageFileName');
    await imageFile.writeAsBytes(imageData);

    // Update progress with file paths
    final updatedProgress = progress.copyWith(
      canvasDataPath: canvasFile.path,
      progressImagePath: imageFile.path,
      lastWorkedOn: DateTime.now(),
    );

    // Save progress metadata
    final metadataFile = File('${progressDir.path}/$_metadataFileName');
    await metadataFile.writeAsString(json.encode(updatedProgress.toJson()));
  }

  /// Load coloring progress
  Future<ColoringProgress?> loadColoringProgress(String progressId) async {
    await _ensureInitialized();

    final metadataFile = File('${_documentsDirectory!.path}/$_coloringDir/progress/$progressId/$_metadataFileName');
    if (!await metadataFile.exists()) return null;

    try {
      final progressJson = await metadataFile.readAsString();
      final progressData = json.decode(progressJson);
      return ColoringProgress.fromJson(progressData);
    } catch (e) {
      debugPrint('Error loading coloring progress: $e');
      return null;
    }
  }

  /// Get all coloring progress entries
  Future<List<ColoringProgress>> getAllColoringProgress() async {
    await _ensureInitialized();

    final progressDir = Directory('${_documentsDirectory!.path}/$_coloringDir/progress');
    if (!await progressDir.exists()) return [];

    final progressList = <ColoringProgress>[];
    await for (final entity in progressDir.list()) {
      if (entity is Directory) {
        final progressId = entity.uri.pathSegments.last;
        final progress = await loadColoringProgress(progressId);
        if (progress != null) {
          progressList.add(progress);
        }
      }
    }

    return progressList;
  }

  /// Save user gallery settings
  Future<void> saveGallerySettings(UserGallery gallery) async {
    await _ensureInitialized();

    final settingsFile = File('${_documentsDirectory!.path}/$_settingsDir/gallery.json');
    await settingsFile.writeAsString(json.encode(gallery.toJson()));
  }

  /// Load user gallery settings
  Future<UserGallery?> loadGallerySettings() async {
    await _ensureInitialized();

    final settingsFile = File('${_documentsDirectory!.path}/$_settingsDir/gallery.json');
    if (!await settingsFile.exists()) return null;

    try {
      final galleryJson = await settingsFile.readAsString();
      final galleryData = json.decode(galleryJson);
      return UserGallery.fromJson(galleryData);
    } catch (e) {
      debugPrint('Error loading gallery settings: $e');
      return null;
    }
  }

  /// Save color palette
  Future<void> saveColorPalette(ColorPalette palette) async {
    await _ensureInitialized();

    final paletteFile = File('${_documentsDirectory!.path}/$_settingsDir/palette.json');
    await paletteFile.writeAsString(json.encode(palette.toJson()));
  }

  /// Load color palette
  Future<ColorPalette?> loadColorPalette() async {
    await _ensureInitialized();

    final paletteFile = File('${_documentsDirectory!.path}/$_settingsDir/palette.json');
    if (!await paletteFile.exists()) return null;

    try {
      final paletteJson = await paletteFile.readAsString();
      final paletteData = json.decode(paletteJson);
      return ColorPalette.fromJson(paletteData);
    } catch (e) {
      debugPrint('Error loading color palette: $e');
      return null;
    }
  }

  /// Get storage usage statistics
  Future<Map<String, int>> getStorageUsage() async {
    await _ensureInitialized();

    final stats = <String, int>{};
    final directories = [_artworksDir, _coloringDir, _settingsDir, _cacheDir];

    for (final dirName in directories) {
      final dir = Directory('${_documentsDirectory!.path}/$dirName');
      if (await dir.exists()) {
        int size = 0;
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              // Ignore files that can't be read
            }
          }
        }
        stats[dirName] = size;
      }
    }

    return stats;
  }

  /// Clear cached files
  Future<void> clearCache() async {
    await _ensureInitialized();

    final cacheDir = Directory('${_documentsDirectory!.path}/$_cacheDir');
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (e) {
          debugPrint('Error clearing cache file: $e');
        }
      }
    }

    // Recreate cache directory structure
    await Directory('${_documentsDirectory!.path}/$_cacheDir/thumbnails').create(recursive: true);
  }

  /// Export artwork as file for sharing
  Future<File?> exportArtwork(String artworkId) async {
    await _ensureInitialized();

    final imageFile = File('${_documentsDirectory!.path}/$_artworksDir/$artworkId/$_imageFileName');
    if (!await imageFile.exists()) return null;

    final tempFile = File('${_cacheDirectory!.path}/export_${DateTime.now().millisecondsSinceEpoch}.png');
    await imageFile.copy(tempFile.path);

    return tempFile;
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (_documentsDirectory == null || _cacheDirectory == null) {
      await initialize();
    }
  }

  Future<void> _saveArtworkMetadata(Artwork artwork) async {
    final metadataFile = File('${_documentsDirectory!.path}/$_artworksDir/${artwork.id}/$_metadataFileName');
    await metadataFile.writeAsString(json.encode(artwork.toJson()));
  }

  Map<String, dynamic> _serializeCanvas(DrawingCanvas canvas) {
    return {
      'id': canvas.id,
      'version': '1.0',
      'dimensions': {'width': canvas.dimensions.width, 'height': canvas.dimensions.height},
      'backgroundColor': {
        'r': canvas.backgroundColor.red,
        'g': canvas.backgroundColor.green,
        'b': canvas.backgroundColor.blue,
        'a': canvas.backgroundColor.alpha,
      },
      'strokes': canvas.strokes
          .map(
            (stroke) => {
              'id': stroke.id,
              'tool': stroke.tool.name,
              'color': {
                'r': stroke.color.red,
                'g': stroke.color.green,
                'b': stroke.color.blue,
                'a': stroke.color.alpha,
              },
              'brushSize': stroke.brushSize,
              'opacity': stroke.opacity,
              'points': stroke.points.map((point) => {'x': point.dx, 'y': point.dy}).toList(),
              'timestamp': stroke.timestamp.toIso8601String(),
            },
          )
          .toList(),
      'lastModified': canvas.lastModified.toIso8601String(),
    };
  }

  DrawingCanvas _deserializeCanvas(Map<String, dynamic> data) {
    return DrawingCanvas.fromJson(data);
  }

  Future<Uint8List> _generateThumbnail(Uint8List imageData, Size thumbnailSize) async {
    // This would need actual image processing
    // For now, return the original image data
    // In a real implementation, use image package to resize
    return imageData;
  }
}
