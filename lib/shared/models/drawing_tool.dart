import 'package:flutter/material.dart';

/// Enumeration of available drawing tool types
enum ToolType { pencil, brush, eraser, bucketFill, eyedropper, line, rectangle, circle, wave }

/// Represents a drawing tool with its properties and configurations
class DrawingTool {
  final ToolType type;
  final String name;
  final String iconAsset;
  final double minSize;
  final double maxSize;
  final double defaultSize;
  final bool supportsOpacity;
  final bool supportsPressure;
  final BlendMode blendMode;

  const DrawingTool({
    required this.type,
    required this.name,
    required this.iconAsset,
    required this.minSize,
    required this.maxSize,
    required this.defaultSize,
    required this.supportsOpacity,
    required this.supportsPressure,
    required this.blendMode,
  });

  /// Predefined tool configurations
  static const DrawingTool pencil = DrawingTool(
    type: ToolType.pencil,
    name: 'Pencil',
    iconAsset: 'assets/icons/pencil.png',
    minSize: 0.5,
    maxSize: 8.0,
    defaultSize: 1.5,
    supportsOpacity: false,
    supportsPressure: true, // Pencils support pressure for line variation
    blendMode: BlendMode.multiply, // More natural pencil blending
  );

  static const DrawingTool brush = DrawingTool(
    type: ToolType.brush,
    name: 'Brush',
    iconAsset: 'assets/icons/brush.png',
    minSize: 2.0,
    maxSize: 100.0,
    defaultSize: 12.0,
    supportsOpacity: true,
    supportsPressure: true,
    blendMode: BlendMode.srcOver, // Standard paint blending
  );

  static const DrawingTool eraser = DrawingTool(
    type: ToolType.eraser,
    name: 'Eraser',
    iconAsset: 'assets/icons/eraser.png',
    minSize: 5.0,
    maxSize: 50.0,
    defaultSize: 10.0,
    supportsOpacity: false,
    supportsPressure: false,
    blendMode: BlendMode.clear,
  );

  /// Get all available tools
  static List<DrawingTool> get allTools => [pencil, brush, eraser];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawingTool && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'DrawingTool{type: $type, name: $name}';
  }
}
