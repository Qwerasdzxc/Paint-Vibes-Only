import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/core/services/i_settings_service.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'test_settings_service_impl.dart';

/// Contract test for ISettingsService interface
/// This test uses a test implementation that works without SharedPreferences
void main() {
  group('ISettingsService Contract Tests', () {
    late ISettingsService service;

    setUp(() {
      // Using test implementation for contract validation
      service = TestSettingsServiceImpl();
    });

    group('Drawing Settings', () {
      test('getDefaultBrushSize should return default brush size', () async {
        final size = await service.getDefaultBrushSize();
        expect(size, isA<double>());
        expect(size, greaterThan(0));
      });

      test('setDefaultBrushSize should set brush size', () async {
        const newSize = 5.0;
        await service.setDefaultBrushSize(newSize);
        // No exception should be thrown
      });

      test('getDefaultColor should return default color', () async {
        final color = await service.getDefaultColor();
        expect(color, isA<Color>());
      });

      test('setDefaultColor should set default color', () async {
        const newColor = Colors.red;
        await service.setDefaultColor(newColor);
        // No exception should be thrown
      });

      test('getPressureSensitivityEnabled should return pressure setting', () async {
        final enabled = await service.getPressureSensitivityEnabled();
        expect(enabled, isA<bool>());
      });

      test('setPressureSensitivityEnabled should set pressure setting', () async {
        await service.setPressureSensitivityEnabled(true);
        // No exception should be thrown
      });
    });

    group('Gallery Settings', () {
      test('getGalleryViewMode should return view mode', () async {
        final viewMode = await service.getGalleryViewMode();
        expect(viewMode, isA<GalleryViewMode>());
      });

      test('setGalleryViewMode should set view mode', () async {
        await service.setGalleryViewMode(GalleryViewMode.grid);
        // No exception should be thrown
      });

      test('getGallerySortOrder should return sort order', () async {
        final sortOrder = await service.getGallerySortOrder();
        expect(sortOrder, isA<GallerySortOrder>());
      });

      test('setGallerySortOrder should set sort order', () async {
        await service.setGallerySortOrder(GallerySortOrder.dateCreated);
        // No exception should be thrown
      });
    });

    group('Performance Settings', () {
      test('getMaxUndoSteps should return max undo steps', () async {
        final maxSteps = await service.getMaxUndoSteps();
        expect(maxSteps, isA<int>());
        expect(maxSteps, greaterThan(0));
      });

      test('setMaxUndoSteps should set max undo steps', () async {
        await service.setMaxUndoSteps(50);
        // No exception should be thrown
      });

      test('getAutoSaveEnabled should return auto save setting', () async {
        final enabled = await service.getAutoSaveEnabled();
        expect(enabled, isA<bool>());
      });

      test('setAutoSaveEnabled should set auto save setting', () async {
        await service.setAutoSaveEnabled(true);
        // No exception should be thrown
      });

      test('getAutoSaveInterval should return interval in seconds', () async {
        final interval = await service.getAutoSaveInterval();
        expect(interval, isA<int>());
        expect(interval, greaterThan(0));
      });

      test('setAutoSaveInterval should set interval', () async {
        await service.setAutoSaveInterval(30);
        // No exception should be thrown
      });
    });

    group('App Settings', () {
      test('getFirstTimeUser should return first time user flag', () async {
        final isFirstTime = await service.getFirstTimeUser();
        expect(isFirstTime, isA<bool>());
      });

      test('setFirstTimeUser should set first time user flag', () async {
        await service.setFirstTimeUser(false);
        // No exception should be thrown
      });

      test('getAppVersion should return app version', () async {
        final version = await service.getAppVersion();
        expect(version, isA<String>());
        expect(version, isNotEmpty);
      });

      test('getLastBackupDate should return last backup date', () async {
        final date = await service.getLastBackupDate();
        expect(date, isA<DateTime>());
      });

      test('setLastBackupDate should set backup date', () async {
        final date = DateTime.now();
        await service.setLastBackupDate(date);
        // No exception should be thrown
      });
    });
  });
}
