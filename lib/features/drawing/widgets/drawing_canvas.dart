import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';

/// Interactive drawing canvas widget with CustomPainter implementation
class DrawingCanvasWidget extends StatefulWidget {
  final DrawingCanvas canvasModel;
  final DrawingStroke? currentStroke;
  final Function(Offset)? onPanStart;
  final Function(Offset)? onPanUpdate;
  final Function(Offset)? onPanEnd;
  final bool enabled;
  final bool showGrid;

  const DrawingCanvasWidget({
    super.key,
    required this.canvasModel,
    this.currentStroke,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.enabled = true,
    this.showGrid = false,
  });

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.enabled
          ? (details) {
              widget.onPanStart?.call(details.localPosition);
            }
          : null,
      onPanUpdate: widget.enabled
          ? (details) {
              widget.onPanUpdate?.call(details.localPosition);
            }
          : null,
      onPanEnd: widget.enabled
          ? (details) {
              widget.onPanEnd?.call(details.localPosition);
            }
          : null,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: DrawingCanvasPainter(
            canvasModel: widget.canvasModel,
            currentStroke: widget.currentStroke,
            showGrid: widget.showGrid,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// CustomPainter implementation for rendering the drawing canvas
/// Implements multi-layer rendering: Background → Strokes → UI overlay
class DrawingCanvasPainter extends CustomPainter {
  final DrawingCanvas canvasModel;
  final DrawingStroke? currentStroke;
  final bool showGrid;

  DrawingCanvasPainter({required this.canvasModel, this.currentStroke, this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Step 1: Draw background layer
    _drawBackground(canvas, size);

    // Step 2: Draw all completed strokes
    _drawStrokes(canvas, size);

    // Step 3: Draw current stroke (if any)
    _drawCurrentStroke(canvas, size);

    // Step 4: Draw UI overlay (grid, guides, etc.)
    _drawUIOverlay(canvas, size);
  }

  /// Draw the canvas background
  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = canvasModel.backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  /// Draw all completed strokes from the canvas model
  void _drawStrokes(Canvas canvas, Size size) {
    for (final stroke in canvasModel.strokes) {
      _drawSingleStroke(canvas, stroke);
    }
  }

  /// Draw the current stroke being drawn (if any)
  void _drawCurrentStroke(Canvas canvas, Size size) {
    if (currentStroke != null) {
      _drawSingleStroke(canvas, currentStroke!);
    }
  }

  /// Draw a single stroke with optimized rendering and smooth curves
  void _drawSingleStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.brushSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = stroke.blendMode;

    // Apply opacity if specified
    if (stroke.opacity < 1.0) {
      paint.color = paint.color.withOpacity(stroke.opacity);
    }

    if (stroke.points.length == 1) {
      // Draw a single point as a circle
      canvas.drawCircle(stroke.points.first, stroke.brushSize / 2, paint..style = PaintingStyle.fill);
    } else {
      // Draw connected path for multiple points with smooth curves
      final path = _createSmoothPath(stroke.points);
      canvas.drawPath(path, paint);
    }
  }

  /// Create a smooth path from stroke points using quadratic curves
  Path _createSmoothPath(List<Offset> points) {
    final path = Path();

    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      // Simple line for two points
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    // Use quadratic curves for smoother strokes
    for (int i = 1; i < points.length - 1; i++) {
      final currentPoint = points[i];
      final nextPoint = points[i + 1];

      final controlPoint = Offset((currentPoint.dx + nextPoint.dx) / 2, (currentPoint.dy + nextPoint.dy) / 2);

      path.quadraticBezierTo(currentPoint.dx, currentPoint.dy, controlPoint.dx, controlPoint.dy);
    }

    // Connect to the last point
    path.lineTo(points.last.dx, points.last.dy);

    return path;
  }

  /// Draw UI overlay elements (grid, rulers, guides, etc.)
  void _drawUIOverlay(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // TODO: Add more overlay features as needed
    // - Rulers if enabled
    // - Guides or snap lines
    // - Selection indicators
    // - Transform handles
  }

  /// Draw grid lines on the canvas
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridSpacing = 20.0; // 20 pixel grid

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingCanvasPainter oldDelegate) {
    // Smart repaint logic - only repaint when necessary
    return canvasModel != oldDelegate.canvasModel ||
        currentStroke != oldDelegate.currentStroke ||
        showGrid != oldDelegate.showGrid ||
        canvasModel.lastModified != oldDelegate.canvasModel.lastModified ||
        canvasModel.strokes.length != oldDelegate.canvasModel.strokes.length;
  }

  /// Check if a stroke contains a given point within tolerance
  bool strokeContainsPoint(DrawingStroke stroke, Offset point, double tolerance) {
    final hitRadius = tolerance + stroke.brushSize / 2;

    for (final strokePoint in stroke.points) {
      final distance = (strokePoint - point).distance;
      if (distance <= hitRadius) {
        return true;
      }
    }
    return false;
  }

  /// Get the bounding box of the entire canvas content
  Rect getContentBounds() {
    if (canvasModel.strokes.isEmpty) {
      return Rect.zero;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in canvasModel.strokes) {
      for (final point in stroke.points) {
        final strokeRadius = stroke.brushSize / 2;
        minX = minX < point.dx - strokeRadius ? minX : point.dx - strokeRadius;
        minY = minY < point.dy - strokeRadius ? minY : point.dy - strokeRadius;
        maxX = maxX > point.dx + strokeRadius ? maxX : point.dx + strokeRadius;
        maxY = maxY > point.dy + strokeRadius ? maxY : point.dy + strokeRadius;
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Get stroke at a specific point (for selection)
  DrawingStroke? getStrokeAtPoint(Offset point, double tolerance) {
    // Search in reverse order to get topmost stroke
    for (int i = canvasModel.strokes.length - 1; i >= 0; i--) {
      final stroke = canvasModel.strokes[i];
      if (strokeContainsPoint(stroke, point, tolerance)) {
        return stroke;
      }
    }
    return null;
  }
}
