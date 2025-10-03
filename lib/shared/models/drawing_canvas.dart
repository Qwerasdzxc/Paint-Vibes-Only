import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Represents the active drawing surface and its state
class DrawingCanvas {
  final String id;
  final Size dimensions;
  final Color backgroundColor;
  final List<DrawingStroke> strokes;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentBrushSize;
  final bool isDirty;
  final DateTime lastModified;

  DrawingCanvas({
    required this.id,
    required this.dimensions,
    required this.backgroundColor,
    required this.strokes,
    required this.currentTool,
    required this.currentColor,
    required this.currentBrushSize,
    required this.isDirty,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  /// Create a new empty canvas
  factory DrawingCanvas.empty({required String id, required Size dimensions, Color? backgroundColor}) {
    return DrawingCanvas(
      id: id,
      dimensions: dimensions,
      backgroundColor: backgroundColor ?? Colors.white,
      strokes: [],
      currentTool: DrawingTool.pencil,
      currentColor: Colors.black,
      currentBrushSize: DrawingTool.pencil.defaultSize,
      isDirty: false,
    );
  }

  /// Create a copy of this canvas with modified properties
  DrawingCanvas copyWith({
    String? id,
    Size? dimensions,
    Color? backgroundColor,
    List<DrawingStroke>? strokes,
    DrawingTool? currentTool,
    Color? currentColor,
    double? currentBrushSize,
    bool? isDirty,
    DateTime? lastModified,
  }) {
    return DrawingCanvas(
      id: id ?? this.id,
      dimensions: dimensions ?? this.dimensions,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      strokes: strokes ?? List.from(this.strokes),
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentBrushSize: currentBrushSize ?? this.currentBrushSize,
      isDirty: isDirty ?? this.isDirty,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Add a stroke to the canvas
  DrawingCanvas addStroke(DrawingStroke stroke) {
    return copyWith(strokes: [...strokes, stroke], isDirty: true, lastModified: DateTime.now());
  }

  /// Remove a stroke from the canvas
  DrawingCanvas removeStroke(String strokeId) {
    final updatedStrokes = strokes.where((s) => s.id != strokeId).toList();
    return copyWith(strokes: updatedStrokes, isDirty: true, lastModified: DateTime.now());
  }

  /// Clear all strokes from the canvas
  DrawingCanvas clearStrokes() {
    return copyWith(strokes: [], isDirty: true, lastModified: DateTime.now());
  }

  /// Mark canvas as saved (not dirty)
  DrawingCanvas markAsSaved() {
    return copyWith(isDirty: false);
  }

  /// Convert canvas to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': '1.0',
      'dimensions': {'width': dimensions.width, 'height': dimensions.height},
      'backgroundColor': {
        'r': backgroundColor.red,
        'g': backgroundColor.green,
        'b': backgroundColor.blue,
        'a': backgroundColor.alpha,
      },
      'strokes': strokes.map((s) => s.toJson()).toList(),
      'currentTool': currentTool.type.name,
      'currentColor': {'r': currentColor.red, 'g': currentColor.green, 'b': currentColor.blue, 'a': currentColor.alpha},
      'currentBrushSize': currentBrushSize,
      'createdAt': lastModified.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Create canvas from JSON
  factory DrawingCanvas.fromJson(Map<String, dynamic> json) {
    final dimensionsData = json['dimensions'] as Map<String, dynamic>;
    final backgroundColorData = json['backgroundColor'] as Map<String, dynamic>;
    final currentColorData = json['currentColor'] as Map<String, dynamic>;
    final strokesData = json['strokes'] as List<dynamic>;

    return DrawingCanvas(
      id: json['id'] as String,
      dimensions: Size((dimensionsData['width'] as num).toDouble(), (dimensionsData['height'] as num).toDouble()),
      backgroundColor: Color.fromARGB(
        backgroundColorData['a'] as int,
        backgroundColorData['r'] as int,
        backgroundColorData['g'] as int,
        backgroundColorData['b'] as int,
      ),
      strokes: strokesData.map((s) => DrawingStroke.fromJson(s as Map<String, dynamic>)).toList(),
      currentTool: _getToolByType(json['currentTool'] as String),
      currentColor: Color.fromARGB(
        currentColorData['a'] as int,
        currentColorData['r'] as int,
        currentColorData['g'] as int,
        currentColorData['b'] as int,
      ),
      currentBrushSize: (json['currentBrushSize'] as num).toDouble(),
      isDirty: false, // Loaded canvas is considered clean
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  static DrawingTool _getToolByType(String typeName) {
    switch (typeName) {
      case 'pencil':
        return DrawingTool.pencil;
      case 'brush':
        return DrawingTool.brush;
      case 'eraser':
        return DrawingTool.eraser;
      default:
        return DrawingTool.pencil;
    }
  }

  /// Validation rules
  bool get isValid {
    return dimensions.width > 0 && dimensions.height > 0 && strokes.length <= 10000;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawingCanvas && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DrawingCanvas{id: $id, strokes: ${strokes.length}, isDirty: $isDirty}';
  }
}
