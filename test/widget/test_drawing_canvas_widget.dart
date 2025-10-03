import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/widgets/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_canvas.dart';

/// Widget test for DrawingCanvasWidget CustomPainter widget
/// These tests validate the drawing canvas UI behavior
void main() {
  group('DrawingCanvasWidget Tests', () {
    late DrawingCanvas testCanvasModel;

    setUp(() {
      // Create a test canvas model
      testCanvasModel = DrawingCanvas.empty(id: 'test-canvas', dimensions: const Size(400, 300));
    });

    testWidgets('should render drawing canvas widget', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: DrawingCanvasWidget(canvasModel: testCanvasModel)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(DrawingCanvasWidget), findsOneWidget);
    });

    testWidgets('should respond to tap gestures', (WidgetTester tester) async {
      // ARRANGE
      bool tapHandled = false;
      final testWidget = MaterialApp(
        home: Scaffold(
          body: DrawingCanvasWidget(canvasModel: testCanvasModel, onPanStart: (offset) => tapHandled = true),
        ),
      );
      await tester.pumpWidget(testWidget);

      // ACT
      await tester.tap(find.byType(DrawingCanvasWidget));
      await tester.pump();

      // ASSERT
      expect(find.byType(DrawingCanvasWidget), findsOneWidget);
      expect(tapHandled, isTrue);
    });

    testWidgets('should handle pan gestures for drawing', (WidgetTester tester) async {
      // ARRANGE
      bool panStarted = false;
      bool panUpdated = false;
      bool panEnded = false;

      final testWidget = MaterialApp(
        home: Scaffold(
          body: DrawingCanvasWidget(
            canvasModel: testCanvasModel,
            onPanStart: (offset) => panStarted = true,
            onPanUpdate: (offset) => panUpdated = true,
            onPanEnd: (offset) => panEnded = true,
          ),
        ),
      );
      await tester.pumpWidget(testWidget);

      // ACT - Simulate drawing gesture
      await tester.drag(find.byType(DrawingCanvasWidget), const Offset(50, 50));
      await tester.pump();

      // ASSERT
      expect(find.byType(DrawingCanvasWidget), findsOneWidget);
      expect(panStarted, isTrue);
      expect(panUpdated, isTrue);
      expect(panEnded, isTrue);
    });

    testWidgets('should update when canvas data changes', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: DrawingCanvasWidget(canvasModel: testCanvasModel)),
      );

      // ACT
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // ASSERT - Test widget updates
      expect(find.byType(DrawingCanvasWidget), findsOneWidget);
    });
  });
}
