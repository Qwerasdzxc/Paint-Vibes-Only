import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/coloring/widgets/coloring_page_widget.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';

/// Widget test for ColoringPageWidget
/// These tests validate the coloring page UI behavior
void main() {
  group('ColoringPageWidget Tests', () {
    late ColoringPage testColoringPage;
    late ColoringProgress testProgress;

    setUp(() {
      testColoringPage = ColoringPage(
        id: 'test_page',
        title: 'Test Coloring Page',
        description: 'A test coloring page',
        category: 'Test',
        outlinePath: 'assets/test_outline.svg',
        thumbnailPath: 'assets/test_thumb.png',
        difficulty: Difficulty.easy,
        suggestedColors: ['#FF0000', '#00FF00', '#0000FF'],
        isUnlocked: true,
        completionCount: 0,
      );

      testProgress = ColoringProgress(
        id: 'test_progress',
        coloringPageId: 'test_page',
        userId: 'test_user',
        progressImagePath: 'assets/test_progress.png',
        canvasDataPath: 'data/test_progress.json',
        completionPercent: 0.5,
        startedAt: DateTime.now(),
        lastWorkedOn: DateTime.now(),
        isCompleted: false,
        totalTimeSpent: const Duration(minutes: 30),
      );
    });

    testWidgets('should render coloring page widget', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: ColoringPageWidget(coloringPage: testColoringPage)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(ColoringPageWidget), findsOneWidget);
    });

    testWidgets('should display coloring page outline', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(body: ColoringPageWidget(coloringPage: testColoringPage)),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test outline rendering
      expect(find.byType(ColoringPageWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle color fill interactions', (WidgetTester tester) async {
      // ARRANGE
      Offset? tappedOffset;
      Color? appliedColor;

      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColoringPageWidget(
            coloringPage: testColoringPage,
            currentColor: Colors.red,
            onColorApplied: (offset, color) {
              tappedOffset = offset;
              appliedColor = color;
            },
          ),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // ASSERT - Test color fill behavior
      expect(find.byType(ColoringPageWidget), findsOneWidget);
      expect(tappedOffset, isNotNull);
      expect(appliedColor, equals(Colors.red));
    });

    testWidgets('should track coloring progress', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColoringPageWidget(coloringPage: testColoringPage, progress: testProgress),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // ASSERT - Test progress tracking
      expect(find.byType(ColoringPageWidget), findsOneWidget);
      expect(find.text('50%'), findsOneWidget); // Progress indicator
    });

    testWidgets('should show empty state when no coloring page', (WidgetTester tester) async {
      // ARRANGE
      const testWidget = MaterialApp(home: Scaffold(body: ColoringPageWidget()));

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(ColoringPageWidget), findsOneWidget);
      expect(find.text('No coloring page loaded'), findsOneWidget);
    });
  });
}
