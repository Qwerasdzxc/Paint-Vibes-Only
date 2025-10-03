import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:painter/core/services/i_settings_service.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';

/// Implementation of ISettingsService using SharedPreferences for persistent storage
class SettingsService implements ISettingsService {
  static const String _keyBrushSize = 'default_brush_size';
  static const String _keyDefaultColor = 'default_color';
  static const String _keyPressureSensitivity = 'pressure_sensitivity_enabled';
  static const String _keyGalleryViewMode = 'gallery_view_mode';
  static const String _keyGallerySortOrder = 'gallery_sort_order';
  static const String _keyMaxUndoSteps = 'max_undo_steps';
  static const String _keyAutoSaveEnabled = 'auto_save_enabled';
  static const String _keyAutoSaveInterval = 'auto_save_interval';
  static const String _keyFirstTimeUser = 'first_time_user';
  static const String _keyLastBackupDate = 'last_backup_date';

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

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Drawing Settings

  @override
  Future<double> getDefaultBrushSize() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getDouble(_keyBrushSize) ?? _defaultBrushSize;
    } catch (e) {
      throw SettingsStorageException('getDefaultBrushSize', e.toString());
    }
  }

  @override
  Future<void> setDefaultBrushSize(double size) async {
    if (size <= 0 || size > 50) {
      throw InvalidSettingValueException(_keyBrushSize, size, 'Brush size must be between 0 and 50');
    }

    try {
      final prefs = await _getPrefs();
      await prefs.setDouble(_keyBrushSize, size);
    } catch (e) {
      throw SettingsStorageException('setDefaultBrushSize', e.toString());
    }
  }

  @override
  Future<Color> getDefaultColor() async {
    try {
      final prefs = await _getPrefs();
      final colorValue = prefs.getInt(_keyDefaultColor) ?? _defaultColor.value;
      return Color(colorValue);
    } catch (e) {
      throw SettingsStorageException('getDefaultColor', e.toString());
    }
  }

  @override
  Future<void> setDefaultColor(Color color) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyDefaultColor, color.value);
    } catch (e) {
      throw SettingsStorageException('setDefaultColor', e.toString());
    }
  }

  @override
  Future<bool> getPressureSensitivityEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyPressureSensitivity) ?? _defaultPressureSensitivity;
    } catch (e) {
      throw SettingsStorageException('getPressureSensitivityEnabled', e.toString());
    }
  }

  @override
  Future<void> setPressureSensitivityEnabled(bool enabled) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_keyPressureSensitivity, enabled);
    } catch (e) {
      throw SettingsStorageException('setPressureSensitivityEnabled', e.toString());
    }
  }

  // Gallery Settings

  @override
  Future<GalleryViewMode> getGalleryViewMode() async {
    try {
      final prefs = await _getPrefs();
      final modeIndex = prefs.getInt(_keyGalleryViewMode) ?? _defaultGalleryViewMode.index;

      if (modeIndex < 0 || modeIndex >= GalleryViewMode.values.length) {
        return _defaultGalleryViewMode;
      }

      return GalleryViewMode.values[modeIndex];
    } catch (e) {
      throw SettingsStorageException('getGalleryViewMode', e.toString());
    }
  }

  @override
  Future<void> setGalleryViewMode(GalleryViewMode mode) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyGalleryViewMode, mode.index);
    } catch (e) {
      throw SettingsStorageException('setGalleryViewMode', e.toString());
    }
  }

  @override
  Future<GallerySortOrder> getGallerySortOrder() async {
    try {
      final prefs = await _getPrefs();
      final orderIndex = prefs.getInt(_keyGallerySortOrder) ?? _defaultGallerySortOrder.index;

      if (orderIndex < 0 || orderIndex >= GallerySortOrder.values.length) {
        return _defaultGallerySortOrder;
      }

      return GallerySortOrder.values[orderIndex];
    } catch (e) {
      throw SettingsStorageException('getGallerySortOrder', e.toString());
    }
  }

  @override
  Future<void> setGallerySortOrder(GallerySortOrder order) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyGallerySortOrder, order.index);
    } catch (e) {
      throw SettingsStorageException('setGallerySortOrder', e.toString());
    }
  }

  // Performance Settings

  @override
  Future<int> getMaxUndoSteps() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_keyMaxUndoSteps) ?? _defaultMaxUndoSteps;
    } catch (e) {
      throw SettingsStorageException('getMaxUndoSteps', e.toString());
    }
  }

  @override
  Future<void> setMaxUndoSteps(int steps) async {
    if (steps < 1 || steps > 100) {
      throw InvalidSettingValueException(_keyMaxUndoSteps, steps, 'Max undo steps must be between 1 and 100');
    }

    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyMaxUndoSteps, steps);
    } catch (e) {
      throw SettingsStorageException('setMaxUndoSteps', e.toString());
    }
  }

  @override
  Future<bool> getAutoSaveEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyAutoSaveEnabled) ?? _defaultAutoSaveEnabled;
    } catch (e) {
      throw SettingsStorageException('getAutoSaveEnabled', e.toString());
    }
  }

  @override
  Future<void> setAutoSaveEnabled(bool enabled) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_keyAutoSaveEnabled, enabled);
    } catch (e) {
      throw SettingsStorageException('setAutoSaveEnabled', e.toString());
    }
  }

  @override
  Future<int> getAutoSaveInterval() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_keyAutoSaveInterval) ?? _defaultAutoSaveInterval;
    } catch (e) {
      throw SettingsStorageException('getAutoSaveInterval', e.toString());
    }
  }

  @override
  Future<void> setAutoSaveInterval(int seconds) async {
    if (seconds < 5 || seconds > 300) {
      throw InvalidSettingValueException(
        _keyAutoSaveInterval,
        seconds,
        'Auto save interval must be between 5 and 300 seconds',
      );
    }

    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyAutoSaveInterval, seconds);
    } catch (e) {
      throw SettingsStorageException('setAutoSaveInterval', e.toString());
    }
  }

  // App Settings

  @override
  Future<bool> getFirstTimeUser() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_keyFirstTimeUser) ?? _defaultFirstTimeUser;
    } catch (e) {
      throw SettingsStorageException('getFirstTimeUser', e.toString());
    }
  }

  @override
  Future<void> setFirstTimeUser(bool isFirst) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_keyFirstTimeUser, isFirst);
    } catch (e) {
      throw SettingsStorageException('setFirstTimeUser', e.toString());
    }
  }

  @override
  Future<String> getAppVersion() async {
    try {
      // TODO: Consider adding package_info_plus dependency for dynamic version
      // For now, return the version from pubspec.yaml
      return '1.0.0+1';
    } catch (e) {
      throw SettingsStorageException('getAppVersion', e.toString());
    }
  }

  @override
  Future<DateTime> getLastBackupDate() async {
    try {
      final prefs = await _getPrefs();
      final timestamp = prefs.getInt(_keyLastBackupDate);

      if (timestamp == null) {
        // Return a default date if no backup has been made
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      throw SettingsStorageException('getLastBackupDate', e.toString());
    }
  }

  @override
  Future<void> setLastBackupDate(DateTime date) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keyLastBackupDate, date.millisecondsSinceEpoch);
    } catch (e) {
      throw SettingsStorageException('setLastBackupDate', e.toString());
    }
  }

  /// Clear all settings (useful for testing or reset functionality)
  Future<void> clearAllSettings() async {
    try {
      final prefs = await _getPrefs();
      await prefs.clear();
    } catch (e) {
      throw SettingsStorageException('clearAllSettings', e.toString());
    }
  }

  /// Check if setting exists
  Future<bool> hasSetting(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    } catch (e) {
      throw SettingsStorageException('hasSetting', e.toString());
    }
  }
}
