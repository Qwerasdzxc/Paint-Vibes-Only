import 'package:flutter/material.dart';

/// Abstract interface for color management service
abstract class IColorService {
  // Color Palette Management
  Future<List<Color>> getPredefinedColors();
  Future<List<Color>> getCustomColors();
  Future<List<Color>> getRecentColors();
  Future<void> addCustomColor(Color color);
  Future<void> addToRecentColors(Color color);
  Future<void> removeCustomColor(Color color);
  Future<void> clearRecentColors();

  // Color Operations
  Color getCurrentColor();
  Future<void> setCurrentColor(Color color);
  Future<Color?> pickColorFromCanvas(String canvasId, Offset position);

  // Color Conversion
  HSVColor colorToHSV(Color color);
  Color hsvToColor(HSVColor hsv);
  String colorToHex(Color color);
  Color hexToColor(String hex);
}
