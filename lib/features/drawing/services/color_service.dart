import 'package:flutter/material.dart';
import 'package:painter/features/drawing/services/i_color_service.dart';
import 'package:painter/shared/models/color_palette.dart';

/// Implementation of IColorService for managing color operations
class ColorService implements IColorService {
  ColorPalette _colorPalette = ColorPalette.defaultPalette();

  @override
  Future<List<Color>> getPredefinedColors() async {
    return _colorPalette.predefinedColors;
  }

  @override
  Future<List<Color>> getCustomColors() async {
    return _colorPalette.customColors;
  }

  @override
  Future<List<Color>> getRecentColors() async {
    return _colorPalette.recentColors;
  }

  @override
  Future<void> addCustomColor(Color color) async {
    _colorPalette = _colorPalette.addCustomColor(color);
  }

  @override
  Future<void> addToRecentColors(Color color) async {
    _colorPalette = _colorPalette.addToRecentColors(color);
  }

  @override
  Future<void> removeCustomColor(Color color) async {
    _colorPalette = _colorPalette.removeCustomColor(color);
  }

  @override
  Future<void> clearRecentColors() async {
    _colorPalette = _colorPalette.clearRecentColors();
  }

  @override
  Color getCurrentColor() {
    return _colorPalette.currentColor;
  }

  @override
  Future<void> setCurrentColor(Color color) async {
    _colorPalette = _colorPalette.setCurrentColor(color);
  }

  @override
  Future<Color?> pickColorFromCanvas(String canvasId, Offset position) async {
    // TODO: Implement actual color picking from canvas
    // This would require access to the canvas pixel data
    // For now, return null to indicate color picking is not available
    return null;
  }

  @override
  HSVColor colorToHSV(Color color) {
    return HSVColor.fromColor(color);
  }

  @override
  Color hsvToColor(HSVColor hsv) {
    return hsv.toColor();
  }

  @override
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  Color hexToColor(String hex) {
    String hexString = hex.replaceAll('#', '');

    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // Add alpha channel
    }

    final int value = int.parse(hexString, radix: 16);
    return Color(value);
  }

  /// Get the current color palette
  ColorPalette getColorPalette() {
    return _colorPalette;
  }

  /// Set the entire color palette
  void setColorPalette(ColorPalette palette) {
    _colorPalette = palette;
  }
}
