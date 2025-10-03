import 'dart:io';
import 'dart:typed_data';

/// Interface for file management and storage operations
abstract class IFileService {
  // Directory Management
  Future<Directory> getAppDocumentsDirectory();
  Future<Directory> getArtworksDirectory();
  Future<Directory> getColoringDirectory();
  Future<Directory> getCacheDirectory();

  // File Operations
  Future<File> saveImageFile(String fileName, Uint8List imageData);
  Future<File> saveJsonFile(String fileName, Map<String, dynamic> jsonData);
  Future<Map<String, dynamic>?> loadJsonFile(String fileName);
  Future<Uint8List?> loadImageFile(String fileName);
  Future<bool> deleteFile(String fileName);
  Future<bool> fileExists(String fileName);

  // Storage Management
  Future<int> getStorageUsage();
  Future<int> getAvailableStorage();
  Future<void> cleanupTempFiles();
  Future<void> cleanupOrphanedFiles();

  // Backup and Restore
  Future<String> createBackup();
  Future<void> restoreFromBackup(String backupPath);
}

/// Custom exceptions for file operations
class FileServiceException implements Exception {
  final String operation;
  final String details;
  FileServiceException(this.operation, this.details);
  String toString() => 'File service error during $operation: $details';
}

class InsufficientStorageException implements Exception {
  final int requiredBytes;
  final int availableBytes;
  InsufficientStorageException(this.requiredBytes, this.availableBytes);
  String toString() => 'Insufficient storage: need $requiredBytes bytes, only $availableBytes available';
}

class FileNotFoundException implements Exception {
  final String fileName;
  FileNotFoundException(this.fileName);
  String toString() => 'File not found: $fileName';
}

class BackupCorruptedException implements Exception {
  final String backupPath;
  final String reason;
  BackupCorruptedException(this.backupPath, this.reason);
  String toString() => 'Backup corrupted at $backupPath: $reason';
}
