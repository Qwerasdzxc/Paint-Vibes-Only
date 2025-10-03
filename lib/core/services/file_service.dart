import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:painter/core/storage/i_file_service.dart';

/// Implementation of IFileService for managing file operations
class FileService implements IFileService {
  // Cache for directory paths to avoid repeated system calls
  Directory? _appDocumentsDir;
  Directory? _artworksDir;
  Directory? _coloringDir;
  Directory? _cacheDir;

  @override
  Future<Directory> getAppDocumentsDirectory() async {
    _appDocumentsDir ??= await getApplicationDocumentsDirectory();
    return _appDocumentsDir!;
  }

  @override
  Future<Directory> getArtworksDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    _artworksDir ??= Directory('${appDir.path}/artworks');

    if (!await _artworksDir!.exists()) {
      await _artworksDir!.create(recursive: true);
    }

    return _artworksDir!;
  }

  @override
  Future<Directory> getColoringDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    _coloringDir ??= Directory('${appDir.path}/coloring');

    if (!await _coloringDir!.exists()) {
      await _coloringDir!.create(recursive: true);
    }

    return _coloringDir!;
  }

  @override
  Future<Directory> getCacheDirectory() async {
    _cacheDir ??= await getTemporaryDirectory();
    return _cacheDir!;
  }

  @override
  Future<File> saveImageFile(String fileName, Uint8List imageData) async {
    try {
      final artworksDir = await getArtworksDirectory();
      final file = File('${artworksDir.path}/$fileName');

      // Create parent directory if it doesn't exist
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Check storage space
      final availableSpace = await getAvailableStorage();
      if (availableSpace < imageData.length) {
        throw InsufficientStorageException(imageData.length, availableSpace);
      }

      await file.writeAsBytes(imageData);
      return file;
    } catch (e) {
      throw FileServiceException('saveImageFile', e.toString());
    }
  }

  @override
  Future<File> saveJsonFile(String fileName, Map<String, dynamic> jsonData) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');

      // Create parent directory if it doesn't exist
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final jsonString = jsonEncode(jsonData);
      final jsonBytes = utf8.encode(jsonString);

      // Check storage space
      final availableSpace = await getAvailableStorage();
      if (availableSpace < jsonBytes.length) {
        throw InsufficientStorageException(jsonBytes.length, availableSpace);
      }

      await file.writeAsString(jsonString);
      return file;
    } catch (e) {
      throw FileServiceException('saveJsonFile', e.toString());
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
      throw FileServiceException('loadJsonFile', e.toString());
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
      throw FileServiceException('loadImageFile', e.toString());
    }
  }

  @override
  Future<bool> deleteFile(String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');

      if (!await file.exists()) {
        return false;
      }

      await file.delete();
      return true;
    } catch (e) {
      throw FileServiceException('deleteFile', e.toString());
    }
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      throw FileServiceException('fileExists', e.toString());
    }
  }

  @override
  Future<int> getStorageUsage() async {
    try {
      final appDir = await getAppDocumentsDirectory();
      int totalSize = 0;

      if (await appDir.exists()) {
        await for (final entity in appDir.list(recursive: true)) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;
    } catch (e) {
      throw FileServiceException('getStorageUsage', e.toString());
    }
  }

  @override
  Future<int> getAvailableStorage() async {
    try {
      // This is a simplified implementation - in reality would need platform-specific code
      // to get actual available storage space
      final usedSpace = await getStorageUsage();
      const estimatedMaxSpace = 1024 * 1024 * 1024; // 1GB estimate

      return estimatedMaxSpace - usedSpace;
    } catch (e) {
      throw FileServiceException('getAvailableStorage', e.toString());
    }
  }

  @override
  Future<void> cleanupTempFiles() async {
    try {
      final cacheDir = await getCacheDirectory();
      final tempDir = Directory('${cacheDir.path}/temp');

      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      throw FileServiceException('cleanupTempFiles', e.toString());
    }
  }

  @override
  Future<void> cleanupOrphanedFiles() async {
    try {
      final artworksDir = await getArtworksDirectory();
      final coloringDir = await getColoringDirectory();

      // Load metadata files to identify orphaned files
      final artworkMetadata = await loadJsonFile('artworks/metadata.json');

      // Get list of referenced files from metadata
      final referencedFiles = <String>{};

      if (artworkMetadata != null) {
        final artworks = artworkMetadata['artworks'] as List?;
        if (artworks != null) {
          for (final artwork in artworks) {
            final artworkMap = artwork as Map<String, dynamic>;
            referencedFiles.add(artworkMap['thumbnailPath'] as String? ?? '');
            referencedFiles.add(artworkMap['fullImagePath'] as String? ?? '');
            referencedFiles.add(artworkMap['canvasDataPath'] as String? ?? '');
          }
        }
      }

      // Clean up unreferenced artwork files
      await _cleanupUnreferencedFiles(artworksDir, referencedFiles);
      await _cleanupUnreferencedFiles(coloringDir, referencedFiles);
    } catch (e) {
      throw FileServiceException('cleanupOrphanedFiles', e.toString());
    }
  }

  @override
  Future<String> createBackup() async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final cacheDir = await getCacheDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory('${cacheDir.path}/backup_$timestamp');

      // Create backup directory
      await backupDir.create(recursive: true);

      // Copy all app data to backup directory
      await _copyDirectory(appDir, backupDir);

      // Create backup metadata
      final backupMetadata = {
        'timestamp': timestamp,
        'version': '1.0.0',
        'appVersion': await _getAppVersion(),
        'totalSize': await _getDirectorySize(backupDir),
      };

      final metadataFile = File('${backupDir.path}/backup_metadata.json');
      await metadataFile.writeAsString(jsonEncode(backupMetadata));

      return backupDir.path;
    } catch (e) {
      throw FileServiceException('createBackup', e.toString());
    }
  }

  @override
  Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);

      if (!await backupDir.exists()) {
        throw FileNotFoundException(backupPath);
      }

      // Validate backup integrity
      final metadataFile = File('${backupDir.path}/backup_metadata.json');
      if (!await metadataFile.exists()) {
        throw BackupCorruptedException(backupPath, 'Missing backup metadata');
      }

      final metadataContent = await metadataFile.readAsString();
      final metadata = jsonDecode(metadataContent) as Map<String, dynamic>;

      // Basic validation
      if (!metadata.containsKey('timestamp') || !metadata.containsKey('version')) {
        throw BackupCorruptedException(backupPath, 'Invalid backup metadata format');
      }

      // Clear current app data
      final appDir = await getAppDocumentsDirectory();
      if (await appDir.exists()) {
        await for (final entity in appDir.list()) {
          await entity.delete(recursive: true);
        }
      }

      // Restore data from backup (excluding metadata file)
      await for (final entity in backupDir.list()) {
        if (entity.path != metadataFile.path) {
          final relativePath = entity.path.replaceFirst('${backupDir.path}/', '');
          final targetPath = '${appDir.path}/$relativePath';

          if (entity is Directory) {
            await Directory(targetPath).create(recursive: true);
            await _copyDirectory(entity, Directory(targetPath));
          } else if (entity is File) {
            await entity.copy(targetPath);
          }
        }
      }

      // Clear cached directories
      _appDocumentsDir = null;
      _artworksDir = null;
      _coloringDir = null;
      _cacheDir = null;
    } catch (e) {
      if (e is BackupCorruptedException || e is FileNotFoundException) {
        rethrow;
      }
      throw FileServiceException('restoreFromBackup', e.toString());
    }
  }

  // Private helper methods

  Future<void> _cleanupUnreferencedFiles(Directory directory, Set<String> referencedFiles) async {
    if (!await directory.exists()) return;

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst(await getAppDocumentsDirectory().then((d) => d.path + '/'), '');
        if (!referencedFiles.contains(relativePath)) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: true)) {
      final relativePath = entity.path.replaceFirst(source.path, '');
      final newPath = '${destination.path}$relativePath';

      if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }

  Future<int> _getDirectorySize(Directory directory) async {
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

  Future<String> _getAppVersion() async {
    // In a real implementation, this would read from pubspec.yaml or package info
    return '1.0.0';
  }
}
