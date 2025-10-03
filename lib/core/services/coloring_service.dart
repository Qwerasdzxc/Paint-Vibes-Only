import 'dart:async';
import 'package:flutter/material.dart';
import 'package:painter/features/coloring/services/i_coloring_service.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';

/// Implementation of IColoringService for managing coloring operations
class ColoringService implements IColoringService {
  // In-memory storage for coloring pages and progress
  final Map<String, ColoringPage> _coloringPages = {};
  final Map<String, ColoringProgress> _coloringProgress = {};
  final Map<String, Set<String>> _categoryIndex = {}; // category -> set of page IDs

  // Mock data for colored regions (in reality this would be more complex)
  final Map<String, Map<String, Color>> _coloredRegions = {}; // progressId -> regionId -> color

  ColoringService() {
    _initializeMockData();
  }

  @override
  Future<List<ColoringPage>> getAvailableColoringPages() async {
    return _coloringPages.values.where((page) => page.isUnlocked).toList();
  }

  @override
  Future<List<ColoringPage>> getColoringPagesByCategory(String category) async {
    final pageIds = _categoryIndex[category] ?? <String>{};
    return pageIds
        .map((id) => _coloringPages[id])
        .where((page) => page != null && page.isUnlocked)
        .cast<ColoringPage>()
        .toList();
  }

  @override
  Future<ColoringPage?> getColoringPage(String pageId) async {
    return _coloringPages[pageId];
  }

  @override
  Future<List<String>> getColoringCategories() async {
    return _categoryIndex.keys.toList()..sort();
  }

  @override
  Future<List<ColoringProgress>> getUserColoringProgress() async {
    // For demo purposes, return all progress (in real app would filter by current user)
    return _coloringProgress.values.toList();
  }

  @override
  Future<ColoringProgress?> getColoringProgress(String pageId) async {
    // Find progress for this page (in real app would filter by current user)
    return _coloringProgress.values.where((progress) => progress.coloringPageId == pageId).firstOrNull;
  }

  @override
  Future<ColoringProgress> startColoringPage(String pageId) async {
    final coloringPage = _coloringPages[pageId];
    if (coloringPage == null) {
      throw ColoringPageNotFoundException(pageId);
    }

    final now = DateTime.now();
    final progressId = 'progress_${now.millisecondsSinceEpoch}';

    final progress = ColoringProgress(
      id: progressId,
      coloringPageId: pageId,
      userId: 'current_user', // In real app, get from auth service
      progressImagePath: 'progress_images/$progressId.png',
      canvasDataPath: 'canvas_data/$progressId.json',
      completionPercent: 0.0,
      startedAt: now,
      lastWorkedOn: now,
      isCompleted: false,
      totalTimeSpent: Duration.zero,
    );

    _coloringProgress[progressId] = progress;
    _coloredRegions[progressId] = {};

    return progress;
  }

  @override
  Future<void> saveColoringProgress(ColoringProgress progress) async {
    if (!_coloringProgress.containsKey(progress.id)) {
      throw ColoringProgressNotFoundException(progress.id);
    }

    final updatedProgress = progress.copyWith(lastWorkedOn: DateTime.now());
    _coloringProgress[progress.id] = updatedProgress;
  }

  @override
  Future<void> completeColoringPage(String progressId) async {
    final progress = _coloringProgress[progressId];
    if (progress == null) {
      throw ColoringProgressNotFoundException(progressId);
    }

    final completedProgress = progress.copyWith(
      isCompleted: true,
      completionPercent: 100.0,
      lastWorkedOn: DateTime.now(),
    );

    _coloringProgress[progressId] = completedProgress;

    // Update completion count for the coloring page
    final coloringPage = _coloringPages[progress.coloringPageId];
    if (coloringPage != null) {
      final updatedPage = coloringPage.copyWith(completionCount: coloringPage.completionCount + 1);
      _coloringPages[progress.coloringPageId] = updatedPage;
    }
  }

