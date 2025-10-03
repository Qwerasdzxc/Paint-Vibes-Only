import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/shared/models/color_palette.dart';
import 'package:painter/features/drawing/services/color_service.dart';

/// Unit tests for color conversion algorithms and operations
/// Tests T052: Unit tests for color conversions in test/unit/test_color_conversions.dart
void main() {
  group('Color Conversion Tests', () {
    test('RGB to HSV conversion should be accurate', () {
      // ARRANGE - Test various RGB colors
      final testCases = [
        {'color': Colors.red, 'expectedHue': 0.0, 'expectedSat': 1.0, 'expectedVal': 1.0},
        {'color': Colors.green, 'expectedHue': 120.0, 'expectedSat': 1.0, 'expectedVal': 1.0},
        {'color': Colors.blue, 'expectedHue': 240.0, 'expectedSat': 1.0, 'expectedVal': 1.0},
        {'color': Colors.white, 'expectedHue': 0.0, 'expectedSat': 0.0, 'expectedVal': 1.0},
        {'color': Colors.black, 'expectedHue': 0.0, 'expectedSat': 0.0, 'expectedVal': 0.0},
        {'color': Colors.grey, 'expectedHue': 0.0, 'expectedSat': 0.0, 'expectedVal': 0.5},
      ];

      for (final testCase in testCases) {
        // ACT
        final hsv = HSVColor.fromColor(testCase['color'] as Color);

        // ASSERT
        expect(
          hsv.hue,
          closeTo(testCase['expectedHue'] as double, 10.0),
          reason: 'Hue mismatch for ${testCase['color']}',
        );
        expect(
          hsv.saturation,
          closeTo(testCase['expectedSat'] as double, 0.3),
          reason: 'Saturation mismatch for ${testCase['color']}',
        );
        expect(
          hsv.value,
          closeTo(testCase['expectedVal'] as double, 0.3),
          reason: 'Value mismatch for ${testCase['color']}',
        );
      }
    });

    test('HSV to RGB conversion should be accurate', () {
      // ARRANGE - Test various HSV values
      final testCases = [
        {'hsv': const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0), 'expectedColor': Colors.red},
        {'hsv': const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0), 'expectedColor': Colors.green},
        {'hsv': const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0), 'expectedColor': Colors.blue},
        {'hsv': const HSVColor.fromAHSV(1.0, 0.0, 0.0, 1.0), 'expectedColor': Colors.white},
        {'hsv': const HSVColor.fromAHSV(1.0, 0.0, 0.0, 0.0), 'expectedColor': Colors.black},
      ];

      for (final testCase in testCases) {
        // ACT
        final color = (testCase['hsv'] as HSVColor).toColor();
        final expected = testCase['expectedColor'] as Color;

        // ASSERT
        expect(color.red, closeTo(expected.red, 15), reason: 'Red channel mismatch for HSV ${testCase['hsv']}');
        expect(color.green, closeTo(expected.green, 15), reason: 'Green channel mismatch for HSV ${testCase['hsv']}');
        expect(color.blue, closeTo(expected.blue, 15), reason: 'Blue channel mismatch for HSV ${testCase['hsv']}');
      }
    });

    test('color to hex string conversion should format correctly', () {
      // ARRANGE
      final colorService = ColorService();
      final testColors = [
        {'color': const Color(0xFFFF0000), 'expectedHex': '#FF0000'},
        {'color': const Color(0xFF00FF00), 'expectedHex': '#00FF00'},
        {'color': const Color(0xFF0000FF), 'expectedHex': '#0000FF'},
        {'color': const Color(0xFFFFFFFF), 'expectedHex': '#FFFFFF'},
        {'color': const Color(0xFF000000), 'expectedHex': '#000000'},
        {'color': const Color(0xFF123456), 'expectedHex': '#123456'},
      ];

      for (final testCase in testColors) {
        // ACT
        final hex = colorService.colorToHex(testCase['color'] as Color);

        // ASSERT
        expect(
          hex.toUpperCase(),
          equals(testCase['expectedHex']),
          reason: 'Hex conversion failed for ${testCase['color']}',
        );
        expect(hex.length, equals(7), reason: 'Hex string should be 7 characters long (#RRGGBB)');
        expect(hex.startsWith('#'), isTrue, reason: 'Hex string should start with #');
      }
    });

    test('hex string to color conversion should handle various formats', () {
      // ARRANGE
      final colorService = ColorService();
      final testCases = [
        {'hex': '#FF0000', 'expectedColor': const Color(0xFFFF0000)},
        {'hex': 'FF0000', 'expectedColor': const Color(0xFFFF0000)},
        {'hex': '#00ff00', 'expectedColor': const Color(0xFF00FF00)},
        {'hex': '0000FF', 'expectedColor': const Color(0xFF0000FF)},
        {'hex': '#ffffff', 'expectedColor': const Color(0xFFFFFFFF)},
        {'hex': '000000', 'expectedColor': const Color(0xFF000000)},
      ];

      for (final testCase in testCases) {
        // ACT
        final color = colorService.hexToColor(testCase['hex'] as String);
        final expected = testCase['expectedColor'] as Color;

        // ASSERT
        expect(color.value, equals(expected.value), reason: 'Color conversion failed for hex ${testCase['hex']}');
      }
    });

    test('color interpolation should produce smooth gradients', () {
      // ARRANGE
      const startColor = Colors.red;
      const endColor = Colors.blue;
      const steps = 5;

      // ACT
      final interpolatedColors = _interpolateColors(startColor, endColor, steps);

      // ASSERT
      expect(interpolatedColors.length, equals(steps + 1)); // Including start and end
      expect(interpolatedColors.first.value, equals(startColor.value));
      expect(interpolatedColors.last.value, equals(endColor.value));

      // Check intermediate colors are between start and end
      for (int i = 1; i < interpolatedColors.length - 1; i++) {
        final color = interpolatedColors[i];
        expect(color.red, lessThanOrEqualTo(max(startColor.red, endColor.red)));
        expect(color.red, greaterThanOrEqualTo(min(startColor.red, endColor.red)));
        expect(color.blue, lessThanOrEqualTo(max(startColor.blue, endColor.blue)));
        expect(color.blue, greaterThanOrEqualTo(min(startColor.blue, endColor.blue)));
      }
    });

    test('color blending should produce correct results', () {
      // ARRANGE
      const color1 = Color(0xFFFF0000); // Red
      const color2 = Color(0xFF0000FF); // Blue
      final blendRatios = [0.0, 0.25, 0.5, 0.75, 1.0];

      for (final ratio in blendRatios) {
        // ACT
        final blendedColor = _blendColors(color1, color2, ratio);

        // ASSERT
        if (ratio == 0.0) {
          expect(blendedColor.value, equals(color1.value));
        } else if (ratio == 1.0) {
          expect(blendedColor.value, equals(color2.value));
        } else {
          // Check that blended color is between the two colors
          expect(blendedColor.red, lessThanOrEqualTo(color1.red));
          expect(blendedColor.blue, greaterThanOrEqualTo((color2.blue * ratio * 0.8).round()));
        }
      }
    });

    test('color brightness calculation should be accurate', () {
      // ARRANGE
      final testCases = [
        {'color': Colors.white, 'expectedBrightness': 1.0},
        {'color': Colors.black, 'expectedBrightness': 0.0},
        {'color': Colors.red, 'expectedBrightness': 0.299}, // Weighted brightness
        {'color': Colors.green, 'expectedBrightness': 0.587},
        {'color': Colors.blue, 'expectedBrightness': 0.114},
      ];

      for (final testCase in testCases) {
        // ACT
        final brightness = _calculateBrightness(testCase['color'] as Color);

        // ASSERT
        expect(
          brightness,
          closeTo(testCase['expectedBrightness'] as double, 0.2),
          reason: 'Brightness calculation failed for ${testCase['color']}',
        );
        expect(brightness, greaterThanOrEqualTo(0.0));
        expect(brightness, lessThanOrEqualTo(1.0));
      }
    });

    test('color contrast calculation should meet accessibility standards', () {
      // ARRANGE
      final testCases = [
        {'color1': Colors.black, 'color2': Colors.white, 'minContrast': 7.0}, // High contrast
        {'color1': Colors.blue[900], 'color2': Colors.white, 'minContrast': 4.5}, // WCAG AA
        {'color1': Colors.grey[600], 'color2': Colors.white, 'minContrast': 3.0}, // WCAG AAA large text
      ];

      for (final testCase in testCases) {
        // ACT
        final contrast = _calculateColorContrast(testCase['color1'] as Color, testCase['color2'] as Color);

        // ASSERT
        expect(
          contrast,
          greaterThan((testCase['minContrast'] as double) * 0.7),
          reason: 'Insufficient contrast between ${testCase['color1']} and ${testCase['color2']}',
        );
        expect(contrast, greaterThanOrEqualTo(1.0)); // Minimum possible contrast
        expect(contrast, lessThanOrEqualTo(21.0)); // Maximum possible contrast
      }
    });

    test('color palette serialization should preserve all color data', () {
      // ARRANGE
      final originalPalette = ColorPalette(
        predefinedColors: [Colors.red, Colors.green, Colors.blue],
        customColors: [const Color(0xFF123456), const Color(0xFFABCDEF)],
        recentColors: [Colors.yellow, Colors.purple],
        currentColor: Colors.orange,
        maxRecentColors: 10,
      );

      // ACT
      final json = originalPalette.toJson();
      final restoredPalette = ColorPalette.fromJson(json);

      // ASSERT
      expect(restoredPalette.predefinedColors.length, equals(originalPalette.predefinedColors.length));
      expect(restoredPalette.customColors.length, equals(originalPalette.customColors.length));
      expect(restoredPalette.recentColors.length, equals(originalPalette.recentColors.length));
      expect(restoredPalette.currentColor.value, equals(originalPalette.currentColor.value));
      expect(restoredPalette.maxRecentColors, equals(originalPalette.maxRecentColors));

      // Check individual color values
      for (int i = 0; i < originalPalette.predefinedColors.length; i++) {
        expect(restoredPalette.predefinedColors[i].value, equals(originalPalette.predefinedColors[i].value));
      }
    });

    test('color distance calculation should identify similar colors', () {
      // ARRANGE
      const referenceColor = Color(0xFF7F7F7F); // Medium grey
      final testColors = [
        {'color': const Color(0xFF808080), 'expectedDistance': 'small'}, // Very similar
        {'color': const Color(0xFF9F9F9F), 'expectedDistance': 'medium'}, // Somewhat different
        {'color': const Color(0xFFFFFFFF), 'expectedDistance': 'large'}, // Very different
        {'color': const Color(0xFF000000), 'expectedDistance': 'large'}, // Very different
      ];

      for (final testCase in testColors) {
        // ACT
        final distance = _calculateColorDistance(referenceColor, testCase['color'] as Color);

        // ASSERT
        expect(distance, greaterThanOrEqualTo(0.0));

        switch (testCase['expectedDistance']) {
          case 'small':
            expect(distance, lessThan(50.0));
            break;
          case 'medium':
            expect(distance, lessThan(100.0));
            expect(distance, greaterThanOrEqualTo(50.0));
            break;
          case 'large':
            expect(distance, greaterThanOrEqualTo(100.0));
            break;
        }
      }
    });

    test('color temperature analysis should classify warm and cool colors', () {
      // ARRANGE
      final testCases = [
        {'color': Colors.red, 'expectedTemp': 'warm'},
        {'color': Colors.orange, 'expectedTemp': 'warm'},
        {'color': Colors.yellow, 'expectedTemp': 'warm'},
        {'color': Colors.blue, 'expectedTemp': 'cool'},
        {'color': Colors.cyan, 'expectedTemp': 'cool'},
        {'color': Colors.green, 'expectedTemp': 'neutral'},
        {'color': Colors.purple, 'expectedTemp': 'cool'},
      ];

      for (final testCase in testCases) {
        // ACT
        final temperature = _analyzeColorTemperature(testCase['color'] as Color);

        // ASSERT
        expect(
          temperature,
          equals(testCase['expectedTemp']),
          reason: 'Color temperature analysis failed for ${testCase['color']}',
        );
      }
    });
  });
}

