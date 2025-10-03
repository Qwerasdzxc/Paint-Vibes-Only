import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Abstract interface for drawing service
/// Defines all drawing-related operations and canvas management
abstract class IDrawingService {
  // Canvas Management
  Future<DrawingCanvas> createCanvas(Size dimensions, {Color? backgroundColor});
  Future<DrawingCanvas> loadCanvas(String canvasId);
  Future<void> saveCanvas(DrawingCanvas canvas);
  Future<bool> deleteCanvas(String canvasId);

  // Drawing Operations
  Future<void> addStroke(String canvasId, DrawingStroke stroke);
  Future<void> removeStroke(String canvasId, String strokeId);
  Future<void> clearCanvas(String canvasId);

  // Undo/Redo
  Future<bool> undoLastAction(String canvasId);
  Future<bool> redoLastAction(String canvasId);
  Future<bool> canUndo(String canvasId);
  Future<bool> canRedo(String canvasId);

  // Tool Management
  DrawingTool getCurrentTool(String canvasId);
  Future<void> setCurrentTool(String canvasId, DrawingTool tool);
  List<DrawingTool> getAvailableTools();

  // Export
  Future<Uint8List> exportCanvasAsImage(String canvasId, {ImageFormat format = ImageFormat.png});
  Future<String> exportCanvasAsJson(String canvasId);

  // Stroke Operations (for real-time drawing)
  void startStroke(Offset startPoint, double strokeWidth, Color color);
  void addStrokePoint(Offset point);
  void endStroke();
  void undo();
  void redo();
}

/// Image export formats
enum ImageFormat { png, jpg, svg, pdf }

/// Custom exceptions for drawing operations
class CanvasNotFoundException implements Exception {
  final String canvasId;
  CanvasNotFoundException(this.canvasId);

  @override
  String toString() => 'Canvas not found: $canvasId';
}

class InvalidDrawingOperationException implements Exception {
  final String operation;
  final String reason;
  InvalidDrawingOperationException(this.operation, this.reason);

  @override
  String toString() => 'Invalid drawing operation $operation: $reason';
}

class StorageException implements Exception {
  final String operation;
  final String details;
  StorageException(this.operation, this.details);

  @override
  String toString() => 'Storage error during $operation: $details';
}
