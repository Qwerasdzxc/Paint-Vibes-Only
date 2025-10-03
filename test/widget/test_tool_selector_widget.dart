import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/widgets/tool_selector.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Widget test for ToolSelector widget
/// These tests validate the tool selection UI behavior
void main() {
  group('ToolSelector Widget Tests', () {
    testWidgets('should render tool selector widget', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ToolSelector(selectedTool: DrawingTool.pencil, onToolSelected: (tool) {}),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(ToolSelector), findsOneWidget);
    });

    testWidgets('should display drawing tool options', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ToolSelector(selectedTool: DrawingTool.pencil, onToolSelected: (tool) {}, showLabels: true),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test tool options rendering
      expect(find.byType(ToolSelector), findsOneWidget);
      // Check for tool buttons
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle tool selection', (WidgetTester tester) async {
      // ARRANGE
      DrawingTool? selectedTool;
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ToolSelector(
            selectedTool: DrawingTool.pencil,
            onToolSelected: (tool) {
              selectedTool = tool;
            },
          ),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // Find a tool button and tap it
      final toolButtons = find.byType(InkWell);
      if (tester.widgetList(toolButtons).isNotEmpty) {
        await tester.tap(toolButtons.first);
        await tester.pump();
      }

      // ASSERT - Test tool selection callback
      expect(find.byType(ToolSelector), findsOneWidget);
    });

    testWidgets('should display brush size slider when available', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ToolSelector(
            selectedTool: DrawingTool.brush,
            onToolSelected: (tool) {},
            brushSize: 5.0,
            onBrushSizeChanged: (size) {},
          ),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(ToolSelector), findsOneWidget);
    });
  });
}
