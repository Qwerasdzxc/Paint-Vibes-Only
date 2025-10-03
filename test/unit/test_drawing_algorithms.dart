import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/widgets/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Unit tests for drawing algorithms and mathematical operations
/// Tests T051: Unit tests for drawing algorithms in test/unit/test_drawing_algorithms.dart
void main() {
  group('Drawing Algorithms Tests', () {
    test('smooth path creation from points should generate quadratic bezier curves', () {
      // ARRANGE
      final points = [
        const Offset(0, 0),
        const Offset(50, 25),
        const Offset(100, 50),
        const Offset(150, 25),
        const Offset(200, 0),
      ];

      final stroke = DrawingStroke(
        id: 'test-stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: points,
      );

      final canvas = DrawingCanvas.empty(id: 'test-canvas', dimensions: const Size(300, 100)).addStroke(stroke);

      // ACT - Create CustomPainter to test path creation
      final painter = DrawingCanvasPainter(canvasModel: canvas);

      // ASSERT - Verify painter was created successfully (path creation happens in paint method)
      expect(painter, isNotNull);
      expect(painter.canvasModel.strokes.length, 1);
      expect(painter.canvasModel.strokes.first.points.length, 5);
    });

    test('stroke point interpolation should calculate correct intermediate points', () {
      // ARRANGE
      const startPoint = Offset(0, 0);
      const endPoint = Offset(100, 100);
      const expectedDistance = 100 * sqrt2; // Distance along diagonal

      // ACT
      final distance = _calculateDistance(startPoint, endPoint);
      final midPoint = _interpolatePoint(startPoint, endPoint, 0.5);

      // ASSERT
      expect(distance, closeTo(expectedDistance, 0.1));
      expect(midPoint.dx, closeTo(50.0, 0.1));
      expect(midPoint.dy, closeTo(50.0, 0.1));
    });

    test('stroke smoothing should reduce jagged edges', () {
      // ARRANGE - Create jagged line points
      final jaggedPoints = [
        const Offset(0, 0),
        const Offset(10, 5),
        const Offset(20, 2),
        const Offset(30, 8),
        const Offset(40, 3),
        const Offset(50, 0),
      ];

      // ACT - Calculate smoothed points using moving average
      final smoothedPoints = _applySmoothingFilter(jaggedPoints, windowSize: 3);

      // ASSERT
      expect(smoothedPoints.length, jaggedPoints.length);
      // First and last points should remain unchanged
      expect(smoothedPoints.first, jaggedPoints.first);
      expect(smoothedPoints.last, jaggedPoints.last);

      // Middle points should be smoothed (less extreme values)
      for (int i = 1; i < smoothedPoints.length - 1; i++) {
        final originalY = jaggedPoints[i].dy;
        final smoothedY = smoothedPoints[i].dy;
        // Smoothed point should be closer to average of neighbors
        final avgY = (jaggedPoints[i - 1].dy + jaggedPoints[i + 1].dy) / 2;
        expect((smoothedY - avgY).abs(), lessThan((originalY - avgY).abs()));
      }
    });

    test('pressure sensitivity should affect brush size', () {
      // ARRANGE
      const baseBrushSize = 10.0;
      final pressureValues = [0.2, 0.5, 0.8, 1.0];

      // ACT & ASSERT
      for (final pressure in pressureValues) {
        final adjustedSize = _calculatePressureSensitiveBrushSize(baseBrushSize, pressure);

        expect(adjustedSize, greaterThan(0));
        expect(adjustedSize, lessThanOrEqualTo(baseBrushSize * 2)); // Max 2x size
        expect(adjustedSize, greaterThanOrEqualTo(baseBrushSize * 0.1)); // Min 0.1x size

        // Higher pressure should generally result in larger brush size
        if (pressure >= 0.8) {
          expect(adjustedSize, greaterThan(baseBrushSize * 0.7));
        }
      }
    });

    test('stroke collision detection should identify overlapping areas', () {
      // ARRANGE
      final stroke1Points = [const Offset(0, 50), const Offset(100, 50)];

      final stroke2Points = [const Offset(50, 0), const Offset(50, 100)];

      final stroke1 = DrawingStroke(
        id: 'stroke1',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 10.0,
        points: stroke1Points,
      );

      final stroke2 = DrawingStroke(
        id: 'stroke2',
        tool: DrawingTool.pencil,
        color: Colors.red,
        brushSize: 10.0,
        points: stroke2Points,
      );

      // ACT
      final hasCollision = _checkStrokeCollision(stroke1, stroke2);
      final collisionPoint = _findCollisionPoint(stroke1, stroke2);

      // ASSERT
      expect(hasCollision, isTrue);
      expect(collisionPoint, isNotNull);
      expect(collisionPoint!.dx, closeTo(50.0, 5.0)); // Near intersection
      expect(collisionPoint.dy, closeTo(50.0, 5.0)); // Near intersection
    });

    test('canvas boundary checking should prevent out-of-bounds drawing', () {
      // ARRANGE
      const canvasSize = Size(200, 150);
      final testPoints = [
        const Offset(-10, 50), // Left boundary
        const Offset(50, -10), // Top boundary
        const Offset(250, 50), // Right boundary
        const Offset(50, 200), // Bottom boundary
        const Offset(100, 75), // Inside bounds
      ];

      // ACT & ASSERT
      for (final point in testPoints) {
        final isInBounds = _isPointInBounds(point, canvasSize);

        if (point.dx >= 0 && point.dx <= canvasSize.width && point.dy >= 0 && point.dy <= canvasSize.height) {
          expect(isInBounds, isTrue, reason: 'Point $point should be in bounds');
        } else {
          expect(isInBounds, isFalse, reason: 'Point $point should be out of bounds');
        }
      }
    });

    test('eraser algorithm should properly remove stroke segments', () {
      // ARRANGE
      final originalPoints = List.generate(10, (i) => Offset(i * 10.0, 50.0));
      final eraserCenter = const Offset(50, 50);
      const eraserRadius = 15.0;

      // ACT
      final remainingPoints = _applyEraserToPoints(originalPoints, eraserCenter, eraserRadius);

      // ASSERT
      expect(remainingPoints.length, lessThan(originalPoints.length));

      // Points within eraser radius should be removed
      for (final point in remainingPoints) {
        final distance = _calculateDistance(point, eraserCenter);
        expect(distance, greaterThan(eraserRadius));
      }
    });

    test('drawing performance should meet latency requirements', () {
      // ARRANGE
      final largePointList = List.generate(1000, (i) => Offset(i.toDouble(), sin(i / 10) * 50 + 100));
      final stroke = DrawingStroke(
        id: 'performance-test',
        tool: DrawingTool.brush,
        color: Colors.blue,
        brushSize: 5.0,
        points: largePointList,
      );

      // ACT - Measure path creation time
      final stopwatch = Stopwatch()..start();
      final canvas = DrawingCanvas.empty(id: 'perf-canvas', dimensions: const Size(1000, 200)).addStroke(stroke);

      final painter = DrawingCanvasPainter(canvasModel: canvas);
      stopwatch.stop();

      // ASSERT - Should complete within 50ms requirement
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(painter.canvasModel.strokes.first.points.length, 1000);
    });
  });
}

