import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/services/i_drawing_service.dart';
import 'package:painter/features/drawing/services/drawing_service.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Contract test for IDrawingService interface
/// These tests define the behavior contract that any DrawingService implementation must follow
void main() {
  group('IDrawingService Contract Tests', () {
    late IDrawingService drawingService;

    setUp(() {
      // Use actual implementation for contract testing
      drawingService = DrawingService();
    });

    test('should create canvas with valid parameters', () async {
      // ARRANGE
      const dimensions = Size(800, 600);
      const backgroundColor = Colors.white;

      // ACT
      final canvas = await drawingService.createCanvas(dimensions, backgroundColor: backgroundColor);

      // ASSERT
      expect(canvas.dimensions, equals(dimensions));
      expect(canvas.backgroundColor, equals(backgroundColor));
      expect(canvas.strokes, isEmpty);
      expect(canvas.id, isNotEmpty);
      expect(canvas.isDirty, isFalse);
    });

    test('should throw CanvasNotFoundException for invalid canvas ID', () async {
      // ARRANGE
      const invalidId = 'non_existent_canvas';

      // ACT & ASSERT
      expect(() => drawingService.loadCanvas(invalidId), throwsA(isA<CanvasNotFoundException>()));
    });

    test('should add stroke to canvas', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));
      final stroke = DrawingStroke(
        id: 'test_stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );

      // ACT
      await drawingService.addStroke(canvas.id, stroke);

      // ASSERT
      final updatedCanvas = await drawingService.loadCanvas(canvas.id);
      expect(updatedCanvas.strokes, hasLength(1));
      expect(updatedCanvas.strokes.first.id, equals('test_stroke'));
      expect(updatedCanvas.isDirty, isTrue);
    });

    test('should support undo operation', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));
      final stroke = DrawingStroke(
        id: 'test_stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );

      await drawingService.addStroke(canvas.id, stroke);

      // ACT
      final canUndo = await drawingService.canUndo(canvas.id);
      final undoResult = await drawingService.undoLastAction(canvas.id);

      // ASSERT
      expect(canUndo, isTrue);
      expect(undoResult, isTrue);

      final updatedCanvas = await drawingService.loadCanvas(canvas.id);
      expect(updatedCanvas.strokes, isEmpty);
    });

    test('should support redo operation', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));
      final stroke = DrawingStroke(
        id: 'test_stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );

      await drawingService.addStroke(canvas.id, stroke);
      await drawingService.undoLastAction(canvas.id);

      // ACT
      final canRedo = await drawingService.canRedo(canvas.id);
      final redoResult = await drawingService.redoLastAction(canvas.id);

      // ASSERT
      expect(canRedo, isTrue);
      expect(redoResult, isTrue);

      final updatedCanvas = await drawingService.loadCanvas(canvas.id);
      expect(updatedCanvas.strokes, hasLength(1));
    });

    test('should clear entire canvas', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));
      final stroke1 = DrawingStroke(
        id: 'stroke_1',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );
      final stroke2 = DrawingStroke(
        id: 'stroke_2',
        tool: DrawingTool.brush,
        color: Colors.red,
        brushSize: 5.0,
        points: [const Offset(30, 30), const Offset(40, 40)],
      );

      await drawingService.addStroke(canvas.id, stroke1);
      await drawingService.addStroke(canvas.id, stroke2);

      // ACT
      await drawingService.clearCanvas(canvas.id);

      // ASSERT
      final updatedCanvas = await drawingService.loadCanvas(canvas.id);
      expect(updatedCanvas.strokes, isEmpty);
      expect(updatedCanvas.isDirty, isTrue);
    });

    test('should manage current tool', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));

      // ACT
      final initialTool = drawingService.getCurrentTool(canvas.id);
      await drawingService.setCurrentTool(canvas.id, DrawingTool.brush);
      final updatedTool = drawingService.getCurrentTool(canvas.id);

      // ASSERT
      expect(initialTool, equals(DrawingTool.pencil)); // Default tool
      expect(updatedTool, equals(DrawingTool.brush));
    });

    test('should return available tools', () {
      // ACT
      final availableTools = drawingService.getAvailableTools();

      // ASSERT
      expect(availableTools, isNotEmpty);
      expect(availableTools, contains(DrawingTool.pencil));
      expect(availableTools, contains(DrawingTool.brush));
      expect(availableTools, contains(DrawingTool.eraser));
    });

    test('should support real-time stroke operations', () {
      // ARRANGE
      const startPoint = Offset(100, 100);
      const strokeWidth = 5.0;
      const color = Colors.blue;

      // ACT & ASSERT - Should not throw exceptions
      expect(() => drawingService.startStroke(startPoint, strokeWidth, color), returnsNormally);
      expect(() => drawingService.addStrokePoint(const Offset(110, 110)), returnsNormally);
      expect(() => drawingService.addStrokePoint(const Offset(120, 120)), returnsNormally);
      expect(() => drawingService.endStroke(), returnsNormally);
    });

    test('should export canvas as JSON', () async {
      // ARRANGE
      final canvas = await drawingService.createCanvas(const Size(800, 600));
      final stroke = DrawingStroke(
        id: 'test_stroke',
        tool: DrawingTool.pencil,
        color: Colors.black,
        brushSize: 2.0,
        points: [const Offset(10, 10), const Offset(20, 20)],
      );

      await drawingService.addStroke(canvas.id, stroke);

      // ACT
      final jsonString = await drawingService.exportCanvasAsJson(canvas.id);

      // ASSERT
      expect(jsonString, isNotEmpty);
      expect(jsonString, contains('test_stroke'));
    });
  });
}
