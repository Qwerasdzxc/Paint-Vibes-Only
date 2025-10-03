import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/shared/models/color_palette.dart';
import 'package:painter/features/drawing/widgets/interactive_drawing_canvas.dart';
import 'package:painter/features/drawing/widgets/tool_selector.dart';
import 'package:painter/features/drawing/widgets/color_picker.dart';

/// Main drawing screen with canvas and controls
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingStroke> _strokes = [];
  List<DrawingStroke> _undoStack = [];

  DrawingTool _currentTool = DrawingTool.pencil;
  Color _currentColor = Colors.black;
  double _currentBrushSize = 5.0;
  ColorPalette _colorPalette = ColorPalette.defaultPalette();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Vibes Only'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _canUndo() ? _undo : null, icon: const Icon(Icons.undo)),
          IconButton(onPressed: _canRedo() ? _redo : null, icon: const Icon(Icons.redo)),
          IconButton(onPressed: _clearCanvas, icon: const Icon(Icons.clear_all)),
        ],
      ),
      body: Column(
        children: [
          // Tool bar
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ToolSelector(
                    selectedTool: _currentTool,
                    onToolSelected: (tool) {
                      setState(() {
                        _currentTool = tool;
                        _currentBrushSize = tool.defaultSize;
                      });
                    },
                    brushSize: _currentBrushSize,
                    onBrushSizeChanged: (size) {
                      setState(() {
                        _currentBrushSize = size;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 200,
                  child: ColorPicker(
                    selectedColor: _currentColor,
                    onColorSelected: (color) {
                      setState(() {
                        _currentColor = color;
                      });
                    },
                    palette: _colorPalette,
                    onPaletteUpdated: (palette) {
                      setState(() {
                        _colorPalette = palette;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Drawing canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveDrawingCanvas(
                  strokes: _strokes,
                  currentTool: _currentTool,
                  currentColor: _currentColor,
                  currentBrushSize: _currentBrushSize,
                  onStrokeCompleted: _addStroke,
                ),
              ),
            ),
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tool: ${_currentTool.name}', style: Theme.of(context).textTheme.bodySmall),
                Text('Strokes: ${_strokes.length}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addStroke(DrawingStroke stroke) {
    setState(() {
      _strokes.add(stroke);
      _undoStack.clear(); // Clear redo stack when new stroke is added
    });
  }

  bool _canUndo() {
    return _strokes.isNotEmpty;
  }

  bool _canRedo() {
    return _undoStack.isNotEmpty;
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        final lastStroke = _strokes.removeLast();
        _undoStack.add(lastStroke);
      });
    }
  }

  void _redo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        final redoStroke = _undoStack.removeLast();
        _strokes.add(redoStroke);
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear all drawings?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _strokes.clear();
                _undoStack.clear();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
