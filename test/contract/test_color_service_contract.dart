import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/features/drawing/services/i_color_service.dart';
import 'package:painter/features/drawing/services/color_service.dart';

/// Contract test for IColorService interface
/// These tests define the behavior contract that any ColorService implementation must follow
void main() {
  group('IColorService Contract Tests', () {
    late IColorService colorService;

    setUp(() {
      colorService = ColorService();
    });

    test('should return predefined colors', () async {
      // ACT
      final predefinedColors = await colorService.getPredefinedColors();

      // ASSERT
      expect(predefinedColors, isNotEmpty);
      expect(predefinedColors, contains(Colors.black));
      expect(predefinedColors, contains(Colors.white));
      expect(predefinedColors, contains(Colors.red));
    });

    test('should manage custom colors', () async {
      // ARRANGE
      const customColor = Color(0xFF123456);

      // ACT
      await colorService.addCustomColor(customColor);
      final customColors = await colorService.getCustomColors();

      // ASSERT
      expect(customColors, contains(customColor));
    });

    test('should not add duplicate custom colors', () async {
      // ARRANGE
      const customColor = Color(0xFF123456);

      // ACT
      await colorService.addCustomColor(customColor);
      await colorService.addCustomColor(customColor); // Add same color again
      final customColors = await colorService.getCustomColors();

      // ASSERT
      expect(customColors.where((c) => c == customColor).length, equals(1));
    });

    test('should remove custom colors', () async {
      // ARRANGE
      const customColor = Color(0xFF123456);
      await colorService.addCustomColor(customColor);

      // ACT
      await colorService.removeCustomColor(customColor);
      final customColors = await colorService.getCustomColors();

      // ASSERT
      expect(customColors, isNot(contains(customColor)));
    });

    test('should manage recent colors', () async {
      // ARRANGE
      const color1 = Colors.red;
      const color2 = Colors.blue;

      // ACT
      await colorService.addToRecentColors(color1);
      await colorService.addToRecentColors(color2);
      final recentColors = await colorService.getRecentColors();

      // ASSERT
      expect(recentColors, isNotEmpty);
      expect(recentColors.first, equals(color2)); // Most recent should be first
      expect(recentColors, contains(color1));
    });

    test('should clear recent colors', () async {
      // ARRANGE
      await colorService.addToRecentColors(Colors.red);
      await colorService.addToRecentColors(Colors.blue);

      // ACT
      await colorService.clearRecentColors();
      final recentColors = await colorService.getRecentColors();

      // ASSERT
      expect(recentColors, isEmpty);
    });

    test('should manage current color', () async {
      // ARRANGE
      const newColor = Colors.green;

      // ACT
      final initialColor = colorService.getCurrentColor();
      await colorService.setCurrentColor(newColor);
      final updatedColor = colorService.getCurrentColor();

      // ASSERT
      expect(initialColor, equals(Colors.black)); // Default color
      expect(updatedColor, equals(newColor));
    });

    test('should add current color to recent colors when set', () async {
      // ARRANGE
      const newColor = Colors.purple;

      // ACT
      await colorService.setCurrentColor(newColor);
      final recentColors = await colorService.getRecentColors();

      // ASSERT
      expect(recentColors, contains(newColor));
      expect(recentColors.first, equals(newColor));
    });

    test('should convert color to HSV', () {
      // ARRANGE
      const color = Color(0xFFFF0000); // Pure red

      // ACT
      final hsv = colorService.colorToHSV(color);

      // ASSERT
      expect(hsv, isA<HSVColor>());
      expect(hsv.hue, closeTo(0.0, 1.0)); // Red has hue around 0
      expect(hsv.saturation, equals(1.0));
      expect(hsv.value, equals(1.0));
    });

    test('should convert HSV to color', () {
      // ARRANGE
      const hsv = HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0); // Pure green

      // ACT
      final color = colorService.hsvToColor(hsv);

      // ASSERT
      expect(color, isA<Color>());
      expect(color.red, equals(0));
      expect(color.green, equals(255));
      expect(color.blue, equals(0));
    });

    test('should convert color to hex string', () {
      // ARRANGE
      const color = Color(0xFFFF0000); // Pure red

      // ACT
      final hex = colorService.colorToHex(color);

      // ASSERT
      expect(hex, isA<String>());
      expect(hex, startsWith('#'));
      expect(hex.length, equals(7)); // #RRGGBB format
      expect(hex.toUpperCase(), equals('#FF0000'));
    });

    test('should convert hex string to color', () {
      // ARRANGE
      const hexString = '#FF0000';

      // ACT
      final color = colorService.hexToColor(hexString);

      // ASSERT
      expect(color, isA<Color>());
      expect(color.red, equals(255));
      expect(color.green, equals(0));
      expect(color.blue, equals(0));
    });

    test('should handle hex string without hash prefix', () {
      // ARRANGE
      const hexString = 'FF0000';

      // ACT
      final color = colorService.hexToColor(hexString);

      // ASSERT
      expect(color.red, equals(255));
      expect(color.green, equals(0));
      expect(color.blue, equals(0));
    });

    test('should return null for color picking from canvas (not implemented)', () async {
      // ARRANGE
      const canvasId = 'test_canvas';
      const position = Offset(100, 100);

      // ACT
      final pickedColor = await colorService.pickColorFromCanvas(canvasId, position);

      // ASSERT
      expect(pickedColor, isNull);
    });
  });
}
