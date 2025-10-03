import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/shared/models/color_palette.dart';

void main() {
  group('ColorPalette Tests', () {
    test('should create color palette with required fields', () {
      final predefinedColors = [Colors.red, Colors.blue, Colors.green];
      final customColors = [Colors.pink, Colors.orange];
      final recentColors = [Colors.yellow];

      final palette = ColorPalette(
        predefinedColors: predefinedColors,
        customColors: customColors,
        recentColors: recentColors,
        currentColor: Colors.black,
        maxRecentColors: 5,
      );

      expect(palette.predefinedColors, predefinedColors);
      expect(palette.customColors, customColors);
      expect(palette.recentColors, recentColors);
      expect(palette.currentColor, Colors.black);
      expect(palette.maxRecentColors, 5);
    });

    test('should create default palette', () {
      final defaultPalette = ColorPalette.defaultPalette();

      expect(defaultPalette.predefinedColors.isNotEmpty, true);
      expect(defaultPalette.predefinedColors.contains(Colors.black), true);
      expect(defaultPalette.predefinedColors.contains(Colors.white), true);
      expect(defaultPalette.predefinedColors.contains(Colors.red), true);
      expect(defaultPalette.predefinedColors.contains(Colors.blue), true);
      expect(defaultPalette.customColors.isEmpty, true);
      expect(defaultPalette.recentColors.isEmpty, true);
      expect(defaultPalette.currentColor, Colors.black);
      expect(defaultPalette.maxRecentColors, 10);
    });

    test('should copy with modified properties', () {
      final originalPalette = ColorPalette.defaultPalette();

      final modifiedPalette = originalPalette.copyWith(
        currentColor: Colors.red,
        maxRecentColors: 15,
        customColors: [Colors.purple],
      );

      expect(modifiedPalette.currentColor, Colors.red);
      expect(modifiedPalette.maxRecentColors, 15);
      expect(modifiedPalette.customColors, [Colors.purple]);
      expect(modifiedPalette.predefinedColors, originalPalette.predefinedColors);
      expect(modifiedPalette.recentColors, originalPalette.recentColors);
    });

    test('should add custom color', () {
      final palette = ColorPalette.defaultPalette();
      final customColor = const Color(0xFF123456);

      final updatedPalette = palette.addCustomColor(customColor);

      expect(updatedPalette.customColors.contains(customColor), true);
      expect(updatedPalette.customColors.length, 1);

      // Adding same color again should not duplicate
      final duplicatePalette = updatedPalette.addCustomColor(customColor);
      expect(duplicatePalette.customColors.length, 1);
    });

    test('should remove custom color', () {
      final palette = ColorPalette.defaultPalette();
      final customColor1 = const Color(0xFF123456);
      final customColor2 = const Color(0xFF654321);

      final paletteWithColors = palette.addCustomColor(customColor1).addCustomColor(customColor2);

      expect(paletteWithColors.customColors.length, 2);

      final paletteAfterRemoval = paletteWithColors.removeCustomColor(customColor1);
      expect(paletteAfterRemoval.customColors.length, 1);
      expect(paletteAfterRemoval.customColors.contains(customColor1), false);
      expect(paletteAfterRemoval.customColors.contains(customColor2), true);
    });

    test('should add to recent colors', () {
      final palette = ColorPalette.defaultPalette();

      final updatedPalette = palette.addToRecentColors(Colors.red);

      expect(updatedPalette.recentColors.length, 1);
      expect(updatedPalette.recentColors.first, Colors.red);
    });

    test('should maintain recent colors order and limit', () {
      final palette = ColorPalette(
        predefinedColors: [Colors.black],
        customColors: [],
        recentColors: [],
        currentColor: Colors.black,
        maxRecentColors: 3,
      );

      var updatedPalette = palette;

      // Add 5 colors (more than limit)
      updatedPalette = updatedPalette.addToRecentColors(Colors.red);
      updatedPalette = updatedPalette.addToRecentColors(Colors.blue);
      updatedPalette = updatedPalette.addToRecentColors(Colors.green);
      updatedPalette = updatedPalette.addToRecentColors(Colors.yellow);
      updatedPalette = updatedPalette.addToRecentColors(Colors.orange);

      // Should keep only 3 most recent colors
      expect(updatedPalette.recentColors.length, 3);
      expect(updatedPalette.recentColors[0], Colors.orange); // Most recent
      expect(updatedPalette.recentColors[1], Colors.yellow);
      expect(updatedPalette.recentColors[2], Colors.green);
    });

    test('should move existing color to front when added to recent', () {
      final palette = ColorPalette.defaultPalette();

      var updatedPalette = palette;
      updatedPalette = updatedPalette.addToRecentColors(Colors.red);
      updatedPalette = updatedPalette.addToRecentColors(Colors.blue);
      updatedPalette = updatedPalette.addToRecentColors(Colors.green);

      expect(updatedPalette.recentColors, [Colors.green, Colors.blue, Colors.red]);

      // Add blue again - should move to front
      updatedPalette = updatedPalette.addToRecentColors(Colors.blue);

      expect(updatedPalette.recentColors, [Colors.blue, Colors.green, Colors.red]);
      expect(updatedPalette.recentColors.length, 3); // No duplicates
    });

    test('should clear recent colors', () {
      final palette = ColorPalette.defaultPalette().addToRecentColors(Colors.red).addToRecentColors(Colors.blue);

      expect(palette.recentColors.length, 2);

      final clearedPalette = palette.clearRecentColors();

      expect(clearedPalette.recentColors.isEmpty, true);
    });

    test('should set current color and add to recent', () {
      final palette = ColorPalette.defaultPalette();

      final updatedPalette = palette.setCurrentColor(Colors.purple);

      expect(updatedPalette.currentColor, Colors.purple);
      expect(updatedPalette.recentColors.contains(Colors.purple), true);
      expect(updatedPalette.recentColors.first, Colors.purple);
    });

    test('should get all colors', () {
      final palette = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue],
        customColors: [Colors.purple, Colors.orange],
        recentColors: [],
        currentColor: Colors.black,
      );

      final allColors = palette.allColors;

      expect(allColors.length, 4);
      expect(allColors.contains(Colors.red), true);
      expect(allColors.contains(Colors.blue), true);
      expect(allColors.contains(Colors.purple), true);
      expect(allColors.contains(Colors.orange), true);
    });

    test('should convert to and from JSON', () {
      final originalPalette = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue, Colors.green],
        customColors: [Colors.purple, Colors.orange],
        recentColors: [Colors.yellow, Colors.cyan],
        currentColor: Colors.pink,
        maxRecentColors: 8,
      );

      final json = originalPalette.toJson();
      final restoredPalette = ColorPalette.fromJson(json);

      expect(restoredPalette.predefinedColors.length, originalPalette.predefinedColors.length);
      expect(restoredPalette.customColors.length, originalPalette.customColors.length);
      expect(restoredPalette.recentColors.length, originalPalette.recentColors.length);
      expect(restoredPalette.currentColor.value, originalPalette.currentColor.value);
      expect(restoredPalette.maxRecentColors, originalPalette.maxRecentColors);

      // Check specific colors
      expect(restoredPalette.predefinedColors[0].value, Colors.red.value);
      expect(restoredPalette.customColors[0].value, Colors.purple.value);
      expect(restoredPalette.recentColors[0].value, Colors.yellow.value);
    });

    test('should handle color value serialization correctly', () {
      const customColor = Color(0xFF123456);
      final palette = ColorPalette.defaultPalette().addCustomColor(customColor);

      final json = palette.toJson();
      final restoredPalette = ColorPalette.fromJson(json);

      expect(restoredPalette.customColors.first.value, customColor.value);
      expect(restoredPalette.customColors.first.red, customColor.red);
      expect(restoredPalette.customColors.first.green, customColor.green);
      expect(restoredPalette.customColors.first.blue, customColor.blue);
      expect(restoredPalette.customColors.first.alpha, customColor.alpha);
    });

    test('should validate palette properties', () {
      final validPalette = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue],
        customColors: [],
        recentColors: [Colors.green],
        currentColor: Colors.black,
        maxRecentColors: 5,
      );

      expect(validPalette.isValid, true);

      final invalidPalette = ColorPalette(
        predefinedColors: [], // Empty predefined colors
        customColors: [],
        recentColors: [Colors.red, Colors.blue, Colors.green],
        currentColor: Colors.black,
        maxRecentColors: 2, // Recent colors exceed max
      );

      expect(invalidPalette.isValid, false);
    });

    test('should handle equality comparison', () {
      final palette1 = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue],
        customColors: [Colors.purple],
        recentColors: [Colors.green],
        currentColor: Colors.black,
        maxRecentColors: 5,
      );

      final palette2 = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue],
        customColors: [Colors.purple],
        recentColors: [Colors.yellow], // Different recent colors
        currentColor: Colors.black,
        maxRecentColors: 5,
      );

      final palette3 = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue],
        customColors: [Colors.purple],
        recentColors: [Colors.green],
        currentColor: Colors.white, // Different current color
        maxRecentColors: 5,
      );

      expect(palette1, equals(palette2)); // Same structure (equality ignores recent colors)
      expect(palette1, isNot(equals(palette3))); // Different current color
      expect(palette1.hashCode, equals(palette2.hashCode));
      expect(palette1.hashCode, isNot(equals(palette3.hashCode)));
    });

    test('should handle toString method', () {
      final palette = ColorPalette(
        predefinedColors: [Colors.red, Colors.blue, Colors.green],
        customColors: [Colors.purple, Colors.orange],
        recentColors: [Colors.yellow],
        currentColor: Colors.black,
      );

      final stringRepresentation = palette.toString();

      expect(stringRepresentation.contains('ColorPalette'), true);
      expect(stringRepresentation.contains('current'), true);
      expect(stringRepresentation.contains('predefined: 3'), true);
      expect(stringRepresentation.contains('custom: 2'), true);
    });

    test('should handle empty custom colors list', () {
      final palette = ColorPalette.defaultPalette();

      expect(palette.customColors.isEmpty, true);

      final allColors = palette.allColors;
      expect(allColors, palette.predefinedColors);
    });

    test('should preserve order of predefined colors', () {
      final predefinedColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
      final palette = ColorPalette(
        predefinedColors: predefinedColors,
        customColors: [],
        recentColors: [],
        currentColor: Colors.black,
      );

      expect(palette.predefinedColors[0], Colors.red);
      expect(palette.predefinedColors[1], Colors.green);
      expect(palette.predefinedColors[2], Colors.blue);
      expect(palette.predefinedColors[3], Colors.yellow);
    });

    test('should handle default palette colors count', () {
      final defaultPalette = ColorPalette.defaultPalette();

      // Default palette should have a reasonable number of colors
      expect(defaultPalette.predefinedColors.length, greaterThan(10));
      expect(defaultPalette.predefinedColors.length, lessThan(20));

      // Should include basic colors
      expect(defaultPalette.predefinedColors.contains(Colors.black), true);
      expect(defaultPalette.predefinedColors.contains(Colors.white), true);
      expect(defaultPalette.predefinedColors.contains(Colors.red), true);
      expect(defaultPalette.predefinedColors.contains(Colors.green), true);
      expect(defaultPalette.predefinedColors.contains(Colors.blue), true);
    });
  });
}
