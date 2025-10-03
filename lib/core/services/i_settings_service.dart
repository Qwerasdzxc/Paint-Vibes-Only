import 'package:flutter/material.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart'; // for GallerySortOrder

/// Gallery view mode options
enum GalleryViewMode { grid, list, timeline }

/// Interface for application settings management
abstract class ISettingsService {
  // Drawing Settings
  Future<double> getDefaultBrushSize();
  Future<void> setDefaultBrushSize(double size);
  Future<Color> getDefaultColor();
  Future<void> setDefaultColor(Color color);
  Future<bool> getPressureSensitivityEnabled();
  Future<void> setPressureSensitivityEnabled(bool enabled);

  // Gallery Settings
  Future<GalleryViewMode> getGalleryViewMode();
  Future<void> setGalleryViewMode(GalleryViewMode mode);
  Future<GallerySortOrder> getGallerySortOrder();
  Future<void> setGallerySortOrder(GallerySortOrder order);

  // Performance Settings
  Future<int> getMaxUndoSteps();
  Future<void> setMaxUndoSteps(int steps);
  Future<bool> getAutoSaveEnabled();
  Future<void> setAutoSaveEnabled(bool enabled);
  Future<int> getAutoSaveInterval();
  Future<void> setAutoSaveInterval(int seconds);

  // App Settings
  Future<bool> getFirstTimeUser();
  Future<void> setFirstTimeUser(bool isFirst);
  Future<String> getAppVersion();
  Future<DateTime> getLastBackupDate();
  Future<void> setLastBackupDate(DateTime date);
}

/// Custom exceptions for settings operations
class SettingsException implements Exception {
  final String setting;
  final String details;
  SettingsException(this.setting, this.details);
  String toString() => 'Settings error for $setting: $details';
}

class InvalidSettingValueException implements Exception {
  final String setting;
  final dynamic value;
  final String reason;
  InvalidSettingValueException(this.setting, this.value, this.reason);
  String toString() => 'Invalid value $value for setting $setting: $reason';
}

class SettingsStorageException implements Exception {
  final String operation;
  final String details;
  SettingsStorageException(this.operation, this.details);
  String toString() => 'Settings storage error during $operation: $details';
}
