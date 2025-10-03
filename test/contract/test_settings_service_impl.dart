import 'package:flutter/material.dart';
import 'package:painter/core/services/i_settings_service.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';

/// Test implementation of SettingsService that works without SharedPreferences
/// Uses in-memory storage for testing
class TestSettingsServiceImpl implements ISettingsService {
  // In-memory storage for test settings
  final Map<String, dynamic> _storage = {};

  // Default values
  static const double _defaultBrushSize = 5.0;
  static const Color _defaultColor = Colors.black;
  static const bool _defaultPressureSensitivity = true;
  static const GalleryViewMode _defaultGalleryViewMode = GalleryViewMode.grid;
  static const GallerySortOrder _defaultGallerySortOrder = GallerySortOrder.dateCreated;
  static const int _defaultMaxUndoSteps = 20;
  static const bool _defaultAutoSaveEnabled = true;
  static const int _defaultAutoSaveInterval = 30; // seconds
  static const bool _defaultFirstTimeUser = true;

  // Drawing Settings

  @override
  Future<double> getDefaultBrushSize() async {
    return _storage['brush_size'] ?? _defaultBrushSize;
  }

  @override
  Future<void> setDefaultBrushSize(double size) async {
    if (size <= 0 || size > 50) {
      throw InvalidSettingValueException('brush_size', size, 'Brush size must be between 0 and 50');
    }
    _storage['brush_size'] = size;
  }

  @override
  Future<Color> getDefaultColor() async {
    final colorValue = _storage['default_color'] ?? _defaultColor.value;
    return Color(colorValue);
  }

  @override
  Future<void> setDefaultColor(Color color) async {
    _storage['default_color'] = color.value;
  }

  @override
  Future<bool> getPressureSensitivityEnabled() async {
    return _storage['pressure_sensitivity'] ?? _defaultPressureSensitivity;
  }

  @override
  Future<void> setPressureSensitivityEnabled(bool enabled) async {
    _storage['pressure_sensitivity'] = enabled;
  }

  // Gallery Settings

  @override
  Future<GalleryViewMode> getGalleryViewMode() async {
    final modeIndex = _storage['gallery_view_mode'] ?? _defaultGalleryViewMode.index;

    if (modeIndex < 0 || modeIndex >= GalleryViewMode.values.length) {
      return _defaultGalleryViewMode;
    }

    return GalleryViewMode.values[modeIndex];
  }

  @override
  Future<void> setGalleryViewMode(GalleryViewMode mode) async {
    _storage['gallery_view_mode'] = mode.index;
  }

  @override
  Future<GallerySortOrder> getGallerySortOrder() async {
    final orderIndex = _storage['gallery_sort_order'] ?? _defaultGallerySortOrder.index;

    if (orderIndex < 0 || orderIndex >= GallerySortOrder.values.length) {
      return _defaultGallerySortOrder;
    }

    return GallerySortOrder.values[orderIndex];
  }

  @override
  Future<void> setGallerySortOrder(GallerySortOrder order) async {
    _storage['gallery_sort_order'] = order.index;
  }

  // Performance Settings

  @override
  Future<int> getMaxUndoSteps() async {
    return _storage['max_undo_steps'] ?? _defaultMaxUndoSteps;
  }

  @override
  Future<void> setMaxUndoSteps(int steps) async {
    if (steps < 1 || steps > 100) {
      throw InvalidSettingValueException('max_undo_steps', steps, 'Max undo steps must be between 1 and 100');
    }
    _storage['max_undo_steps'] = steps;
  }

  @override
  Future<bool> getAutoSaveEnabled() async {
    return _storage['auto_save_enabled'] ?? _defaultAutoSaveEnabled;
  }

  @override
  Future<void> setAutoSaveEnabled(bool enabled) async {
    _storage['auto_save_enabled'] = enabled;
  }

  @override
  Future<int> getAutoSaveInterval() async {
    return _storage['auto_save_interval'] ?? _defaultAutoSaveInterval;
  }

  @override
  Future<void> setAutoSaveInterval(int seconds) async {
    if (seconds < 5 || seconds > 300) {
      throw InvalidSettingValueException(
        'auto_save_interval',
        seconds,
        'Auto save interval must be between 5 and 300 seconds',
      );
    }
    _storage['auto_save_interval'] = seconds;
  }

  // App Settings

  @override
  Future<bool> getFirstTimeUser() async {
    return _storage['first_time_user'] ?? _defaultFirstTimeUser;
  }

  @override
  Future<void> setFirstTimeUser(bool isFirst) async {
    _storage['first_time_user'] = isFirst;
  }

  @override
  Future<String> getAppVersion() async {
    return '1.0.0+1'; // Test version
  }

  @override
  Future<DateTime> getLastBackupDate() async {
    final timestamp = _storage['last_backup_date'];

    if (timestamp == null) {
      // Return a default date if no backup has been made
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> setLastBackupDate(DateTime date) async {
    _storage['last_backup_date'] = date.millisecondsSinceEpoch;
  }

  /// Clear all test settings
  void clearAllSettings() {
    _storage.clear();
  }

  /// Check if test setting exists
  bool hasSetting(String key) {
    return _storage.containsKey(key);
  }
}
