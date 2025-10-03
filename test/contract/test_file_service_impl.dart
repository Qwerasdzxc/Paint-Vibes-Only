import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:painter/core/storage/i_file_service.dart';

/// Test implementation of FileService that works without platform dependencies
/// Uses temporary directories for testing instead of platform-specific paths
class TestFileServiceImpl implements IFileService {
  static Directory? _tempDir;

  /// Get a temporary directory for testing
  static Future<Directory> _getTempDir() async {
    _tempDir ??= await Directory.systemTemp.createTemp('painter_test_');
    return _tempDir!;
  }

  @override
  Future<Directory> getAppDocumentsDirectory() async {
    final tempDir = await _getTempDir();
    final appDocsDir = Directory('${tempDir.path}/documents');
    if (!appDocsDir.existsSync()) {
      await appDocsDir.create(recursive: true);
    }
    return appDocsDir;
  }

  @override
  Future<Directory> getArtworksDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final artworksDir = Directory('${appDir.path}/artworks');
    if (!artworksDir.existsSync()) {
      await artworksDir.create(recursive: true);
    }
    return artworksDir;
  }

  @override
  Future<Directory> getColoringDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final coloringDir = Directory('${appDir.path}/coloring');
    if (!coloringDir.existsSync()) {
      await coloringDir.create(recursive: true);
    }
    return coloringDir;
  }

  @override
  Future<Directory> getCacheDirectory() async {
    final tempDir = await _getTempDir();
    final cacheDir = Directory('${tempDir.path}/cache');
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  @override
  Future<File> saveImageFile(String fileName, Uint8List imageData) async {
    try {
      final artworksDir = await getArtworksDirectory();
      final file = File('${artworksDir.path}/$fileName');
      return await file.writeAsBytes(imageData);
    } catch (e) {
      throw Exception('File service error during saveImageFile: $e');
    }
  }

  @override
  Future<File> saveJsonFile(String fileName, Map<String, dynamic> jsonData) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      final jsonString = jsonEncode(jsonData);
      return await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('File service error during saveJsonFile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> loadJsonFile(String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('File service error during loadJsonFile: $e');
    }
  }

  @override
  Future<Uint8List?> loadImageFile(String fileName) async {
    try {
      final artworksDir = await getArtworksDirectory();
      final file = File('${artworksDir.path}/$fileName');

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsBytes();
    } catch (e) {
      throw Exception('File service error during loadImageFile: $e');
    }
  }

  @override
  Future<bool> deleteFile(String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('File service error during deleteFile: $e');
    }
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      throw Exception('File service error during fileExists: $e');
    }
  }

  @override
  Future<int> getStorageUsage() async {
    try {
      final appDir = await getAppDocumentsDirectory();
      return await _calculateDirectorySize(appDir);
    } catch (e) {
      throw Exception('File service error during getStorageUsage: $e');
    }
  }

  @override
  Future<int> getAvailableStorage() async {
    try {
      // For testing, simulate available storage
      const maxStorage = 1000000000; // 1GB
      final usedStorage = await getStorageUsage();
      return maxStorage - usedStorage;
    } catch (e) {
      throw Exception('File service error during getAvailableStorage: $e');
    }
  }

  @override
  Future<void> cleanupTempFiles() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      throw Exception('File service error during cleanupTempFiles: $e');
    }
  }

  @override
  Future<void> cleanupOrphanedFiles() async {
    try {
      final artworksDir = await getArtworksDirectory();

      // Simulate cleanup by checking for files without metadata
      await for (final entity in artworksDir.list()) {
        if (entity is File && entity.path.endsWith('.png')) {
          final metadataPath = entity.path.replaceAll('.png', '_metadata.json');
          final metadataFile = File(metadataPath);
          if (!await metadataFile.exists()) {
            // This would be an orphaned file in a real scenario
            // For testing, we'll just simulate the check
          }
        }
      }
    } catch (e) {
      throw Exception('File service error during cleanupOrphanedFiles: $e');
    }
  }

  @override
  Future<String> createBackup() async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final backupPath = '${appDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.zip';

      // For testing, create a simple backup file
      final backupFile = File(backupPath);
      await backupFile.writeAsString('backup_data');

      return backupPath;
    } catch (e) {
      throw Exception('File service error during createBackup: $e');
    }
  }

  @override
  Future<void> restoreFromBackup(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('File not found: $backupPath');
    }

    // For testing, simulate restore operation
    // In a real implementation, this would extract and restore files
  }

  /// Helper method to calculate directory size
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;

    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
    }

    return totalSize;
  }

  /// Clean up test directory
  static Future<void> cleanupTestDir() async {
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
      _tempDir = null;
    }
  }
}
