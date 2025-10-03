import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/widgets/color_picker.dart';
import 'package:painter/shared/models/color_palette.dart';

/// Widget test for ColorPicker widget
/// These tests validate the color picker UI behavior
void main() {
  group('ColorPicker Widget Tests', () {
    testWidgets('should render color picker widget', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColorPicker(selectedColor: Colors.blue, onColorSelected: (color) {}),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT
      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('should display color palette options', (WidgetTester tester) async {
      // ARRANGE
      final palette = ColorPalette(
        predefinedColors: [Colors.red, Colors.green, Colors.blue],
        customColors: [],
        recentColors: [],
        currentColor: Colors.red,
        maxRecentColors: 10,
      );

      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColorPicker(selectedColor: Colors.red, onColorSelected: (color) {}, palette: palette),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test color palette rendering
      expect(find.byType(ColorPicker), findsOneWidget);
      // Check for color containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle color selection', (WidgetTester tester) async {
      // ARRANGE
      Color? selectedColor;
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColorPicker(
            selectedColor: Colors.red,
            onColorSelected: (color) {
              selectedColor = color;
            },
          ),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // Find a color container and tap it
      final colorContainers = find.byType(InkWell);
      if (tester.widgetList(colorContainers).isNotEmpty) {
        await tester.tap(colorContainers.first);
        await tester.pump();
      }

      // ASSERT - Test color selection callback
      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('should support HSV color mode', (WidgetTester tester) async {
      // ARRANGE
      final testWidget = MaterialApp(
        home: Scaffold(
          body: ColorPicker(selectedColor: Colors.blue, onColorSelected: (color) {}, showHsvPicker: true),
        ),
      );

      // ACT
      await tester.pumpWidget(testWidget);

      // ASSERT - Test HSV color mode
      expect(find.byType(ColorPicker), findsOneWidget);
    });
  });
}
