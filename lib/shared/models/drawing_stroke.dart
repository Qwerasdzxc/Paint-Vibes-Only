import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Represents a single drawing stroke on the canvas
class DrawingStroke {
  final String id;
  final DrawingTool tool;
  final Color color;
  final double brushSize;
  final List<Offset> points;
  final double opacity;
  final BlendMode blendMode;
  final DateTime timestamp;

  DrawingStroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.brushSize,
    required this.points,
    this.opacity = 1.0,
    BlendMode? blendMode,
    DateTime? timestamp,
  }) : blendMode = blendMode ?? tool.blendMode,
       timestamp = timestamp ?? DateTime.now();

  /// Create a copy of this stroke with modified properties
  DrawingStroke copyWith({
    String? id,
    DrawingTool? tool,
    Color? color,
    double? brushSize,
    List<Offset>? points,
    double? opacity,
    BlendMode? blendMode,
    DateTime? timestamp,
  }) {
    return DrawingStroke(
      id: id ?? this.id,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      brushSize: brushSize ?? this.brushSize,
      points: points ?? List.from(this.points),
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert stroke to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool': tool.type.name,
      'color': {'r': color.red, 'g': color.green, 'b': color.blue, 'a': color.alpha},
      'brushSize': brushSize,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'opacity': opacity,
      'blendMode': blendMode.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create stroke from JSON
  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final colorData = json['color'] as Map<String, dynamic>;
    final pointsData = json['points'] as List<dynamic>;

    return DrawingStroke(
      id: json['id'] as String,
      tool: _getToolByType(json['tool'] as String),
      color: Color.fromARGB(colorData['a'] as int, colorData['r'] as int, colorData['g'] as int, colorData['b'] as int),
      brushSize: (json['brushSize'] as num).toDouble(),
      points: pointsData.map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble())).toList(),
      opacity: (json['opacity'] as num).toDouble(),
      blendMode: _getBlendModeByName(json['blendMode'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
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

  static BlendMode _getBlendModeByName(String name) {
    switch (name) {
      case 'clear':
        return BlendMode.clear;
      case 'srcOver':
        return BlendMode.srcOver;
      default:
        return BlendMode.srcOver;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawingStroke && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DrawingStroke{id: $id, tool: ${tool.name}, points: ${points.length}}';
  }
}
