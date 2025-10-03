import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:painter/core/services/file_service.dart';

/// Unit tests for file operations and storage management
/// Tests T053: Unit tests for file operations in test/unit/test_file_operations.dart
void main() {
  group('File Operations Tests', () {
    late FileService fileService;
    late Directory tempTestDir;

    setUpAll(() async {
      // Initialize test file service
      fileService = FileService();

      // Create temporary test directory
      final tempDir = await getTemporaryDirectory();
      tempTestDir = Directory('${tempDir.path}/test_painter_files');
      if (await tempTestDir.exists()) {
        await tempTestDir.delete(recursive: true);
      }
      await tempTestDir.create(recursive: true);
    });

    tearDownAll(() async {
      // Clean up test directory
      if (await tempTestDir.exists()) {
        await tempTestDir.delete(recursive: true);
      }
    });

    test('file creation and deletion should work correctly', () async {
      // ARRANGE
      const fileName = 'test_file.txt';
      final testData = Uint8List.fromList('Hello, World!'.codeUnits);

      // ACT - Save file
      final savedFile = await fileService.saveImageFile(fileName, testData);
      final exists = await fileService.fileExists(fileName);

      // Delete file
      final deleted = await fileService.deleteFile(fileName);
      final existsAfterDelete = await fileService.fileExists(fileName);

      // ASSERT
      expect(savedFile, isA<File>());
      expect(exists, isTrue);
      expect(deleted, isTrue);
      expect(existsAfterDelete, isFalse);
    });

    test('JSON file serialization should preserve data integrity', () async {
      // ARRANGE
      const fileName = 'test_data.json';
      final originalData = {
        'string_value': 'test string',
        'int_value': 42,
        'double_value': 3.14159,
        'bool_value': true,
        'list_value': [1, 2, 3, 'four'],
        'nested_object': {'color': Colors.red.value, 'timestamp': DateTime.now().millisecondsSinceEpoch},
      };

      // ACT
      await fileService.saveJsonFile(fileName, originalData);
      final loadedData = await fileService.loadJsonFile(fileName);

      // Clean up
      await fileService.deleteFile(fileName);

      // ASSERT
      expect(loadedData, isNotNull);
      expect(loadedData!['string_value'], equals(originalData['string_value']));
      expect(loadedData['int_value'], equals(originalData['int_value']));
      expect(loadedData['double_value'], equals(originalData['double_value']));
      expect(loadedData['bool_value'], equals(originalData['bool_value']));
      expect(loadedData['list_value'], equals(originalData['list_value']));
      expect(loadedData['nested_object']['color'], equals((originalData['nested_object'] as Map)['color']));
    });

    test('image file operations should handle binary data correctly', () async {
      // ARRANGE - Create test image data (PNG header + some data)
      const fileName = 'test_image.png';
      final pngHeader = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]); // PNG signature
      final testImageData = Uint8List.fromList([
        ...pngHeader,
        ...List.generate(1000, (i) => i % 256), // Generate test data
      ]);

      // ACT
      await fileService.saveImageFile(fileName, testImageData);
      final loadedImageData = await fileService.loadImageFile(fileName);

      // Clean up
      await fileService.deleteFile(fileName);

      // ASSERT
      expect(loadedImageData, isNotNull);
      expect(loadedImageData!.length, equals(testImageData.length));
      expect(loadedImageData.sublist(0, 8), equals(pngHeader));
    });

    test('storage usage calculation should be accurate', () async {
      // ARRANGE - Create several test files with known sizes
      final testFiles = [
        {'name': 'small_file.json', 'size': 100},
        {'name': 'medium_file.png', 'size': 5000},
        {'name': 'large_file.json', 'size': 50000},
      ];

      int totalExpectedSize = 0;

      // ACT - Create files
      for (final fileInfo in testFiles) {
        final fileName = fileInfo['name'] as String;
        final size = fileInfo['size'] as int;
        final data = Uint8List.fromList(List.generate(size, (i) => i % 256));

        await fileService.saveImageFile(fileName, data);
        totalExpectedSize += size;
      }

      final usageBeforeCleanup = await fileService.getStorageUsage();

      // Clean up files
      for (final fileInfo in testFiles) {
        await fileService.deleteFile(fileInfo['name'] as String);
      }

      final usageAfterCleanup = await fileService.getStorageUsage();

      // ASSERT
      expect(usageBeforeCleanup, greaterThanOrEqualTo(totalExpectedSize));
      expect(usageAfterCleanup, lessThan(usageBeforeCleanup));
    });

    test('directory structure creation should be robust', () async {
      // ARRANGE
      final directories = await Future.wait([
        fileService.getAppDocumentsDirectory(),
        fileService.getArtworksDirectory(),
        fileService.getColoringDirectory(),
        fileService.getCacheDirectory(),
      ]);

      // ASSERT
      for (final directory in directories) {
        expect(directory, isA<Directory>());
        expect(await directory.exists(), isTrue);
      }
    });

    test('file path sanitization should prevent security issues', () {
      // ARRANGE - Test various potentially dangerous file names
      final dangerousNames = [
        '../../../etc/passwd',
        'C:\\Windows\\System32\\config',
        '../../sensitive_file.txt',
        'file_with_\0_null_byte',
        'file:///etc/shadow',
        'very_long_filename_' + 'a' * 300,
      ];

      for (final dangerousName in dangerousNames) {
        // ACT & ASSERT
        expect(() => _sanitizeFileName(dangerousName), returnsNormally);
        final sanitized = _sanitizeFileName(dangerousName);

        // Should not contain path traversal patterns
        expect(sanitized.contains('..'), isFalse);
        expect(sanitized.contains('/'), isFalse);
        expect(sanitized.contains('\\'), isFalse);
        expect(sanitized.contains('\0'), isFalse);

        // Should be reasonable length
        expect(sanitized.length, lessThanOrEqualTo(255));
      }
    });

    test('concurrent file operations should be thread-safe', () async {
      // ARRANGE
      const numberOfConcurrentOps = 10;
      final futures = <Future>[];

      // ACT - Perform concurrent file operations
      for (int i = 0; i < numberOfConcurrentOps; i++) {
        futures.add(_performFileOperationSequence(fileService, 'concurrent_$i'));
      }

      // Wait for all operations to complete
      await Future.wait(futures);

      // ASSERT - All operations should complete without errors
      // (If any operation failed, Future.wait would have thrown)
      expect(futures.length, equals(numberOfConcurrentOps));
    });

    test('backup and restore operations should preserve data', () async {
      // ARRANGE - Create test data
      final testFiles = [
        {
          'name': 'backup_test1.json',
          'data': {'test': 'data1'},
        },
        {
          'name': 'backup_test2.json',
          'data': {'test': 'data2'},
        },
      ];

      for (final fileInfo in testFiles) {
        await fileService.saveJsonFile(fileInfo['name'] as String, fileInfo['data'] as Map<String, dynamic>);
      }

      // ACT - Create backup
      final backupPath = await fileService.createBackup();

      // Delete original files
      for (final fileInfo in testFiles) {
        await fileService.deleteFile(fileInfo['name'] as String);
      }

      // Verify files are gone
      for (final fileInfo in testFiles) {
        final exists = await fileService.fileExists(fileInfo['name'] as String);
        expect(exists, isFalse);
      }

      // Restore from backup
      await fileService.restoreFromBackup(backupPath);

      // ASSERT - Files should be restored
      for (final fileInfo in testFiles) {
        final exists = await fileService.fileExists(fileInfo['name'] as String);
        expect(exists, isTrue);

        final restoredData = await fileService.loadJsonFile(fileInfo['name'] as String);
        expect(restoredData, equals(fileInfo['data']));
      }

      // Clean up
      for (final fileInfo in testFiles) {
        await fileService.deleteFile(fileInfo['name'] as String);
      }
    });

    test('error handling should provide meaningful messages', () async {
      // ARRANGE
      const nonExistentFile = 'this_file_does_not_exist.json';

      // ACT & ASSERT - Loading non-existent file should return null, not throw
      final result = await fileService.loadJsonFile(nonExistentFile);
      expect(result, isNull);

      // Test file existence check
      final exists = await fileService.fileExists(nonExistentFile);
      expect(exists, isFalse);

      // Test deleting non-existent file
      final deleteResult = await fileService.deleteFile(nonExistentFile);
      expect(deleteResult, isFalse);
    });

    test('large file operations should handle memory efficiently', () async {
      // ARRANGE - Create a large file (1MB)
      const fileName = 'large_test_file.bin';
      const fileSize = 1024 * 1024; // 1MB
      final largeData = Uint8List.fromList(List.generate(fileSize, (i) => i % 256));

      // ACT
      final stopwatch = Stopwatch()..start();
      await fileService.saveImageFile(fileName, largeData);
      final loadedData = await fileService.loadImageFile(fileName);
      stopwatch.stop();

      // Clean up
      await fileService.deleteFile(fileName);

      // ASSERT
      expect(loadedData, isNotNull);
      expect(loadedData!.length, equals(fileSize));

      // Operation should complete within reasonable time (10 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });

    test('file metadata preservation should work correctly', () async {
      // ARRANGE
      const fileName = 'metadata_test.json';
      final testData = {'created_at': DateTime.now().toIso8601String(), 'version': '1.0.0', 'user_id': 'test_user'};

      // ACT
      final savedFile = await fileService.saveJsonFile(fileName, testData);
      final fileStat = await savedFile.stat();

      await Future.delayed(const Duration(milliseconds: 10)); // Ensure time difference

      // Modify file
      final modifiedData = Map<String, dynamic>.from(testData);
      modifiedData['modified'] = 'true';
      await fileService.saveJsonFile(fileName, modifiedData);
      final modifiedStat = await savedFile.stat();

      // Clean up
      await fileService.deleteFile(fileName);

      // ASSERT
      expect(fileStat.size, greaterThan(0));
      expect(modifiedStat.modified.isAfter(fileStat.modified), isTrue);
    });
  });
}

// Helper functions for file operations testing

String _sanitizeFileName(String fileName) {
  // Remove path traversal patterns
  String sanitized = fileName.replaceAll(RegExp(r'[.][.]'), '');

  // Remove directory separators
  sanitized = sanitized.replaceAll(RegExp(r'[/\\:]'), '_');

  // Remove null bytes and control characters
  sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');

  // Limit length
  if (sanitized.length > 255) {
    sanitized = sanitized.substring(0, 255);
  }

  // Ensure not empty
  if (sanitized.isEmpty) {
    sanitized = 'default_filename';
  }

  return sanitized;
}

Future<void> _performFileOperationSequence(FileService fileService, String baseFileName) async {
  try {
    // Create file
    final testData = {'id': baseFileName, 'timestamp': DateTime.now().millisecondsSinceEpoch};
    await fileService.saveJsonFile('$baseFileName.json', testData);

    // Read file
    await fileService.loadJsonFile('$baseFileName.json');

    // Check existence
    await fileService.fileExists('$baseFileName.json');

    // Delete file
    await fileService.deleteFile('$baseFileName.json');
  } catch (e) {
    // Re-throw to fail the test if any operation fails
    throw Exception('File operation sequence failed for $baseFileName: $e');
  }
}
