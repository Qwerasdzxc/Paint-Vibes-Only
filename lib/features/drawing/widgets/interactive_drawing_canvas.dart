import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/features/drawing/widgets/drawing_canvas.dart';

/// Interactive drawing canvas that handles user input and integrates with drawing model
class InteractiveDrawingCanvas extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentBrushSize;
  final Function(DrawingStroke) onStrokeCompleted;
  final bool enabled;

  const InteractiveDrawingCanvas({
    super.key,
    required this.strokes,
    required this.currentTool,
    required this.currentColor,
    required this.currentBrushSize,
    required this.onStrokeCompleted,
    this.enabled = true,
  });

  @override
  State<InteractiveDrawingCanvas> createState() => _InteractiveDrawingCanvasState();
}

class _InteractiveDrawingCanvasState extends State<InteractiveDrawingCanvas> {
  DrawingStroke? _currentStroke;

  // Create a drawing canvas model for rendering
  DrawingCanvas get _canvasModel {
    return DrawingCanvas.empty(id: 'drawing-canvas', dimensions: const Size(800, 600)).copyWith(
      strokes: widget.strokes,
      currentTool: widget.currentTool,
      currentColor: widget.currentColor,
      currentBrushSize: widget.currentBrushSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawingCanvasWidget(
      canvasModel: _canvasModel,
      currentStroke: _currentStroke,
      enabled: widget.enabled,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
    );
  }

  void _onPanStart(Offset position) {
    if (!widget.enabled) return;

    setState(() {
      _currentStroke = DrawingStroke(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tool: widget.currentTool,
        points: [position],
        color: widget.currentColor,
        brushSize: widget.currentBrushSize,
        blendMode: widget.currentTool.blendMode,
        opacity: 1.0,
      );
    });
  }

  void _onPanUpdate(Offset position) {
    if (!widget.enabled || _currentStroke == null) return;

    setState(() {
      _currentStroke = _currentStroke!.copyWith(points: [..._currentStroke!.points, position]);
    });
  }

  void _onPanEnd(Offset position) {
    if (!widget.enabled || _currentStroke == null) return;

    final completedStroke = _currentStroke!.copyWith(points: [..._currentStroke!.points, position]);

    widget.onStrokeCompleted(completedStroke);

    setState(() {
      _currentStroke = null;
    });
  }
}