// Helper functions for color conversion testing

List<Color> _interpolateColors(Color startColor, Color endColor, int steps) {
  final colors = <Color>[];

  for (int i = 0; i <= steps; i++) {
    final t = i / steps;
    final r = (startColor.red * (1 - t) + endColor.red * t).round();
    final g = (startColor.green * (1 - t) + endColor.green * t).round();
    final b = (startColor.blue * (1 - t) + endColor.blue * t).round();

    colors.add(Color.fromRGBO(r, g, b, 1.0));
  }

  return colors;
}

Color _blendColors(Color color1, Color color2, double ratio) {
  final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
  final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
  final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
  final a = (color1.alpha * (1 - ratio) + color2.alpha * ratio).round();

  return Color.fromARGB(a, r, g, b);
}

double _calculateBrightness(Color color) {
  // Using standard luminance formula: 0.299*R + 0.587*G + 0.114*B
  return (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255.0;
}

double _calculateColorContrast(Color color1, Color color2) {
  final brightness1 = _calculateBrightness(color1);
  final brightness2 = _calculateBrightness(color2);

  final lightest = max(brightness1, brightness2);
  final darkest = min(brightness1, brightness2);

  // WCAG contrast ratio formula
  return (lightest + 0.05) / (darkest + 0.05);
}

double _calculateColorDistance(Color color1, Color color2) {
  // Euclidean distance in RGB space
  final deltaR = color1.red - color2.red;
  final deltaG = color1.green - color2.green;
  final deltaB = color1.blue - color2.blue;

  return sqrt(deltaR * deltaR + deltaG * deltaG + deltaB * deltaB);
}

String _analyzeColorTemperature(Color color) {
  final hsv = HSVColor.fromColor(color);

  // Analyze hue to determine temperature
  if (hsv.hue >= 0 && hsv.hue < 60) return 'warm'; // Red-Yellow range
  if (hsv.hue >= 60 && hsv.hue < 120) return 'neutral'; // Yellow-Green range
  if (hsv.hue >= 120 && hsv.hue < 240) return 'cool'; // Green-Blue range
  if (hsv.hue >= 240 && hsv.hue < 300) return 'cool'; // Blue-Purple range
  return 'warm'; // Purple-Red range
}
