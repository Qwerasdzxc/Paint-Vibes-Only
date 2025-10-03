import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:painter/features/drawing/services/i_drawing_service.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Implementation of IDrawingService for managing drawing operations
class DrawingService implements IDrawingService {
  final Map<String, DrawingCanvas> _canvases = {};
  final Map<String, List<DrawingStroke>> _undoHistory = {};
  final Map<String, List<DrawingStroke>> _redoHistory = {};

  // Current stroke being drawn (for real-time operations)
  DrawingStroke? _currentStroke;
  String? _currentCanvasId;
  final List<Offset> _currentStrokePoints = [];

  @override
  Future<DrawingCanvas> createCanvas(Size dimensions, {Color? backgroundColor}) async {
    final canvasId = 'canvas_${DateTime.now().millisecondsSinceEpoch}';
    final canvas = DrawingCanvas.empty(id: canvasId, dimensions: dimensions, backgroundColor: backgroundColor);

    _canvases[canvasId] = canvas;
    _undoHistory[canvasId] = [];
    _redoHistory[canvasId] = [];

    return canvas;
  }

  @override
  Future<DrawingCanvas> loadCanvas(String canvasId) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }
    return canvas;
  }

  @override
  Future<void> saveCanvas(DrawingCanvas canvas) async {
    _canvases[canvas.id] = canvas.markAsSaved();
  }

  @override
  Future<bool> deleteCanvas(String canvasId) async {
    final removed = _canvases.remove(canvasId) != null;
    _undoHistory.remove(canvasId);
    _redoHistory.remove(canvasId);
    return removed;
  }

  @override
  Future<void> addStroke(String canvasId, DrawingStroke stroke) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    // Save current state for undo
    _undoHistory[canvasId]?.add(stroke);
    _redoHistory[canvasId]?.clear(); // Clear redo history when new action is added

    _canvases[canvasId] = canvas.addStroke(stroke);
  }

  @override
  Future<void> removeStroke(String canvasId, String strokeId) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    _canvases[canvasId] = canvas.removeStroke(strokeId);
  }

  @override
  Future<void> clearCanvas(String canvasId) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    _canvases[canvasId] = canvas.clearStrokes();
  }

  @override
  Future<bool> undoLastAction(String canvasId) async {
    final canvas = _canvases[canvasId];
    final undoHistory = _undoHistory[canvasId];

    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    if (undoHistory == null || undoHistory.isEmpty || canvas.strokes.isEmpty) {
      return false;
    }

    final lastStroke = canvas.strokes.last;
    _redoHistory[canvasId]?.add(lastStroke);
    undoHistory.removeLast();

    _canvases[canvasId] = canvas.removeStroke(lastStroke.id);
    return true;
  }

  @override
  Future<bool> redoLastAction(String canvasId) async {
    final canvas = _canvases[canvasId];
    final redoHistory = _redoHistory[canvasId];

    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    if (redoHistory == null || redoHistory.isEmpty) {
      return false;
    }

    final strokeToRedo = redoHistory.removeLast();
    _undoHistory[canvasId]?.add(strokeToRedo);

    _canvases[canvasId] = canvas.addStroke(strokeToRedo);
    return true;
  }

  @override
  Future<bool> canUndo(String canvasId) async {
    final canvas = _canvases[canvasId];
    return canvas != null && canvas.strokes.isNotEmpty;
  }

  @override
  Future<bool> canRedo(String canvasId) async {
    final redoHistory = _redoHistory[canvasId];
    return redoHistory != null && redoHistory.isNotEmpty;
  }

  @override
  DrawingTool getCurrentTool(String canvasId) {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }
    return canvas.currentTool;
  }

  @override
  Future<void> setCurrentTool(String canvasId, DrawingTool tool) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    _canvases[canvasId] = canvas.copyWith(currentTool: tool);
  }

  @override
  List<DrawingTool> getAvailableTools() {
    return DrawingTool.allTools;
  }

  @override
  Future<Uint8List> exportCanvasAsImage(String canvasId, {ImageFormat format = ImageFormat.png}) async {
    // TODO: Implement actual image export
    // This is a placeholder implementation
    throw UnimplementedError('Image export not yet implemented');
  }

  @override
  Future<String> exportCanvasAsJson(String canvasId) async {
    final canvas = _canvases[canvasId];
    if (canvas == null) {
      throw CanvasNotFoundException(canvasId);
    }

    // This would normally use json.encode, but for now return a simple string
    return canvas.toJson().toString();
  }

  // Real-time drawing operations
  @override
  void startStroke(Offset startPoint, double strokeWidth, Color color) {
    _currentStrokePoints.clear();
    _currentStrokePoints.add(startPoint);

    _currentStroke = DrawingStroke(
      id: 'stroke_${DateTime.now().millisecondsSinceEpoch}',
      tool: DrawingTool.pencil, // Default tool for now
      color: color,
      brushSize: strokeWidth,
      points: _currentStrokePoints,
    );
  }

  @override
  void addStrokePoint(Offset point) {
    if (_currentStroke != null) {
      _currentStrokePoints.add(point);
    }
  }

  @override
  void endStroke() {
    if (_currentStroke != null && _currentCanvasId != null) {
      final finalStroke = _currentStroke!.copyWith(points: List.from(_currentStrokePoints));
      addStroke(_currentCanvasId!, finalStroke);
    }
    _currentStroke = null;
    _currentStrokePoints.clear();
  }

  @override
  void undo() {
    if (_currentCanvasId != null) {
      undoLastAction(_currentCanvasId!);
    }
  }

  @override
  void redo() {
    if (_currentCanvasId != null) {
      redoLastAction(_currentCanvasId!);
    }
  }

  /// Set the current canvas for real-time operations
  void setCurrentCanvas(String canvasId) {
    _currentCanvasId = canvasId;
  }
}
