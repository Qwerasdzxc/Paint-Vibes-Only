import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

void main() {
  group('Model Coverage Tests', () {
    test('Drawing canvas factory methods and operations', () {
      // Test empty canvas creation
      final emptyCanvas = DrawingCanvas.empty(id: 'test-canvas', dimensions: const Size(800, 600));

      expect(emptyCanvas.id, 'test-canvas');
      expect(emptyCanvas.dimensions, const Size(800, 600));
      expect(emptyCanvas.strokes, isEmpty);
      expect(emptyCanvas.isDirty, false);

      // Test adding strokes
      final stroke = DrawingStroke(
        id: 'stroke-1',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 5.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );

      final updatedCanvas = emptyCanvas.addStroke(stroke);
      expect(updatedCanvas.strokes.length, 1);
      expect(updatedCanvas.isDirty, true);

      // Test removing strokes
      final clearedCanvas = updatedCanvas.removeStroke('stroke-1');
      expect(clearedCanvas.strokes.length, 0);

      // Test clearing all strokes
      final clearAllCanvas = updatedCanvas.clearStrokes();
      expect(clearAllCanvas.strokes, isEmpty);
      expect(clearAllCanvas.isDirty, true);

      // Test mark as saved
      final savedCanvas = updatedCanvas.markAsSaved();
      expect(savedCanvas.isDirty, false);

      // Test validation
      expect(emptyCanvas.isValid, true);

      // Test equality
      expect(emptyCanvas == emptyCanvas, true);
      expect(emptyCanvas.hashCode, emptyCanvas.hashCode);

      // Test toString
      expect(emptyCanvas.toString().contains('test-canvas'), true);
    });

    test('Drawing canvas JSON serialization', () {
      final canvas = DrawingCanvas(
        id: 'test-canvas',
        dimensions: const Size(100, 100),
        backgroundColor: Colors.white,
        strokes: [
          DrawingStroke(
            id: 'stroke-1',
            tool: DrawingTool.brush,
            color: Colors.red,
            brushSize: 10.0,
            points: [const Offset(5, 5)],
          ),
        ],
        currentTool: DrawingTool.pencil,
        currentColor: Colors.blue,
        currentBrushSize: 3.0,
        isDirty: true,
      );

      // Test serialization
      final json = canvas.toJson();
      expect(json['id'], 'test-canvas');
      expect(json['version'], '1.0');
      expect(json['dimensions']['width'], 100.0);
      expect(json['dimensions']['height'], 100.0);
      expect(json['strokes'], isA<List>());
      expect(json['currentTool'], 'pencil');

      // Test deserialization
      final restored = DrawingCanvas.fromJson(json);
      expect(restored.id, canvas.id);
      expect(restored.dimensions, canvas.dimensions);
      expect(restored.backgroundColor.value, canvas.backgroundColor.value);
      expect(restored.strokes.length, canvas.strokes.length);
      expect(restored.currentTool.type, canvas.currentTool.type);
    });

    test('Drawing stroke operations and serialization', () {
      final stroke = DrawingStroke(
        id: 'test-stroke',
        tool: DrawingTool.brush,
        color: Colors.green,
        brushSize: 8.0,
        points: [const Offset(1, 1), const Offset(2, 2)],
        opacity: 0.8,
      );

      // Test basic properties
      expect(stroke.id, 'test-stroke');
      expect(stroke.tool, DrawingTool.brush);
      expect(stroke.color, Colors.green);
      expect(stroke.brushSize, 8.0);
      expect(stroke.points.length, 2);
      expect(stroke.opacity, 0.8);

      // Test copy with
      final copiedStroke = stroke.copyWith(color: Colors.yellow, brushSize: 12.0);
      expect(copiedStroke.color, Colors.yellow);
      expect(copiedStroke.brushSize, 12.0);
      expect(copiedStroke.id, stroke.id); // Should remain the same

      // Test JSON serialization
      final json = stroke.toJson();
      expect(json['id'], 'test-stroke');
      expect(json['tool'], 'brush');
      expect(json['brushSize'], 8.0);
      expect(json['opacity'], 0.8);
      expect(json['points'], isA<List>());

      // Test JSON deserialization
      final restored = DrawingStroke.fromJson(json);
      expect(restored.id, stroke.id);
      expect(restored.tool.type, stroke.tool.type);
      expect(restored.color.value, stroke.color.value);
      expect(restored.brushSize, stroke.brushSize);
      expect(restored.points.length, stroke.points.length);

      // Test basic equality and hash code
      expect(stroke == stroke, true);
      expect(stroke.hashCode, stroke.hashCode);

      // Test toString
      final toStringResult = stroke.toString();
      expect(toStringResult.contains('test-stroke'), true);
    });

    test('Drawing tool operations', () {
      // Test predefined tools
      expect(DrawingTool.pencil.type, ToolType.pencil);
      expect(DrawingTool.pencil.name, 'Pencil');
      expect(DrawingTool.pencil.defaultSize, 2.0);
      expect(DrawingTool.pencil.minSize, 1.0);
      expect(DrawingTool.pencil.maxSize, 10.0);
      expect(DrawingTool.pencil.supportsOpacity, false);
      expect(DrawingTool.pencil.supportsPressure, false);
      expect(DrawingTool.pencil.blendMode, BlendMode.srcOver);

      expect(DrawingTool.brush.type, ToolType.brush);
      expect(DrawingTool.brush.name, 'Brush');
      expect(DrawingTool.brush.supportsOpacity, true);
      expect(DrawingTool.brush.supportsPressure, true);

      expect(DrawingTool.eraser.type, ToolType.eraser);
      expect(DrawingTool.eraser.name, 'Eraser');
      expect(DrawingTool.eraser.blendMode, BlendMode.clear);

      // Test all tools
      final allTools = DrawingTool.allTools;
      expect(allTools.length, 3);
      expect(allTools.contains(DrawingTool.pencil), true);
      expect(allTools.contains(DrawingTool.brush), true);
      expect(allTools.contains(DrawingTool.eraser), true);

      // Test equality
      expect(DrawingTool.pencil == DrawingTool.pencil, true);
      expect(DrawingTool.pencil == DrawingTool.brush, false);

      // Test hash code
      expect(DrawingTool.pencil.hashCode, DrawingTool.pencil.hashCode);

      // Test toString
      expect(DrawingTool.pencil.toString().contains('pencil'), true);
      expect(DrawingTool.pencil.toString().contains('Pencil'), true);
    });
  });
}
