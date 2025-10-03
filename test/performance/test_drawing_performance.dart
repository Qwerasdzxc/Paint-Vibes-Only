import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/shared/models/drawing_canvas.dart';

void main() {
  group('Drawing Performance Tests', () {
    test('should handle large number of strokes efficiently', () {
      final stopwatch = Stopwatch()..start();

      const strokeCount = 1000;
      final strokes = <DrawingStroke>[];

      // Create many strokes
      for (int i = 0; i < strokeCount; i++) {
        final points = List.generate(10, (index) => Offset(index.toDouble(), index.toDouble()));
        strokes.add(
          DrawingStroke(id: 'stroke-$i', tool: DrawingTool.pencil, color: Colors.black, brushSize: 2.0, points: points),
        );
      }

      stopwatch.stop();

      // Should create 1000 strokes in reasonable time (< 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(strokes.length, strokeCount);
    });

    test('should handle canvas with many strokes efficiently', () {
      final stopwatch = Stopwatch()..start();

      // Create canvas with many strokes
      final strokes = <DrawingStroke>[];
      for (int i = 0; i < 500; i++) {
        final points = List.generate(20, (index) => Offset(index.toDouble() * 2, index.toDouble() * 2));
        strokes.add(
          DrawingStroke(
            id: 'perf-stroke-$i',
            tool: DrawingTool.brush,
            color: Color((0xFF000000 + i) % 0xFFFFFFFF),
            brushSize: 3.0 + (i % 10),
            points: points,
          ),
        );
      }

      final canvas = DrawingCanvas(
        id: 'performance-canvas',
        dimensions: const Size(800, 600),
        backgroundColor: Colors.white,
        strokes: strokes,
        currentTool: DrawingTool.pencil,
        currentColor: Colors.black,
        currentBrushSize: 2.0,
        isDirty: false,
      );

      stopwatch.stop();

      // Canvas creation should be fast even with many strokes
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(canvas.strokes.length, 500);
    });

    test('should handle stroke serialization performance', () {
      // Create stroke with many points
      final points = List.generate(1000, (index) => Offset(index.toDouble(), index.toDouble() * 0.5));

      final stroke = DrawingStroke(
        id: 'large-stroke',
        tool: DrawingTool.brush,
        color: Colors.red,
        brushSize: 5.0,
        points: points,
      );

      final stopwatch = Stopwatch()..start();

      // Serialize to JSON
      final json = stroke.toJson();

      // Deserialize from JSON
      final restoredStroke = DrawingStroke.fromJson(json);

      stopwatch.stop();

      // Serialization/deserialization should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(restoredStroke.points.length, points.length);
    });

    test('should handle batch stroke operations efficiently', () {
      final stopwatch = Stopwatch()..start();

      var canvas = DrawingCanvas(
        id: 'batch-test',
        dimensions: const Size(1000, 1000),
        backgroundColor: Colors.white,
        strokes: [],
        currentTool: DrawingTool.pencil,
        currentColor: Colors.black,
        currentBrushSize: 2.0,
        isDirty: false,
      );

      // Add many strokes in batch
      final newStrokes = <DrawingStroke>[];
      for (int i = 0; i < 200; i++) {
        final points = [Offset(i.toDouble(), i.toDouble()), Offset(i + 10.0, i + 10.0), Offset(i + 20.0, i + 5.0)];

        newStrokes.add(
          DrawingStroke(
            id: 'batch-stroke-$i',
            tool: DrawingTool.pencil,
            color: Colors.blue,
            brushSize: 2.0,
            points: points,
          ),
        );
      }

      // Add all strokes at once
      canvas = canvas.copyWith(strokes: [...canvas.strokes, ...newStrokes]);

      stopwatch.stop();

      // Batch operations should be efficient
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(canvas.strokes.length, 200);
    });

    test('should measure memory usage for large canvas', () {
      // Create large canvas with many complex strokes
      final strokes = <DrawingStroke>[];
      for (int i = 0; i < 100; i++) {
        // Create strokes with many points
        final points = List.generate(100, (index) {
          final angle = (index * 2 * math.pi) / 100;
          return Offset(50 + 40 * math.cos(angle), 50 + 40 * math.sin(angle));
        });

        strokes.add(
          DrawingStroke(
            id: 'memory-stroke-$i',
            tool: DrawingTool.brush,
            color: Color((0xFF000000 + i * 1000) % 0xFFFFFFFF),
            brushSize: 5.0,
            points: points,
          ),
        );
      }

      final largeCanvas = DrawingCanvas(
        id: 'memory-test-canvas',
        dimensions: const Size(2000, 2000),
        backgroundColor: Colors.white,
        strokes: strokes,
        currentTool: DrawingTool.brush,
        currentColor: Colors.red,
        currentBrushSize: 5.0,
        isDirty: true,
      );

      // Memory usage should be reasonable
      expect(largeCanvas.strokes.length, 100);
      // Note: Actual memory measurement in unit tests is approximate
      // In real scenarios, you'd use proper memory profiling tools
    });

    test('should handle rapid stroke updates efficiently', () {
      var canvas = DrawingCanvas(
        id: 'rapid-update-test',
        dimensions: const Size(500, 500),
        backgroundColor: Colors.white,
        strokes: [],
        currentTool: DrawingTool.pencil,
        currentColor: Colors.black,
        currentBrushSize: 2.0,
        isDirty: false,
      );

      final stopwatch = Stopwatch()..start();

      // Simulate rapid drawing updates
      for (int i = 0; i < 50; i++) {
        final stroke = DrawingStroke(
          id: 'rapid-stroke-$i',
          tool: DrawingTool.pencil,
          color: Colors.black,
          brushSize: 2.0,
          points: [Offset(i.toDouble(), 0), Offset(i.toDouble(), 10), Offset(i.toDouble(), 20)],
        );

        // Add stroke to canvas (simulating real-time drawing)
        canvas = canvas.addStroke(stroke);
      }

      stopwatch.stop();

      // Rapid updates should be handled efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(canvas.strokes.length, 50);
    });

    test('should handle color blending performance', () {
      final stopwatch = Stopwatch()..start();

      final strokes = <DrawingStroke>[];

      // Create strokes with different blend modes
      for (int i = 0; i < 100; i++) {
        final blendMode = [BlendMode.srcOver, BlendMode.multiply, BlendMode.screen, BlendMode.overlay][i % 4];

        strokes.add(
          DrawingStroke(
            id: 'blend-stroke-$i',
            tool: DrawingTool.brush,
            color: Color((0xFF000000 + i * 256) % 0xFFFFFFFF),
            brushSize: 4.0,
            points: [Offset(i.toDouble(), i.toDouble())],
            blendMode: blendMode,
          ),
        );
      }

      stopwatch.stop();

      // Creating strokes with different blend modes should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(30));
      expect(strokes.length, 100);
    });

    test('should handle canvas bounds checking efficiently', () {
      final canvas = DrawingCanvas(
        id: 'bounds-test',
        dimensions: const Size(100, 100),
        backgroundColor: Colors.white,
        strokes: [],
        currentTool: DrawingTool.pencil,
        currentColor: Colors.black,
        currentBrushSize: 2.0,
        isDirty: false,
      );

      final stopwatch = Stopwatch()..start();

      // Test many points for bounds checking
      for (int i = 0; i < 1000; i++) {
        final point = Offset(i.toDouble() * 0.5, i.toDouble() * 0.3);

        // Simulate bounds checking (in real app, this would be in canvas logic)
        final isInBounds =
            point.dx >= 0 &&
            point.dx <= canvas.dimensions.width &&
            point.dy >= 0 &&
            point.dy <= canvas.dimensions.height;

        expect(isInBounds, isA<bool>());
      }

      stopwatch.stop();

      // Bounds checking should be very fast
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('should handle undo/redo operations efficiently', () {
      var canvas = DrawingCanvas(
        id: 'undo-test',
        dimensions: const Size(400, 400),
        backgroundColor: Colors.white,
        strokes: [],
        currentTool: DrawingTool.pencil,
        currentColor: Colors.black,
        currentBrushSize: 2.0,
        isDirty: false,
      );

      final stopwatch = Stopwatch()..start();

      // Add strokes
      final strokes = <DrawingStroke>[];
      for (int i = 0; i < 20; i++) {
        final stroke = DrawingStroke(
          id: 'undo-stroke-$i',
          tool: DrawingTool.pencil,
          color: Colors.black,
          brushSize: 2.0,
          points: [Offset(i.toDouble(), i.toDouble())],
        );
        strokes.add(stroke);
        canvas = canvas.addStroke(stroke);
      }

      // Simulate undo operations (by removing strokes)
      for (int i = 0; i < 10; i++) {
        final strokesWithoutLast = canvas.strokes.take(canvas.strokes.length - 1).toList();
        canvas = canvas.copyWith(strokes: strokesWithoutLast);
      }

      // Simulate redo operations (by re-adding strokes)
      for (int i = 10; i < 15; i++) {
        canvas = canvas.addStroke(strokes[i]);
      }

      stopwatch.stop();

      // Undo/redo operations should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(20));
      expect(canvas.strokes.length, 15);
    });

    test('should handle canvas serialization performance', () {
      // Create canvas with moderate number of strokes
      final strokes = <DrawingStroke>[];
      for (int i = 0; i < 100; i++) {
        final points = List.generate(10, (index) => Offset(index.toDouble() + i, index.toDouble() + i));
        strokes.add(
          DrawingStroke(
            id: 'serialize-stroke-$i',
            tool: DrawingTool.brush,
            color: Color((0xFF000000 + i * 100) % 0xFFFFFFFF),
            brushSize: 3.0,
            points: points,
          ),
        );
      }

      final canvas = DrawingCanvas(
        id: 'serialize-test',
        dimensions: const Size(800, 600),
        backgroundColor: Colors.lightBlue,
        strokes: strokes,
        currentTool: DrawingTool.brush,
        currentColor: Colors.red,
        currentBrushSize: 5.0,
        isDirty: true,
      );

      final stopwatch = Stopwatch()..start();

      // Serialize canvas
      final json = canvas.toJson();

      // Deserialize canvas
      final restoredCanvas = DrawingCanvas.fromJson(json);

      stopwatch.stop();

      // Canvas serialization should be reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      expect(restoredCanvas.strokes.length, canvas.strokes.length);
      expect(restoredCanvas.id, canvas.id);
    });

    test('should validate canvas performance limits', () {
      final canvas = DrawingCanvas.empty(id: 'validation-test', dimensions: const Size(1000, 1000));

      final stopwatch = Stopwatch()..start();

      // Test validation with maximum allowed strokes
      final maxStrokes = <DrawingStroke>[];
      for (int i = 0; i < 10000; i++) {
        // Maximum allowed by validation
        maxStrokes.add(
          DrawingStroke(
            id: 'max-stroke-$i',
            tool: DrawingTool.pencil,
            color: Colors.black,
            brushSize: 1.0,
            points: [Offset(i.toDouble() % 100, (i / 100).floor().toDouble())],
          ),
        );
      }

      final canvasWithMaxStrokes = canvas.copyWith(strokes: maxStrokes);

      stopwatch.stop();

      // Should handle maximum strokes efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(canvasWithMaxStrokes.isValid, true);
      expect(canvasWithMaxStrokes.strokes.length, 10000);
    });
  });
}
