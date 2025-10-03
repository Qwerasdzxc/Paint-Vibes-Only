import 'package:flutter/material.dart';

/// Represents available colors and user preferences
class ColorPalette {
  final List<Color> predefinedColors;
  final List<Color> customColors;
  final List<Color> recentColors;
  final Color currentColor;
  final int maxRecentColors;

  ColorPalette({
    required this.predefinedColors,
    required this.customColors,
    required this.recentColors,
    required this.currentColor,
    this.maxRecentColors = 10,
  });

  /// Create default color palette
  factory ColorPalette.defaultPalette() {
    return ColorPalette(
      predefinedColors: [
        Colors.black,
        Colors.white,
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.brown,
        Colors.grey,
        Colors.cyan,
        Colors.amber,
        Colors.indigo,
        Colors.teal,
        Colors.lime,
      ],
      customColors: [],
      recentColors: [],
      currentColor: Colors.black,
    );
  }

  /// Create a copy of this palette with modified properties
  ColorPalette copyWith({
    List<Color>? predefinedColors,
    List<Color>? customColors,
    List<Color>? recentColors,
    Color? currentColor,
    int? maxRecentColors,
  }) {
    return ColorPalette(
      predefinedColors: predefinedColors ?? List.from(this.predefinedColors),
      customColors: customColors ?? List.from(this.customColors),
      recentColors: recentColors ?? List.from(this.recentColors),
      currentColor: currentColor ?? this.currentColor,
      maxRecentColors: maxRecentColors ?? this.maxRecentColors,
    );
  }

  /// Add a custom color to the palette
  ColorPalette addCustomColor(Color color) {
    if (customColors.contains(color)) return this;
    return copyWith(customColors: [...customColors, color]);
  }

  /// Remove a custom color from the palette
  ColorPalette removeCustomColor(Color color) {
    final updatedCustomColors = customColors.where((c) => c != color).toList();
    return copyWith(customColors: updatedCustomColors);
  }

  /// Add a color to recent colors (maintaining max limit)
  ColorPalette addToRecentColors(Color color) {
    final updatedRecentColors = List<Color>.from(recentColors);
    updatedRecentColors.remove(color); // Remove if already exists
    updatedRecentColors.insert(0, color); // Add to beginning

    // Keep only maxRecentColors items
    if (updatedRecentColors.length > maxRecentColors) {
      updatedRecentColors.removeRange(maxRecentColors, updatedRecentColors.length);
    }

    return copyWith(recentColors: updatedRecentColors);
  }

  /// Clear recent colors
  ColorPalette clearRecentColors() {
    return copyWith(recentColors: []);
  }

  /// Set current color and add to recent colors
  ColorPalette setCurrentColor(Color color) {
    return addToRecentColors(color).copyWith(currentColor: color);
  }

  /// Get all colors (predefined + custom)
  List<Color> get allColors => [...predefinedColors, ...customColors];

  /// Convert palette to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'predefinedColors': predefinedColors.map((c) => c.value).toList(),
      'customColors': customColors.map((c) => c.value).toList(),
      'recentColors': recentColors.map((c) => c.value).toList(),
      'currentColor': currentColor.value,
      'maxRecentColors': maxRecentColors,
    };
  }

  /// Create palette from JSON
  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      predefinedColors: (json['predefinedColors'] as List).map((v) => Color(v as int)).toList(),
      customColors: (json['customColors'] as List).map((v) => Color(v as int)).toList(),
      recentColors: (json['recentColors'] as List).map((v) => Color(v as int)).toList(),
      currentColor: Color(json['currentColor'] as int),
      maxRecentColors: json['maxRecentColors'] as int,
    );
  }

  /// Validation rules
  bool get isValid {
    return recentColors.length <= maxRecentColors && predefinedColors.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorPalette &&
        other.currentColor == currentColor &&
        other.predefinedColors.length == predefinedColors.length &&
        other.customColors.length == customColors.length;
  }

  @override
  int get hashCode => Object.hash(currentColor, predefinedColors.length, customColors.length);

  @override
  String toString() {
    return 'ColorPalette{current: $currentColor, predefined: ${predefinedColors.length}, custom: ${customColors.length}}';
  }
}
