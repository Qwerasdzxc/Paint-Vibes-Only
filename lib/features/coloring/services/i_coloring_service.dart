import 'package:flutter/material.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';

/// Interface for coloring page management and progress tracking
abstract class IColoringService {
  // Coloring Pages
  Future<List<ColoringPage>> getAvailableColoringPages();
  Future<List<ColoringPage>> getColoringPagesByCategory(String category);
  Future<ColoringPage?> getColoringPage(String pageId);
  Future<List<String>> getColoringCategories();

  // Coloring Progress
  Future<List<ColoringProgress>> getUserColoringProgress();
  Future<ColoringProgress?> getColoringProgress(String pageId);
  Future<ColoringProgress> startColoringPage(String pageId);
  Future<void> saveColoringProgress(ColoringProgress progress);
  Future<void> completeColoringPage(String progressId);

  // Coloring Operations
  Future<void> applyColorToRegion(String progressId, Offset position, Color color);
  Future<double> calculateCompletionPercentage(String progressId);
  Future<List<Color>> getSuggestedColorsForPage(String pageId);
}

/// Custom exceptions for coloring operations
class ColoringPageNotFoundException implements Exception {
  final String pageId;
  ColoringPageNotFoundException(this.pageId);
  String toString() => 'Coloring page not found: $pageId';
}

class ColoringProgressNotFoundException implements Exception {
  final String progressId;
  ColoringProgressNotFoundException(this.progressId);
  String toString() => 'Coloring progress not found: $progressId';
}

class InvalidColoringOperationException implements Exception {
  final String operation;
  final String reason;
  InvalidColoringOperationException(this.operation, this.reason);
  String toString() => 'Invalid coloring operation $operation: $reason';
}

class ColoringStorageException implements Exception {
  final String operation;
  final String details;
  ColoringStorageException(this.operation, this.details);
  String toString() => 'Coloring storage error during $operation: $details';
}