  @override
  Future<void> applyColorToRegion(String progressId, Offset position, Color color) async {
    final progress = _coloringProgress[progressId];
    if (progress == null) {
      throw ColoringProgressNotFoundException(progressId);
    }

    if (progress.isCompleted) {
      throw InvalidColoringOperationException('applyColorToRegion', 'Cannot modify completed coloring page');
    }

    // Simulate region detection based on position
    final regionId = _detectRegionFromPosition(position);
    _coloredRegions[progressId]![regionId] = color;

    // Update completion percentage and last worked time
    final newCompletionPercent = await calculateCompletionPercentage(progressId);
    final updatedProgress = progress.copyWith(completionPercent: newCompletionPercent, lastWorkedOn: DateTime.now());

    _coloringProgress[progressId] = updatedProgress;
  }

  @override
  Future<double> calculateCompletionPercentage(String progressId) async {
    final progress = _coloringProgress[progressId];
    if (progress == null) {
      throw ColoringProgressNotFoundException(progressId);
    }

    final coloringPage = _coloringPages[progress.coloringPageId];
    if (coloringPage == null) {
      return 0.0;
    }

    // Simulate completion calculation based on colored regions
    final coloredRegionsCount = _coloredRegions[progressId]?.length ?? 0;
    final totalRegions = _getTotalRegionsForPage(coloringPage);

    if (totalRegions == 0) return 0.0;

    return (coloredRegionsCount / totalRegions * 100).clamp(0.0, 100.0);
  }

  @override
  Future<List<Color>> getSuggestedColorsForPage(String pageId) async {
    final coloringPage = _coloringPages[pageId];
    if (coloringPage == null) {
      throw ColoringPageNotFoundException(pageId);
    }

    // Convert hex color strings to Color objects
    return coloringPage.suggestedColors.map((colorHex) => _parseColorFromHex(colorHex)).toList();
  }

  // Private helper methods

  void _initializeMockData() {
    // Create some sample coloring pages
    final pages = [
      ColoringPage(
        id: 'animals_cat_001',
        title: 'Cute Kitten',
        description: 'A playful kitten with simple outlines',
        category: 'animals',
        outlinePath: 'outlines/cat_001.svg',
        thumbnailPath: 'thumbnails/cat_001.png',
        difficulty: Difficulty.easy,
        suggestedColors: ['#FF69B4', '#87CEEB', '#98FB98', '#DDA0DD'],
        isUnlocked: true,
        completionCount: 12,
      ),
      ColoringPage(
        id: 'nature_flower_001',
        title: 'Spring Flowers',
        description: 'Beautiful flowers in a garden setting',
        category: 'nature',
        outlinePath: 'outlines/flower_001.svg',
        thumbnailPath: 'thumbnails/flower_001.png',
        difficulty: Difficulty.medium,
        suggestedColors: ['#FF1493', '#32CD32', '#FFD700', '#8A2BE2'],
        isUnlocked: true,
        completionCount: 8,
      ),
      ColoringPage(
        id: 'patterns_mandala_001',
        title: 'Intricate Mandala',
        description: 'Complex geometric patterns for detailed coloring',
        category: 'patterns',
        outlinePath: 'outlines/mandala_001.svg',
        thumbnailPath: 'thumbnails/mandala_001.png',
        difficulty: Difficulty.hard,
        suggestedColors: ['#FF4500', '#4169E1', '#FFD700', '#DC143C', '#9370DB'],
        isUnlocked: true,
        completionCount: 3,
      ),
    ];

    // Store pages and build category index
    for (final page in pages) {
      _coloringPages[page.id] = page;
      _categoryIndex.putIfAbsent(page.category, () => <String>{}).add(page.id);
    }
  }

  String _detectRegionFromPosition(Offset position) {
    // Simple region detection simulation based on position
    // In a real app, this would use complex path detection algorithms
    final x = (position.dx / 50).floor();
    final y = (position.dy / 50).floor();
    return 'region_${x}_${y}';
  }

  int _getTotalRegionsForPage(ColoringPage page) {
    // Simulate total regions based on difficulty
    switch (page.difficulty) {
      case Difficulty.easy:
        return 15;
      case Difficulty.medium:
        return 30;
      case Difficulty.hard:
        return 60;
    }
  }

  Color _parseColorFromHex(String hexString) {
    // Remove # if present
    final hex = hexString.replaceAll('#', '');

    try {
      // Parse hex color
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {
      // Return a default color if parsing fails
      return Colors.grey;
    }

    return Colors.grey;
  }
}

/// Extension to add firstOrNull functionality
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    try {
      return first;
    } catch (_) {
      return null;
    }
  }
}
