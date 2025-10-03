import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

void main() {
  group('DrawingStroke Tests', () {
    test('should create drawing stroke with required fields', () {
      final points = [const Offset(10, 10), const Offset(20, 20), const Offset(30, 30)];

      final stroke = DrawingStroke(
        id: 'test-stroke-id',
        tool: DrawingTool.pencil,
        color: Colors.blue,
        brushSize: 5.0,
        points: points,
      );

      expect(stroke.id, 'test-stroke-id');
      expect(stroke.tool, DrawingTool.pencil);
      expect(stroke.color, Colors.blue);
      expect(stroke.brushSize, 5.0);
      expect(stroke.points.length, 3);
      expect(stroke.opacity, 1.0); // Default opacity
      expect(stroke.blendMode, DrawingTool.pencil.blendMode); // Default blend mode from tool
    });

    test('should handle different drawing tools', () {
      final pencilStroke = DrawingStroke(
        id: 'pencil-stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(0, 0)],
      );

      final brushStroke = DrawingStroke(
        id: 'brush-stroke',
        tool: DrawingTool.brush,
        color: Colors.red,
        brushSize: 10.0,
        points: [const Offset(0, 0)],
      );

      final eraserStroke = DrawingStroke(
        id: 'eraser-stroke',
        tool: DrawingTool.eraser,
        color: Colors.transparent,
        brushSize: 15.0,
        points: [const Offset(0, 0)],
      );

      expect(pencilStroke.tool, DrawingTool.pencil);
      expect(brushStroke.tool, DrawingTool.brush);
      expect(eraserStroke.tool, DrawingTool.eraser);
    });

    test('should handle stroke points correctly', () {
      final points = [const Offset(0, 0), const Offset(5, 5), const Offset(10, 8), const Offset(15, 12)];

      final stroke = DrawingStroke(
        id: 'points-test',
        tool: DrawingTool.brush,
        color: Colors.green,
        brushSize: 3.0,
        points: points,
      );

      expect(stroke.points.length, 4);
      expect(stroke.points[0], const Offset(0, 0));
      expect(stroke.points[1], const Offset(5, 5));
      expect(stroke.points[2], const Offset(10, 8));
      expect(stroke.points[3], const Offset(15, 12));
    });

    test('should handle opacity and blend modes', () {
      final stroke = DrawingStroke(
        id: 'opacity-test',
        tool: DrawingTool.brush,
        color: Colors.purple,
        brushSize: 4.0,
        points: [const Offset(0, 0)],
        opacity: 0.5,
        blendMode: BlendMode.multiply,
      );

      expect(stroke.opacity, 0.5);
      expect(stroke.blendMode, BlendMode.multiply);
    });

    test('should use tool default blend mode when not specified', () {
      final stroke = DrawingStroke(
        id: 'default-blend-test',
        tool: DrawingTool.pencil,
        color: Colors.orange,
        brushSize: 2.0,
        points: [const Offset(0, 0)],
      );

      expect(stroke.blendMode, DrawingTool.pencil.blendMode);
    });

    test('should handle timestamp correctly', () {
      final customTimestamp = DateTime(2023, 5, 15, 10, 30, 0);

      final strokeWithTimestamp = DrawingStroke(
        id: 'timestamp-test',
        tool: DrawingTool.brush,
        color: Colors.cyan,
        brushSize: 6.0,
        points: [const Offset(0, 0)],
        timestamp: customTimestamp,
      );

      expect(strokeWithTimestamp.timestamp, customTimestamp);

      // Test default timestamp (current time)
      final strokeWithDefaultTimestamp = DrawingStroke(
        id: 'default-timestamp-test',
        tool: DrawingTool.brush,
        color: Colors.cyan,
        brushSize: 6.0,
        points: [const Offset(0, 0)],
      );

      final now = DateTime.now();
      expect(strokeWithDefaultTimestamp.timestamp.difference(now).inSeconds.abs() < 2, true);
    });

    test('should copy with modified properties', () {
      final originalStroke = DrawingStroke(
        id: 'original-id',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(0, 0), const Offset(10, 10)],
        opacity: 1.0,
      );

      final modifiedStroke = originalStroke.copyWith(color: Colors.red, brushSize: 5.0, opacity: 0.8);

      expect(modifiedStroke.id, originalStroke.id);
      expect(modifiedStroke.tool, originalStroke.tool);
      expect(modifiedStroke.color, Colors.red);
      expect(modifiedStroke.brushSize, 5.0);
      expect(modifiedStroke.opacity, 0.8);
      expect(modifiedStroke.points.length, originalStroke.points.length);
    });

    test('should convert to and from JSON', () {
      final points = [const Offset(1.5, 2.3), const Offset(4.7, 8.9), const Offset(12.1, 15.6)];

      final originalStroke = DrawingStroke(
        id: 'json-test-stroke',
        tool: DrawingTool.brush,
        color: const Color(0xFF123456),
        brushSize: 7.5,
        points: points,
        opacity: 0.75,
        blendMode: BlendMode.multiply,
        timestamp: DateTime(2023, 6, 20, 14, 30, 45),
      );

      final json = originalStroke.toJson();
      final restoredStroke = DrawingStroke.fromJson(json);

      expect(restoredStroke.id, originalStroke.id);
      expect(restoredStroke.tool, originalStroke.tool);
      expect(restoredStroke.color.value, originalStroke.color.value);
      expect(restoredStroke.brushSize, originalStroke.brushSize);
      expect(restoredStroke.points.length, originalStroke.points.length);
      expect(restoredStroke.points[0].dx, closeTo(points[0].dx, 0.001));
      expect(restoredStroke.points[0].dy, closeTo(points[0].dy, 0.001));
      expect(restoredStroke.opacity, originalStroke.opacity);
      expect(restoredStroke.blendMode, originalStroke.blendMode);
      expect(restoredStroke.timestamp, originalStroke.timestamp);
    });

    test('should handle color serialization correctly', () {
      final stroke = DrawingStroke(
        id: 'color-test',
        tool: DrawingTool.brush,
        color: const Color.fromARGB(128, 255, 128, 64), // Semi-transparent orange
        brushSize: 4.0,
        points: [const Offset(0, 0)],
      );

      final json = stroke.toJson();
      final restoredStroke = DrawingStroke.fromJson(json);

      expect(restoredStroke.color.alpha, 128);
      expect(restoredStroke.color.red, 255);
      expect(restoredStroke.color.green, 128);
      expect(restoredStroke.color.blue, 64);
    });

    test('should handle tool type mapping in JSON', () {
      final pencilStroke = DrawingStroke(
        id: 'pencil-json-test',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 1.0,
        points: [const Offset(0, 0)],
      );

      final brushStroke = DrawingStroke(
        id: 'brush-json-test',
        tool: DrawingTool.brush,
        color: Colors.red,
        brushSize: 5.0,
        points: [const Offset(0, 0)],
      );

      final eraserStroke = DrawingStroke(
        id: 'eraser-json-test',
        tool: DrawingTool.eraser,
        color: Colors.transparent,
        brushSize: 10.0,
        points: [const Offset(0, 0)],
      );

      // Test serialization and deserialization
      final pencilJson = pencilStroke.toJson();
      final brushJson = brushStroke.toJson();
      final eraserJson = eraserStroke.toJson();

      final restoredPencil = DrawingStroke.fromJson(pencilJson);
      final restoredBrush = DrawingStroke.fromJson(brushJson);
      final restoredEraser = DrawingStroke.fromJson(eraserJson);

      expect(restoredPencil.tool, DrawingTool.pencil);
      expect(restoredBrush.tool, DrawingTool.brush);
      expect(restoredEraser.tool, DrawingTool.eraser);
    });

    test('should handle equality comparison correctly', () {
      final stroke1 = DrawingStroke(
        id: 'equality-test-id',
        tool: DrawingTool.pencil,
        color: Colors.blue,
        brushSize: 3.0,
        points: [const Offset(0, 0)],
      );

      final stroke2 = DrawingStroke(
        id: 'equality-test-id', // Same ID
        tool: DrawingTool.brush, // Different tool
        color: Colors.red, // Different color
        brushSize: 5.0, // Different brush size
        points: [const Offset(10, 10)], // Different points
      );

      final stroke3 = DrawingStroke(
        id: 'different-id',
        tool: DrawingTool.pencil,
        color: Colors.blue,
        brushSize: 3.0,
        points: [const Offset(0, 0)],
      );

      // Equality is based on ID only
      expect(stroke1, equals(stroke2));
      expect(stroke1, isNot(equals(stroke3)));
      expect(stroke1.hashCode, equals(stroke2.hashCode));
      expect(stroke1.hashCode, isNot(equals(stroke3.hashCode)));
    });

    test('should handle toString method', () {
      final stroke = DrawingStroke(
        id: 'toString-test-id',
        tool: DrawingTool.brush,
        color: Colors.green,
        brushSize: 4.0,
        points: [const Offset(0, 0), const Offset(5, 5), const Offset(10, 10)],
      );

      final stringRepresentation = stroke.toString();
      expect(stringRepresentation.contains('toString-test-id'), true);
      expect(stringRepresentation.contains('brush'), true);
      expect(stringRepresentation.contains('3'), true); // Points count
    });

    test('should handle empty points list', () {
      final stroke = DrawingStroke(
        id: 'empty-points-test',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [],
      );

      expect(stroke.points.isEmpty, true);
      expect(stroke.points.length, 0);
    });

    test('should handle single point stroke', () {
      final singlePointStroke = DrawingStroke(
        id: 'single-point-test',
        tool: DrawingTool.brush,
        color: Colors.yellow,
        brushSize: 8.0,
        points: [const Offset(50, 75)],
      );

      expect(singlePointStroke.points.length, 1);
      expect(singlePointStroke.points[0], const Offset(50, 75));
    });
  });
}
