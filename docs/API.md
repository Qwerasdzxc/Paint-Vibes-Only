# Paint Vibes API Documentation

This document provides comprehensive API documentation for the Paint Vibes drawing and coloring application.

## Table of Contents

- [Core Services](#core-services)
- [Models](#models)
- [Widgets](#widgets)
- [State Management](#state-management)
- [Storage](#storage)
- [Error Handling](#error-handling)

## Core Services

### ArtworkService

Manages artwork creation, storage, and retrieval operations.

```dart
abstract class IArtworkService {
  /// Creates a new artwork and saves it to storage
  Future<Artwork> createArtwork({
    required String title,
    required String description,
    required Size dimensions,
    String? templateId,
  });

  /// Saves an existing artwork to persistent storage
  Future<void> saveArtwork(Artwork artwork);

  /// Loads an artwork from storage by ID
  Future<Artwork?> loadArtwork(String artworkId);

  /// Retrieves all artworks from storage
  Future<List<Artwork>> getAllArtworks();

  /// Deletes an artwork from storage
  Future<void> deleteArtwork(String artworkId);

  /// Updates artwork metadata
  Future<void> updateArtwork(Artwork artwork);
}
```

#### Usage Example

```dart
final artworkService = ServiceLocator.instance.get<IArtworkService>();

// Create new artwork
final artwork = await artworkService.createArtwork(
  title: 'My Drawing',
  description: 'A beautiful landscape',
  dimensions: const Size(800, 600),
);

// Save artwork
await artworkService.saveArtwork(artwork);

// Load all artworks
final allArtworks = await artworkService.getAllArtworks();
```

### ColoringService

Handles coloring page functionality and progress tracking.

```dart
abstract class IColoringService {
  /// Retrieves all available coloring pages
  Future<List<ColoringPage>> getColoringPages();

  /// Gets a specific coloring page by ID
  Future<ColoringPage?> getColoringPage(String pageId);

  /// Saves coloring progress for a specific page
  Future<void> saveColoringProgress(ColoringProgress progress);

  /// Loads coloring progress for a specific page
  Future<ColoringProgress?> loadColoringProgress(String pageId);

  /// Creates a new coloring page from an image
  Future<ColoringPage> createColoringPage({
    required String title,
    required String imagePath,
    Map<String, dynamic>? metadata,
  });
}
```

#### Usage Example

```dart
final coloringService = ServiceLocator.instance.get<IColoringService>();

// Get all coloring pages
final pages = await coloringService.getColoringPages();

// Save progress
final progress = ColoringProgress(
  pageId: 'page-123',
  completionPercentage: 75.0,
  coloredRegions: regionData,
  lastModified: DateTime.now(),
);
await coloringService.saveColoringProgress(progress);
```

### FileService

Manages file system operations for artwork and data storage.

```dart
abstract class IFileService {
  /// Saves data to a file
  Future<void> saveToFile(String path, String data);

  /// Reads data from a file
  Future<String?> readFromFile(String path);

  /// Checks if a file exists
  Future<bool> fileExists(String path);

  /// Deletes a file
  Future<void> deleteFile(String path);

  /// Gets the application documents directory
  Future<String> getDocumentsPath();

  /// Creates a directory if it doesn't exist
  Future<void> createDirectory(String path);
}
```

## Models

### Artwork

Represents a user's artwork with metadata and state information.

```dart
class Artwork {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final String fullImagePath;
  final String canvasDataPath;
  final DateTime createdAt;
  final DateTime lastModified;
  final Size originalSize;
  final List<String> tags;
  final bool isCompleted;
  final int strokeCount;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.fullImagePath,
    required this.canvasDataPath,
    required this.createdAt,
    required this.lastModified,
    required this.originalSize,
    required this.tags,
    required this.isCompleted,
    required this.strokeCount,
  });

  /// Creates a copy with modified properties
  Artwork copyWith({
    String? id,
    String? title,
    String? description,
    // ... other parameters
  });

  /// Converts artwork to JSON for serialization
  Map<String, dynamic> toJson();

  /// Creates artwork from JSON data
  factory Artwork.fromJson(Map<String, dynamic> json);

  /// Validates artwork data
  bool get isValid;
}
```

### DrawingStroke

Represents a single drawing stroke on the canvas.

```dart
class DrawingStroke {
  final String id;
  final DrawingTool tool;
  final Color color;
  final double brushSize;
  final List<Offset> points;
  final double opacity;
  final BlendMode blendMode;
  final DateTime timestamp;

  DrawingStroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.brushSize,
    required this.points,
    this.opacity = 1.0,
    BlendMode? blendMode,
    DateTime? timestamp,
  });

  /// Creates a copy with modified properties
  DrawingStroke copyWith({
    String? id,
    DrawingTool? tool,
    Color? color,
    // ... other parameters
  });

  /// Converts to JSON for serialization
  Map<String, dynamic> toJson();

  /// Creates from JSON data
  factory DrawingStroke.fromJson(Map<String, dynamic> json);
}
```

### DrawingCanvas

Represents the drawing canvas and its current state.

```dart
class DrawingCanvas {
  final String id;
  final Size dimensions;
  final Color backgroundColor;
  final List<DrawingStroke> strokes;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentBrushSize;
  final bool isDirty;
  final DateTime lastModified;

  DrawingCanvas({
    required this.id,
    required this.dimensions,
    required this.backgroundColor,
    required this.strokes,
    required this.currentTool,
    required this.currentColor,
    required this.currentBrushSize,
    required this.isDirty,
    DateTime? lastModified,
  });

  /// Creates an empty canvas
  factory DrawingCanvas.empty({
    required String id,
    required Size dimensions,
    Color? backgroundColor,
  });

  /// Adds a stroke to the canvas
  DrawingCanvas addStroke(DrawingStroke stroke);

  /// Removes a stroke from the canvas
  DrawingCanvas removeStroke(String strokeId);

  /// Clears all strokes
  DrawingCanvas clearStrokes();

  /// Marks canvas as saved
  DrawingCanvas markAsSaved();

  /// Validates canvas state
  bool get isValid;
}
```

### ColorPalette

Manages color selections and palette customization.

```dart
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

  /// Creates default palette
  factory ColorPalette.defaultPalette();

  /// Adds a custom color
  ColorPalette addCustomColor(Color color);

  /// Removes a custom color
  ColorPalette removeCustomColor(Color color);

  /// Sets current color and updates recent colors
  ColorPalette setCurrentColor(Color color);

  /// Gets all available colors
  List<Color> get allColors;

  /// Validates palette state
  bool get isValid;
}
```

## Widgets

### DrawingCanvasWidget

The main drawing surface widget that handles user input and rendering.

```dart
class DrawingCanvasWidget extends StatefulWidget {
  final DrawingCanvas canvas;
  final Function(DrawingStroke) onStrokeAdded;
  final Function(String) onStrokeRemoved;
  final VoidCallback? onCanvasChanged;

  const DrawingCanvasWidget({
    Key? key,
    required this.canvas,
    required this.onStrokeAdded,
    required this.onStrokeRemoved,
    this.onCanvasChanged,
  }) : super(key: key);

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}
```

#### Usage Example

```dart
DrawingCanvasWidget(
  canvas: currentCanvas,
  onStrokeAdded: (stroke) {
    // Handle new stroke
    setState(() {
      currentCanvas = currentCanvas.addStroke(stroke);
    });
  },
  onStrokeRemoved: (strokeId) {
    // Handle stroke removal
    setState(() {
      currentCanvas = currentCanvas.removeStroke(strokeId);
    });
  },
)
```

### ToolSelectorWidget

Provides tool selection interface for drawing tools.

```dart
class ToolSelectorWidget extends StatelessWidget {
  final DrawingTool currentTool;
  final Function(DrawingTool) onToolChanged;
  final List<DrawingTool> availableTools;

  const ToolSelectorWidget({
    Key? key,
    required this.currentTool,
    required this.onToolChanged,
    required this.availableTools,
  }) : super(key: key);
}
```

### ColorPickerWidget

Advanced color selection widget with palette management.

```dart
class ColorPickerWidget extends StatefulWidget {
  final ColorPalette palette;
  final Function(Color) onColorSelected;
  final Function(ColorPalette) onPaletteChanged;

  const ColorPickerWidget({
    Key? key,
    required this.palette,
    required this.onColorSelected,
    required this.onPaletteChanged,
  }) : super(key: key);
}
```

## State Management

### DrawingState

Manages the drawing canvas state and operations.

```dart
class DrawingState extends ChangeNotifier {
  DrawingCanvas _canvas;
  final List<DrawingCanvas> _history;
  int _historyIndex;

  DrawingCanvas get canvas => _canvas;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  /// Adds a stroke to the canvas
  void addStroke(DrawingStroke stroke);

  /// Removes a stroke from the canvas
  void removeStroke(String strokeId);

  /// Undoes the last operation
  void undo();

  /// Redoes the next operation
  void redo();

  /// Clears the canvas
  void clearCanvas();

  /// Sets the current tool
  void setCurrentTool(DrawingTool tool);

  /// Sets the current color
  void setCurrentColor(Color color);

  /// Sets the brush size
  void setBrushSize(double size);
}
```

### ColorState

Manages color palette and selection state.

```dart
class ColorState extends ChangeNotifier {
  ColorPalette _palette;

  ColorPalette get palette => _palette;
  Color get currentColor => _palette.currentColor;

  /// Sets the current color
  void setCurrentColor(Color color);

  /// Adds a custom color
  void addCustomColor(Color color);

  /// Removes a custom color
  void removeCustomColor(Color color);

  /// Clears recent colors
  void clearRecentColors();
}
```

### GalleryState

Manages artwork gallery and filtering state.

```dart
class GalleryState extends ChangeNotifier {
  List<Artwork> _artworks;
  GalleryViewMode _viewMode;
  GallerySortOrder _sortOrder;
  String _searchQuery;

  List<Artwork> get artworks => _getFilteredArtworks();
  GalleryViewMode get viewMode => _viewMode;

  /// Loads all artworks
  Future<void> loadArtworks();

  /// Adds a new artwork
  void addArtwork(Artwork artwork);

  /// Removes an artwork
  void removeArtwork(String artworkId);

  /// Sets the view mode
  void setViewMode(GalleryViewMode mode);

  /// Sets the sort order
  void setSortOrder(GallerySortOrder order);

  /// Sets the search query
  void setSearchQuery(String query);
}
```

## Storage

### FileStorageManager

Manages file system storage operations with comprehensive error handling.

```dart
class FileStorageManager {
  static FileStorageManager? _instance;
  static FileStorageManager get instance => _instance ??= FileStorageManager._();

  /// Initializes storage directories
  Future<void> initialize();

  /// Saves artwork data to storage
  Future<void> saveArtwork(Artwork artwork);

  /// Loads artwork data from storage
  Future<Artwork?> loadArtwork(String artworkId);

  /// Gets all artwork metadata
  Future<List<Artwork>> getAllArtworks();

  /// Deletes artwork from storage
  Future<void> deleteArtwork(String artworkId);

  /// Saves canvas state
  Future<void> saveCanvas(DrawingCanvas canvas);

  /// Loads canvas state
  Future<DrawingCanvas?> loadCanvas(String canvasId);

  /// Gets storage usage statistics
  Future<StorageStats> getStorageStats();

  /// Cleans up temporary files
  Future<void> cleanupTempFiles();
}
```

## Error Handling

### ErrorHandler

Global error handling and logging system.

```dart
class ErrorHandler {
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  /// Initializes error handler
  Future<void> initialize();

  /// Logs an error with context
  void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]);

  /// Logs a warning
  void logWarning(String message, [
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]);

  /// Logs info message
  void logInfo(String message, [Map<String, dynamic>? context]);

  /// Handles caught exceptions
  void handleException(
    dynamic exception,
    StackTrace stackTrace, {
    String? message,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
  });

  /// Shows error dialog to user
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  });

  /// Gets error statistics
  Map<String, int> getErrorStatistics();

  /// Exports error log
  String exportLog();
}
```

### Error Utilities

Utility functions for safe operation execution.

```dart
class ErrorHandlerUtils {
  /// Executes async operation safely
  static Future<T?> safeAsync<T>(
    Future<T> operation, {
    String? context,
    T? fallback,
    bool showUserError = false,
    BuildContext? buildContext,
  });

  /// Executes sync operation safely
  static T? safe<T>(
    T Function() operation, {
    String? context,
    T? fallback,
    bool showUserError = false,
    BuildContext? buildContext,
  });
}
```

## Integration Examples

### Creating and Saving a Drawing

```dart
// Initialize services
final artworkService = ServiceLocator.instance.get<IArtworkService>();
final fileStorageManager = FileStorageManager.instance;

// Create new artwork
final artwork = await artworkService.createArtwork(
  title: 'My Masterpiece',
  description: 'A beautiful drawing',
  dimensions: const Size(800, 600),
);

// Create canvas
final canvas = DrawingCanvas.empty(
  id: artwork.id,
  dimensions: artwork.originalSize,
);

// Add strokes to canvas
final stroke = DrawingStroke(
  id: 'stroke-1',
  tool: DrawingTool.brush,
  color: Colors.blue,
  brushSize: 5.0,
  points: [Offset(10, 10), Offset(20, 20), Offset(30, 30)],
);

final updatedCanvas = canvas.addStroke(stroke);

// Save canvas and artwork
await fileStorageManager.saveCanvas(updatedCanvas);
await artworkService.saveArtwork(artwork.copyWith(strokeCount: 1));
```

### Loading and Displaying Gallery

```dart
// Get gallery state provider
final galleryState = Provider.of<GalleryState>(context, listen: false);

// Load artworks
await galleryState.loadArtworks();

// Display in widget
Consumer<GalleryState>(
  builder: (context, state, child) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: state.artworks.length,
      itemBuilder: (context, index) {
        final artwork = state.artworks[index];
        return GalleryItemWidget(
          artwork: artwork,
          onTap: () => _openArtwork(artwork),
        );
      },
    );
  },
)
```

## Best Practices

### Error Handling
- Always use try-catch blocks for async operations
- Provide meaningful error messages to users
- Log errors with sufficient context
- Use the ErrorHandlerUtils for consistent error handling

### State Management
- Keep state providers focused on single responsibilities
- Use immutable data structures where possible
- Notify listeners only when necessary
- Dispose of resources properly

### Performance
- Lazy load artwork thumbnails
- Implement efficient canvas rendering
- Use proper image caching strategies
- Optimize state updates and rebuilds

### Testing
- Write unit tests for all business logic
- Use widget tests for UI components
- Implement integration tests for user workflows
- Mock external dependencies in tests

---

This API documentation covers the core functionality of the Paint Vibes application. For more detailed examples and advanced usage patterns, refer to the source code and additional documentation files.