# API Contracts: Paint Vibes Only

**Phase 1**: Service Contracts & Interface Definitions  
**Date**: 25 September 2025

## Service Architecture Overview

This Flutter app uses a service-oriented architecture with clear contracts between UI and business logic layers. All services implement abstract interfaces for testability and maintainability.

## Drawing Service Contract

### Interface: `IDrawingService`

```dart
abstract class IDrawingService {
  // Canvas Management
  Future<DrawingCanvas> createCanvas(Size dimensions, {Color? backgroundColor});
  Future<DrawingCanvas> loadCanvas(String canvasId);
  Future<void> saveCanvas(DrawingCanvas canvas);
  Future<bool> deleteCanvas(String canvasId);
  
  // Drawing Operations
  Future<void> addStroke(String canvasId, DrawingStroke stroke);
  Future<void> removeStroke(String canvasId, String strokeId);
  Future<void> clearCanvas(String canvasId);
  
  // Undo/Redo
  Future<bool> undoLastAction(String canvasId);
  Future<bool> redoLastAction(String canvasId);
  Future<bool> canUndo(String canvasId);
  Future<bool> canRedo(String canvasId);
  
  // Tool Management
  DrawingTool getCurrentTool(String canvasId);
  Future<void> setCurrentTool(String canvasId, DrawingTool tool);
  List<DrawingTool> getAvailableTools();
  
  // Export
  Future<Uint8List> exportCanvasAsImage(String canvasId, {ImageFormat format = ImageFormat.png});
  Future<String> exportCanvasAsJson(String canvasId);
}
```

### Error Handling

```dart
// Custom exceptions for drawing operations
class CanvasNotFoundException implements Exception {
  final String canvasId;
  CanvasNotFoundException(this.canvasId);
  String toString() => 'Canvas not found: $canvasId';
}

class InvalidDrawingOperationException implements Exception {
  final String operation;
  final String reason;
  InvalidDrawingOperationException(this.operation, this.reason);
  String toString() => 'Invalid drawing operation $operation: $reason';
}

class StorageException implements Exception {
  final String operation;
  final String details;
  StorageException(this.operation, this.details);
  String toString() => 'Storage error during $operation: $details';
}
```

## Color Management Service Contract

### Interface: `IColorService`

```dart
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
```

## Artwork Management Service Contract

### Interface: `IArtworkService`

```dart
abstract class IArtworkService {
  // CRUD Operations
  Future<List<Artwork>> getAllArtworks();
  Future<Artwork?> getArtwork(String artworkId);
  Future<Artwork> createArtwork(String title, DrawingCanvas canvas);
  Future<void> updateArtwork(Artwork artwork);
  Future<bool> deleteArtwork(String artworkId);
  
  // Gallery Management
  Future<List<Artwork>> getArtworksByTag(String tag);
  Future<List<Artwork>> searchArtworks(String query);
  Future<List<Artwork>> getArtworksSorted(GallerySortOrder sortOrder);
  
  // Artwork Operations
  Future<Uint8List> generateThumbnail(String artworkId);
  Future<void> shareArtwork(String artworkId);
  Future<String> exportArtwork(String artworkId, ExportFormat format);
  
  // Metadata Management
  Future<void> addTagToArtwork(String artworkId, String tag);
  Future<void> removeTagFromArtwork(String artworkId, String tag);
  Future<List<String>> getAllTags();
}

enum ExportFormat { png, jpg, svg, pdf }
```

## Coloring Service Contract

### Interface: `IColoringService`

```dart
abstract class IColoringService {
  // Coloring Pages
  Future<List<ColoringPage>> getAvailableColoringPages();
  Future<List<ColoringPage>> getColoringPagesByCategory(String category);
  Future<ColoringPage?> getColoringPage(String pageId);
  Future<List<String>> getColoringCategories();
  
  // Coloring Progress
  Future<List<ColoringProgress>> getUserColoringProgress();
  Future<ColoringProgress?> getColoringProgress(String pageId);
  Future<ColoringProgress> startColoringPage(String pageId);
  Future<void> saveColoringProgress(ColoringProgress progress);
  Future<void> completeColoringPage(String progressId);
  
  // Coloring Operations
  Future<void> applyColorToRegion(String progressId, Offset position, Color color);
  Future<double> calculateCompletionPercentage(String progressId);
  Future<List<Color>> getSuggestedColorsForPage(String pageId);
}
```

## File Management Service Contract

### Interface: `IFileService`

