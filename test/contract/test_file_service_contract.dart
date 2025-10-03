import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/core/storage/i_file_service.dart';
import 'test_file_service_impl.dart';

/// Contract test for IFileService interface
/// This test uses a test implementation that doesn't require platform channels
void main() {
  // Initialize Flutter testing bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IFileService Contract Tests', () {
    late IFileService service;

    setUp(() {
      // Using test implementation that works without platform dependencies
      service = TestFileServiceImpl();
    });

    tearDownAll(() async {
      // Clean up test directory
      await TestFileServiceImpl.cleanupTestDir();
    });

    group('Directory Management', () {
      test('getAppDocumentsDirectory should return app documents directory', () async {
        final directory = await service.getAppDocumentsDirectory();
        expect(directory, isA<Directory>());
      });

      test('getArtworksDirectory should return artworks directory', () async {
        final directory = await service.getArtworksDirectory();
        expect(directory, isA<Directory>());
      });

      test('getColoringDirectory should return coloring directory', () async {
        final directory = await service.getColoringDirectory();
        expect(directory, isA<Directory>());
      });

      test('getCacheDirectory should return cache directory', () async {
        final directory = await service.getCacheDirectory();
        expect(directory, isA<Directory>());
      });
    });

    group('File Operations', () {
      test('saveImageFile should save image data to file', () async {
        const fileName = 'test_image.png';
        final imageData = Uint8List.fromList([137, 80, 78, 71]); // PNG header bytes

        final file = await service.saveImageFile(fileName, imageData);
        expect(file, isA<File>());
      });

      test('saveJsonFile should save JSON data to file', () async {
        const fileName = 'test_data.json';
        const jsonData = {'key': 'value', 'number': 42};

        final file = await service.saveJsonFile(fileName, jsonData);
        expect(file, isA<File>());
      });

      test('loadJsonFile should load JSON data from file', () async {
        const fileName = 'existing_data.json';
        final jsonData = await service.loadJsonFile(fileName);
        expect(jsonData, anyOf(isA<Map<String, dynamic>>(), isNull));
      });

      test('loadImageFile should load image data from file', () async {
        const fileName = 'existing_image.png';
        final imageData = await service.loadImageFile(fileName);
        expect(imageData, anyOf(isA<Uint8List>(), isNull));
      });

      test('deleteFile should remove file', () async {
        const fileName = 'file_to_delete.txt';
        final result = await service.deleteFile(fileName);
        expect(result, isA<bool>());
      });

      test('fileExists should check file existence', () async {
        const fileName = 'check_file.txt';
        final exists = await service.fileExists(fileName);
        expect(exists, isA<bool>());
      });
    });

    group('Storage Management', () {
      test('getStorageUsage should return used storage in bytes', () async {
        final usage = await service.getStorageUsage();
        expect(usage, isA<int>());
        expect(usage, greaterThanOrEqualTo(0));
      });

      test('getAvailableStorage should return available storage in bytes', () async {
        final available = await service.getAvailableStorage();
        expect(available, isA<int>());
        expect(available, greaterThanOrEqualTo(0));
      });

      test('cleanupTempFiles should clean temporary files', () async {
        await service.cleanupTempFiles();
        // No exception should be thrown
      });

      test('cleanupOrphanedFiles should clean orphaned files', () async {
        await service.cleanupOrphanedFiles();
        // No exception should be thrown
      });
    });

    group('Backup and Restore', () {
      test('createBackup should create backup and return path', () async {
        final backupPath = await service.createBackup();
        expect(backupPath, isA<String>());
        expect(backupPath, isNotEmpty);
      });

      test('restoreFromBackup should restore from backup path', () async {
        // First create a backup to get a valid path
        final backupPath = await service.createBackup();

        // Now restore from the created backup
        await service.restoreFromBackup(backupPath);
        // No exception should be thrown
      });
    });
  });
}