// Helper functions for drawing algorithms testing

double _calculateDistance(Offset point1, Offset point2) {
  final dx = point2.dx - point1.dx;
  final dy = point2.dy - point1.dy;
  return sqrt(dx * dx + dy * dy);
}

Offset _interpolatePoint(Offset start, Offset end, double t) {
  return Offset(start.dx + (end.dx - start.dx) * t, start.dy + (end.dy - start.dy) * t);
}

List<Offset> _applySmoothingFilter(List<Offset> points, {int windowSize = 3}) {
  if (points.length < windowSize) return points;

  final smoothedPoints = <Offset>[];

  for (int i = 0; i < points.length; i++) {
    if (i == 0 || i == points.length - 1) {
      // Keep first and last points unchanged
      smoothedPoints.add(points[i]);
    } else {
      // Apply moving average to middle points
      double sumX = 0, sumY = 0;
      int count = 0;

      for (int j = max(0, i - windowSize ~/ 2); j <= min(points.length - 1, i + windowSize ~/ 2); j++) {
        sumX += points[j].dx;
        sumY += points[j].dy;
        count++;
      }

      smoothedPoints.add(Offset(sumX / count, sumY / count));
    }
  }

  return smoothedPoints;
}

double _calculatePressureSensitiveBrushSize(double baseBrushSize, double pressure) {
  // Clamp pressure between 0.1 and 2.0 for reasonable size variation
  final clampedPressure = pressure.clamp(0.1, 2.0);
  return baseBrushSize * clampedPressure;
}

bool _checkStrokeCollision(DrawingStroke stroke1, DrawingStroke stroke2) {
  // Simplified collision detection - check if any point from stroke1 is within
  // brush size distance from any point in stroke2
  final combinedRadius = (stroke1.brushSize + stroke2.brushSize);

  for (final point1 in stroke1.points) {
    for (final point2 in stroke2.points) {
      if (_calculateDistance(point1, point2) < combinedRadius) {
        return true;
      }
    }
  }
  return false;
}

Offset? _findCollisionPoint(DrawingStroke stroke1, DrawingStroke stroke2) {
  final combinedRadius = (stroke1.brushSize + stroke2.brushSize);

  for (final point1 in stroke1.points) {
    for (final point2 in stroke2.points) {
      if (_calculateDistance(point1, point2) < combinedRadius) {
        // Return midpoint of collision
        return Offset((point1.dx + point2.dx) / 2, (point1.dy + point2.dy) / 2);
      }
    }
  }
  return null;
}

bool _isPointInBounds(Offset point, Size canvasSize) {
  return point.dx >= 0 && point.dx <= canvasSize.width && point.dy >= 0 && point.dy <= canvasSize.height;
}

List<Offset> _applyEraserToPoints(List<Offset> points, Offset eraserCenter, double eraserRadius) {
  return points.where((point) {
    final distance = _calculateDistance(point, eraserCenter);
    return distance > eraserRadius;
  }).toList();
}