```dart
abstract class IFileService {
  // Directory Management
  Future<Directory> getAppDocumentsDirectory();
  Future<Directory> getArtworksDirectory();
  Future<Directory> getColoringDirectory();
  Future<Directory> getCacheDirectory();
  
  // File Operations
  Future<File> saveImageFile(String fileName, Uint8List imageData);
  Future<File> saveJsonFile(String fileName, Map<String, dynamic> jsonData);
  Future<Map<String, dynamic>?> loadJsonFile(String fileName);
  Future<Uint8List?> loadImageFile(String fileName);
  Future<bool> deleteFile(String fileName);
  Future<bool> fileExists(String fileName);
  
  // Storage Management
  Future<int> getStorageUsage();
  Future<int> getAvailableStorage();
  Future<void> cleanupTempFiles();
  Future<void> cleanupOrphanedFiles();
  
  // Backup and Restore
  Future<String> createBackup();
  Future<void> restoreFromBackup(String backupPath);
}
```

## Settings Service Contract

### Interface: `ISettingsService`

```dart
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
```

## Event Service Contract

### Interface: `IEventService`

```dart
abstract class IEventService {
  // Event Streams
  Stream<DrawingEvent> get drawingEvents;
  Stream<ColoringEvent> get coloringEvents;
  Stream<GalleryEvent> get galleryEvents;
  Stream<StorageEvent> get storageEvents;
  
  // Event Publishing
  void publishDrawingEvent(DrawingEvent event);
  void publishColoringEvent(ColoringEvent event);
  void publishGalleryEvent(GalleryEvent event);
  void publishStorageEvent(StorageEvent event);
}

// Event Types
abstract class AppEvent {
  final DateTime timestamp;
  final String eventId;
  AppEvent(this.eventId) : timestamp = DateTime.now();
}

class DrawingEvent extends AppEvent {
  final String canvasId;
  final DrawingEventType type;
  final dynamic data;
  DrawingEvent(String eventId, this.canvasId, this.type, this.data) : super(eventId);
}

enum DrawingEventType {
  strokeAdded,
  strokeRemoved,
  canvasCleared,
  toolChanged,
  colorChanged,
  undoPerformed,
  redoPerformed
}

class ColoringEvent extends AppEvent {
  final String progressId;
  final ColoringEventType type;
  final dynamic data;
  ColoringEvent(String eventId, this.progressId, this.type, this.data) : super(eventId);
}

enum ColoringEventType {
  pageStarted,
  progressSaved,
  pageCompleted,
  regionColored
}

class GalleryEvent extends AppEvent {
  final String? artworkId;
  final GalleryEventType type;
  final dynamic data;
  GalleryEvent(String eventId, this.artworkId, this.type, this.data) : super(eventId);
}

enum GalleryEventType {
  artworkCreated,
  artworkUpdated,
  artworkDeleted,
  artworkShared,
  galleryRefreshed
}

class StorageEvent extends AppEvent {
  final StorageEventType type;
  final String details;
  StorageEvent(String eventId, this.type, this.details) : super(eventId);
}

enum StorageEventType {
  lowStorage,
  backupCreated,
  cleanupCompleted,
  storageError
}
```

## Contract Testing Requirements

Each service contract must include:

1. **Interface Compliance Tests**: Verify all methods are implemented
2. **Input Validation Tests**: Test parameter validation and error handling
3. **State Transition Tests**: Verify correct state changes
4. **Error Handling Tests**: Test exception throwing and handling
5. **Performance Tests**: Verify response time requirements
6. **Integration Tests**: Test service interactions

### Example Test Structure

```dart
// Drawing Service Contract Tests
class DrawingServiceContractTest {
  late IDrawingService service;
  
  @Test
  void testCreateCanvas_ValidInput_ReturnsCanvas() async {
    // Arrange
    final size = Size(800, 600);
    
    // Act
    final canvas = await service.createCanvas(size);
    
    // Assert
    expect(canvas.dimensions, equals(size));
    expect(canvas.strokes, isEmpty);
    expect(canvas.id, isNotEmpty);
  }
  
  @Test
  void testLoadCanvas_InvalidId_ThrowsException() async {
    // Arrange
    const invalidId = 'non_existent_canvas';
    
    // Act & Assert
    expect(
      () => service.loadCanvas(invalidId),
      throwsA(isA<CanvasNotFoundException>())
    );
  }
}
```

## API Integration Points

### External Services (Future Enhancement)
```dart
// Cloud Storage Service (Optional)
abstract class ICloudStorageService {
  Future<void> syncArtwork(String artworkId);
  Future<void> uploadArtwork(String artworkId);
  Future<void> downloadArtwork(String artworkId);
  Future<bool> isConnected();
}

// Analytics Service (Optional)
abstract class IAnalyticsService {
  void trackDrawingEvent(String eventName, Map<String, dynamic> properties);
  void trackColoringEvent(String eventName, Map<String, dynamic> properties);
  void trackPerformanceMetric(String metric, double value);
}
```

## Contract Versioning

All service contracts use semantic versioning:
- Major version: Breaking changes to method signatures
- Minor version: New methods added (backward compatible)
- Patch version: Bug fixes, no interface changes

Contract compatibility matrix will be maintained for migration planning.

## Next Phase: Implementation

These contracts provide the foundation for:
1. Service implementation classes
2. Mock services for testing
3. Dependency injection configuration
4. Integration test scenarios