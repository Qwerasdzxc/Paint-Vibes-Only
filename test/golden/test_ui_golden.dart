import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:painter/features/drawing/widgets/drawing_canvas.dart';
import 'package:painter/features/drawing/widgets/color_picker.dart';
import 'package:painter/features/drawing/widgets/tool_selector.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/shared/models/color_palette.dart';

/// Golden tests for UI consistency
/// Tests T055: Golden tests for UI consistency in test/golden/test_ui_golden.dart
void main() {
  group('Golden Tests - UI Consistency', () {
    testGoldens('drawing canvas should render consistently', (tester) async {
      // ARRANGE
      final canvas = DrawingCanvas.empty(id: 'golden-test-canvas', dimensions: const Size(400, 300))
          .addStroke(
            DrawingStroke(
              id: 'golden-stroke-1',
              tool: DrawingTool.pencil,
              color: Colors.blue,
              brushSize: 3.0,
              points: [const Offset(50, 50), const Offset(100, 75), const Offset(150, 50), const Offset(200, 100)],
            ),
          )
          .addStroke(
            DrawingStroke(
              id: 'golden-stroke-2',
              tool: DrawingTool.brush,
              color: Colors.red,
              brushSize: 8.0,
              points: [const Offset(250, 150), const Offset(300, 180), const Offset(350, 200)],
            ),
          );

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(width: 400, height: 300, child: DrawingCanvasWidget(canvasModel: canvas, enabled: true)),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'drawing_canvas_with_strokes');
    });

    testGoldens('color picker should render consistently', (tester) async {
      // ARRANGE
      final palette = ColorPalette.defaultPalette();

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 300,
              height: 400,
              child: ColorPicker(selectedColor: Colors.blue, onColorSelected: (_) {}, palette: palette),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'color_picker_default');
    });

    testGoldens('tool selector should render consistently', (tester) async {
      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 300,
              child: ToolSelector(
                selectedTool: DrawingTool.pencil,
                brushSize: 5.0,
                onToolSelected: (_) {},
                onBrushSizeChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'tool_selector_default');
    });

    testGoldens('empty drawing canvas should render consistently', (tester) async {
      // ARRANGE
      final emptyCanvas = DrawingCanvas.empty(
        id: 'empty-canvas',
        dimensions: const Size(300, 200),
        backgroundColor: Colors.white,
      );

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 300,
              height: 200,
              child: DrawingCanvasWidget(canvasModel: emptyCanvas, enabled: true, showGrid: true),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'empty_canvas_with_grid');
    });

    testGoldens('color picker with custom colors should render consistently', (tester) async {
      // ARRANGE
      final customPalette = ColorPalette(
        predefinedColors: [Colors.red, Colors.green, Colors.blue],
        customColors: [const Color(0xFF8E24AA), const Color(0xFF00ACC1)],
        recentColors: [Colors.orange, Colors.purple],
        currentColor: Colors.red,
        maxRecentColors: 10,
      );

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 300,
              height: 400,
              child: ColorPicker(
                selectedColor: const Color(0xFF8E24AA),
                onColorSelected: (_) {},
                palette: customPalette,
              ),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'color_picker_with_custom_colors');
    });

    testGoldens('tool selector with brush tool selected should render consistently', (tester) async {
      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 300,
              child: ToolSelector(
                selectedTool: DrawingTool.brush,
                brushSize: 12.0,
                onToolSelected: (_) {},
                onBrushSizeChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'tool_selector_brush_selected');
    });

    testGoldens('drawing canvas with multiple stroke types should render consistently', (tester) async {
      // ARRANGE
      final canvas =
          DrawingCanvas.empty(
                id: 'multi-stroke-canvas',
                dimensions: const Size(400, 300),
                backgroundColor: const Color(0xFFF5F5F5),
              )
              .addStroke(
                DrawingStroke(
                  id: 'pencil-stroke',
                  tool: DrawingTool.pencil,
                  color: Colors.black,
                  brushSize: 2.0,
                  points: List.generate(20, (i) => Offset(20.0 + i * 5, 50.0 + math.sin(i * 0.3) * 20)),
                ),
              )
              .addStroke(
                DrawingStroke(
                  id: 'brush-stroke',
                  tool: DrawingTool.brush,
                  color: Colors.blue.withOpacity(0.7),
                  brushSize: 10.0,
                  points: List.generate(15, (i) => Offset(50.0 + i * 8, 150.0 + math.cos(i * 0.4) * 30)),
                ),
              )
              .addStroke(
                DrawingStroke(
                  id: 'eraser-stroke',
                  tool: DrawingTool.eraser,
                  color: Colors.transparent,
                  brushSize: 15.0,
                  points: [const Offset(200, 100), const Offset(220, 110), const Offset(240, 120)],
                ),
              );

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(width: 400, height: 300, child: DrawingCanvasWidget(canvasModel: canvas, enabled: true)),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'multi_stroke_canvas');
    });

    testGoldens('color picker in dark theme should render consistently', (tester) async {
      // ARRANGE
      final palette = ColorPalette.defaultPalette();

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Container(
              width: 300,
              height: 400,
              child: ColorPicker(selectedColor: Colors.cyan, onColorSelected: (_) {}, palette: palette),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'color_picker_dark_theme');
    });

    testGoldens('tool selector in compact mode should render consistently', (tester) async {
      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 150,
              height: 200,
              child: ToolSelector(
                selectedTool: DrawingTool.eraser,
                brushSize: 8.0,
                onToolSelected: (_) {},
                onBrushSizeChanged: (_) {},
                toolSize: 32.0, // Smaller for compact mode
              ),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'tool_selector_compact');
    });

    testGoldens('drawing canvas with background color should render consistently', (tester) async {
      // ARRANGE
      final coloredCanvas = DrawingCanvas.empty(
        id: 'colored-bg-canvas',
        dimensions: const Size(300, 200),
        backgroundColor: Colors.lightBlue[50]!,
      );

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 300,
              height: 200,
              child: DrawingCanvasWidget(canvasModel: coloredCanvas, enabled: true),
            ),
          ),
        ),
      );

      // ASSERT
      await screenMatchesGolden(tester, 'canvas_with_background_color');
    });
  });
}
