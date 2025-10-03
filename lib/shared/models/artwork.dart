import 'package:flutter/material.dart';

/// Represents completed or in-progress user creations with metadata
class Artwork {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final String fullImagePath;
  final String canvasDataPath;
  final DateTime createdAt;
  final DateTime lastModified;
  final Size originalSize;
  final List<String> tags;
  final bool isCompleted;
  final int strokeCount;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.fullImagePath,
    required this.canvasDataPath,
    required this.createdAt,
    required this.lastModified,
    required this.originalSize,
    required this.tags,
    required this.isCompleted,
    required this.strokeCount,
  });

  /// Create a copy of this artwork with modified properties
  Artwork copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailPath,
    String? fullImagePath,
    String? canvasDataPath,
    DateTime? createdAt,
    DateTime? lastModified,
    Size? originalSize,
    List<String>? tags,
    bool? isCompleted,
    int? strokeCount,
  }) {
    return Artwork(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fullImagePath: fullImagePath ?? this.fullImagePath,
      canvasDataPath: canvasDataPath ?? this.canvasDataPath,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      originalSize: originalSize ?? this.originalSize,
      tags: tags ?? List.from(this.tags),
      isCompleted: isCompleted ?? this.isCompleted,
      strokeCount: strokeCount ?? this.strokeCount,
    );
  }

  /// Convert artwork to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailPath': thumbnailPath,
      'fullImagePath': fullImagePath,
      'canvasDataPath': canvasDataPath,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'originalSize': {'width': originalSize.width, 'height': originalSize.height},
      'tags': tags,
      'isCompleted': isCompleted,
      'strokeCount': strokeCount,
    };
  }

  /// Create artwork from JSON
  factory Artwork.fromJson(Map<String, dynamic> json) {
    final originalSizeData = json['originalSize'] as Map<String, dynamic>;

    return Artwork(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      fullImagePath: json['fullImagePath'] as String,
      canvasDataPath: json['canvasDataPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      originalSize: Size((originalSizeData['width'] as num).toDouble(), (originalSizeData['height'] as num).toDouble()),
      tags: List<String>.from(json['tags'] as List),
      isCompleted: json['isCompleted'] as bool,
      strokeCount: json['strokeCount'] as int,
    );
  }

  /// Validation rules
  bool get isValid {
    return title.isNotEmpty &&
        title.length <= 100 &&
        originalSize.width > 0 &&
        originalSize.height > 0 &&
        strokeCount >= 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artwork && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Artwork{id: $id, title: $title, strokeCount: $strokeCount}';
  }
}
