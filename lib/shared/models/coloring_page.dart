import 'package:flutter/material.dart';

/// Enumeration of difficulty levels for coloring pages
enum Difficulty {
  easy, // Simple shapes, few details
  medium, // Moderate complexity
  hard, // Complex details, many regions
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  IconData get icon {
    switch (this) {
      case Difficulty.easy:
        return Icons.star_outline;
      case Difficulty.medium:
        return Icons.star_half;
      case Difficulty.hard:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}

/// Represents pre-made designs available for coloring
class ColoringPage {
  final String id;
  final String title;
  final String description;
  final String category;
  final String outlinePath;
  final String thumbnailPath;
  final Difficulty difficulty;
  final List<String> suggestedColors;
  final bool isUnlocked;
  final int completionCount;

  ColoringPage({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.outlinePath,
    required this.thumbnailPath,
    required this.difficulty,
    required this.suggestedColors,
    required this.isUnlocked,
    required this.completionCount,
  });

  /// Create a copy of this coloring page with modified properties
  ColoringPage copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? outlinePath,
    String? thumbnailPath,
    Difficulty? difficulty,
    List<String>? suggestedColors,
    bool? isUnlocked,
    int? completionCount,
  }) {
    return ColoringPage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      outlinePath: outlinePath ?? this.outlinePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      difficulty: difficulty ?? this.difficulty,
      suggestedColors: suggestedColors ?? List.from(this.suggestedColors),
      isUnlocked: isUnlocked ?? this.isUnlocked,
      completionCount: completionCount ?? this.completionCount,
    );
  }

  /// Convert coloring page to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'outlinePath': outlinePath,
      'thumbnailPath': thumbnailPath,
      'difficulty': difficulty.name,
      'suggestedColors': suggestedColors,
      'isUnlocked': isUnlocked,
      'completionCount': completionCount,
    };
  }

  /// Create coloring page from JSON
  factory ColoringPage.fromJson(Map<String, dynamic> json) {
    return ColoringPage(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      outlinePath: json['outlinePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      difficulty: _getDifficultyByName(json['difficulty'] as String),
      suggestedColors: (json['suggestedColors'] as List<dynamic>).cast<String>(),
      isUnlocked: json['isUnlocked'] as bool,
      completionCount: json['completionCount'] as int,
    );
  }

  static Difficulty _getDifficultyByName(String name) {
    switch (name) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }

  /// Validation rules
  bool get isValid {
    return title.isNotEmpty &&
        title.length <= 100 &&
        category.isNotEmpty &&
        outlinePath.isNotEmpty &&
        thumbnailPath.isNotEmpty &&
        completionCount >= 0;
  }

  /// Sample coloring pages for demo/testing
  static List<ColoringPage> get samplePages => [
    ColoringPage(
      id: 'sample_1',
      title: 'Peaceful Garden',
      description: 'A serene garden scene with flowers and butterflies',
      category: 'Nature',
      outlinePath: 'assets/coloring/garden.svg',
      thumbnailPath: 'assets/coloring/thumbnails/garden.png',
      difficulty: Difficulty.easy,
      suggestedColors: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4'],
      isUnlocked: true,
      completionCount: 0,
    ),
    ColoringPage(
      id: 'sample_2',
      title: 'Magical Forest',
      description: 'An enchanted forest with mythical creatures',
      category: 'Fantasy',
      outlinePath: 'assets/coloring/forest.svg',
      thumbnailPath: 'assets/coloring/thumbnails/forest.png',
      difficulty: Difficulty.medium,
      suggestedColors: ['#8E44AD', '#27AE60', '#F39C12', '#E74C3C'],
      isUnlocked: true,
      completionCount: 0,
    ),
    ColoringPage(
      id: 'sample_3',
      title: 'Ocean Adventure',
      description: 'Underwater world with marine life',
      category: 'Animals',
      outlinePath: 'assets/coloring/ocean.svg',
      thumbnailPath: 'assets/coloring/thumbnails/ocean.png',
      difficulty: Difficulty.hard,
      suggestedColors: ['#3498DB', '#1ABC9C', '#F1C40F', '#E67E22'],
      isUnlocked: true,
      completionCount: 0,
    ),
  ];

  /// All available categories
  static List<String> get allCategories => [
    'Animals',
    'Nature',
    'Fantasy',
    'Abstract',
    'Mandalas',
    'Patterns',
    'Holidays',
    'Food',
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColoringPage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ColoringPage{id: $id, title: $title, category: $category, difficulty: $difficulty}';
  }
}
