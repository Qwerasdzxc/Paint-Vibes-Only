import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/coloring/services/i_coloring_service.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';
import 'package:painter/core/services/coloring_service.dart';

/// Contract test for IColoringService interface
/// This test now uses the real implementation to verify it meets the contract
void main() {
  group('IColoringService Contract Tests', () {
    late IColoringService service;
    late ColoringProgress testProgress;

    setUp(() async {
      // Now using the real implementation to test if it passes the contract
      service = ColoringService();

      // Create test progress for operations that need existing progress
      testProgress = await service.startColoringPage('animals_cat_001');
    });

    group('Coloring Pages', () {
      test('getAvailableColoringPages should return list of pages', () async {
        final pages = await service.getAvailableColoringPages();
        expect(pages, isA<List<ColoringPage>>());
      });

      test('getColoringPagesByCategory should return filtered pages', () async {
        const category = 'animals';
        final pages = await service.getColoringPagesByCategory(category);
        expect(pages, isA<List<ColoringPage>>());
      });

      test('getColoringPage should return page by ID', () async {
        const pageId = 'test_page_id';
        final page = await service.getColoringPage(pageId);
        expect(page, anyOf(isA<ColoringPage>(), isNull));
      });

      test('getColoringCategories should return list of categories', () async {
        final categories = await service.getColoringCategories();
        expect(categories, isA<List<String>>());
      });
    });

    group('Coloring Progress', () {
      test('getUserColoringProgress should return user progress list', () async {
        final progressList = await service.getUserColoringProgress();
        expect(progressList, isA<List<ColoringProgress>>());
      });

      test('getColoringProgress should return progress by page ID', () async {
        const pageId = 'test_page_id';
        final progress = await service.getColoringProgress(pageId);
        expect(progress, anyOf(isA<ColoringProgress>(), isNull));
      });

      test('startColoringPage should create new progress', () async {
        const pageId = 'animals_cat_001'; // Use actual page from mock data
        final progress = await service.startColoringPage(pageId);
        expect(progress, isA<ColoringProgress>());
        expect(progress.coloringPageId, equals(pageId));
        expect(progress.completionPercent, equals(0.0));
        expect(progress.isCompleted, isFalse);
      });

      test('saveColoringProgress should persist progress', () async {
        // First create a progress to save
        final createdProgress = await service.startColoringPage('nature_flower_001');
        final updatedProgress = createdProgress.copyWith(completionPercent: 25.0);

        await service.saveColoringProgress(updatedProgress);
        // No exception should be thrown
      });

      test('completeColoringPage should mark progress as complete', () async {
        // Use the test progress created in setUp
        await service.completeColoringPage(testProgress.id);

        // Verify completion
        final updatedProgress = await service.getColoringProgress(testProgress.coloringPageId);
        expect(updatedProgress?.isCompleted, isTrue);
        expect(updatedProgress?.completionPercent, equals(100.0));
      });
    });

    group('Coloring Operations', () {
      test('applyColorToRegion should color at specified position', () async {
        const position = Offset(100, 100);
        const color = Colors.blue;
        await service.applyColorToRegion(testProgress.id, position, color);
        // No exception should be thrown
      });

      test('calculateCompletionPercentage should return percentage', () async {
        final percentage = await service.calculateCompletionPercentage(testProgress.id);
        expect(percentage, isA<double>());
        expect(percentage, greaterThanOrEqualTo(0.0));
        expect(percentage, lessThanOrEqualTo(100.0));
      });

      test('getSuggestedColorsForPage should return color suggestions', () async {
        const pageId = 'animals_cat_001'; // Use actual page from mock data
        final colors = await service.getSuggestedColorsForPage(pageId);
        expect(colors, isA<List<Color>>());
      });
    });
  });
}
