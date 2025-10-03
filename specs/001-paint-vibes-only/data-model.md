# Data Model: Paint Vibes Only

**Phase 1**: Data Architecture & Entity Design  
**Date**: 25 September 2025

## Core Entities

### Drawing Canvas
Represents the active drawing surface and its state.

```dart
class DrawingCanvas {
  String id;                    // Unique identifier
  Size dimensions;              // Canvas size in logical pixels
  Color backgroundColor;        // Canvas background color
  List<DrawingStroke> strokes;  // All drawing strokes
  DrawingTool currentTool;      // Currently selected tool
  Color currentColor;           // Currently selected color
  double currentBrushSize;      // Current brush size
  bool isDirty;                // Has unsaved changes
  DateTime lastModified;        // Last modification timestamp
}
```

**Validation Rules**:
- Canvas dimensions must be positive values
- Stroke list cannot exceed 10,000 strokes per canvas
- Background color must be valid Color object
- Last modified must be valid timestamp

**State Transitions**:
- Clean → Dirty: When stroke added
- Dirty → Clean: When saved successfully
- Any → Loading: During save/load operations

### Drawing Stroke
Represents a single drawing action on the canvas.

```dart
class DrawingStroke {
  String id;                    // Unique stroke identifier
  DrawingTool tool;            // Tool used for this stroke
  Color color;                 // Stroke color
  double brushSize;            // Stroke brush size
  List<Offset> points;         // Path points
  double opacity;              // Stroke opacity (0.0-1.0)
  BlendMode blendMode;         // How stroke blends with canvas
  DateTime timestamp;          // When stroke was created
}
```

**Validation Rules**:
- Points list must contain at least 2 points
- Opacity must be between 0.0 and 1.0
- Brush size must be positive value
- Color must be valid Color object

### Drawing Tool
Represents available drawing instruments and their properties.

```dart
enum ToolType {
  pencil,
  brush,
  eraser,
  bucketFill,
  eyedropper,
  line,
  rectangle,
  circle,
  wave
}

class DrawingTool {
  ToolType type;               // Tool type
  String name;                 // Display name
  String iconAsset;           // Tool icon asset path
  double minSize;             // Minimum brush size
  double maxSize;             // Maximum brush size
  double defaultSize;         // Default brush size
  bool supportsOpacity;       // Supports opacity variation
  bool supportsPressure;      // Supports pressure sensitivity
  BlendMode blendMode;        // Default blend mode
}
```

**Tool Configurations**:
- Pencil: Fixed opacity, no pressure, normal blend
- Brush: Variable opacity, pressure support, normal blend
- Eraser: Fixed opacity, no pressure, clear blend
- Bucket: No size, fixed opacity, normal blend
- Shapes: Variable size, fixed opacity, normal blend

### Artwork
Represents completed or in-progress user creations with metadata.

```dart
class Artwork {
  String id;                   // Unique artwork identifier
  String title;                // User-defined title
  String description;          // Optional description
  String thumbnailPath;        // Thumbnail image path
  String fullImagePath;        // Full resolution image path
  String canvasDataPath;       // Canvas data file path
  DateTime createdAt;          // Creation timestamp
  DateTime lastModified;       // Last modification timestamp
  Size originalSize;           // Original canvas dimensions
  List<String> tags;           // User-defined tags
  bool isCompleted;           // Completion status
  int strokeCount;            // Number of strokes
}
```

**Validation Rules**:
- Title cannot be empty and max 100 characters
- File paths must be valid and accessible
- Timestamps must be valid
- Stroke count must be non-negative
- Original size must have positive dimensions

### Coloring Page
Represents pre-made designs available for coloring.

```dart
class ColoringPage {
  String id;                   // Unique page identifier
  String title;                // Page title
  String description;          // Page description
  String category;             // Page category (animals, nature, etc.)
  String outlinePath;          // Outline SVG or image path
  String thumbnailPath;        // Thumbnail image path
  Difficulty difficulty;       // Complexity level
  List<String> suggestedColors; // Recommended color palette
  bool isUnlocked;            // Availability status
  int completionCount;        // Times completed by user
}

enum Difficulty {
  easy,      // Simple shapes, few details
  medium,    // Moderate complexity
  hard,      // Complex details, many regions
}
```

### Coloring Progress
Represents user's progress on individual coloring pages.

```dart
class ColoringProgress {
  String id;                   // Unique progress identifier
  String coloringPageId;       // Associated coloring page
  String userId;               // User identifier (for future multi-user)
  String progressImagePath;    // Current progress image
  String canvasDataPath;       // Canvas state data
  double completionPercent;    // Completion percentage (0.0-1.0)
  DateTime startedAt;          // When user started
  DateTime lastWorkedOn;       // Last activity
  bool isCompleted;           // Completion status
  Duration totalTimeSpent;     // Total coloring time
}
```

**Validation Rules**:
- Completion percent must be between 0.0 and 1.0
- Time spent must be non-negative
- Timestamps must be valid and logical order

### Color Palette
Represents available colors and user preferences.

```dart
class ColorPalette {
  List<Color> predefinedColors; // Standard color set
  List<Color> customColors;     // User-created colors
  List<Color> recentColors;     // Recently used colors
  Color currentColor;           // Currently selected color
  int maxRecentColors;          // Maximum recent colors to track
}
```

**Validation Rules**:
- Recent colors list cannot exceed maxRecentColors
- All colors must be valid Color objects
- Current color must exist in one of the color lists

### User Gallery
Represents collection of user's saved artworks and progress.

```dart
class UserGallery {
  String userId;                        // User identifier
  List<Artwork> artworks;              // User's drawings
  List<ColoringProgress> coloringProgress; // Coloring page progress
  GallerySortOrder sortOrder;          // Display sort order
  GalleryViewMode viewMode;            // Display view mode
  DateTime lastAccessed;               // Last gallery access
}

enum GallerySortOrder {
  dateCreated,
  dateModified,
  title,
  strokeCount
}

enum GalleryViewMode {
  grid,
  list,
  timeline
}
```

## Data Relationships

### Entity Relationship Diagram
```
UserGallery
├── 1:N → Artwork
├── 1:N → ColoringProgress
└── 1:1 → ColorPalette

Artwork
├── 1:1 → DrawingCanvas
└── N:M → Tags

ColoringProgress
└── N:1 → ColoringPage

DrawingCanvas
├── 1:N → DrawingStroke
└── 1:1 → DrawingTool (current)

DrawingStroke
└── N:1 → DrawingTool
```

## Storage Schema

### File System Organization
```
app_documents/
├── artworks/
│   ├── {artwork_id}/
│   │   ├── canvas.json      # Canvas state data
│   │   ├── image.png        # Rendered artwork
│   │   └── thumbnail.png    # Gallery thumbnail
│   └── metadata.json        # Artwork metadata index
├── coloring/
│   ├── pages/              # Built-in coloring pages
│   │   ├── {page_id}.svg   # Page outline
│   │   └── {page_id}.png   # Page thumbnail
│   └── progress/           # User coloring progress
│       ├── {progress_id}/
│       │   ├── canvas.json # Progress state
│       │   └── image.png   # Current progress image
│       └── metadata.json   # Progress metadata index
├── settings/
│   ├── palette.json        # Color palette data
│   ├── tools.json          # Tool configurations
│   └── gallery.json        # Gallery preferences
└── cache/
    ├── thumbnails/         # Cached thumbnails
    └── temp/              # Temporary files
```

### JSON Schema Examples

#### Canvas State (canvas.json)
```json
{
  "id": "canvas_001",
  "version": "1.0",
  "dimensions": {"width": 800, "height": 600},
  "backgroundColor": {"r": 255, "g": 255, "b": 255, "a": 255},
  "strokes": [
    {
      "id": "stroke_001",
      "tool": "brush",
      "color": {"r": 0, "g": 0, "b": 255, "a": 255},
      "brushSize": 5.0,
      "opacity": 1.0,
      "points": [
        {"x": 100.0, "y": 150.0},
        {"x": 102.0, "y": 152.0}
      ],
      "timestamp": "2025-09-25T10:30:00.000Z"
    }
  ],
  "createdAt": "2025-09-25T10:00:00.000Z",
  "lastModified": "2025-09-25T10:30:00.000Z"
}
```

#### Artwork Metadata (artwork_metadata.json)
```json
{
  "id": "artwork_001",
  "title": "My First Drawing",
  "description": "A beautiful sunset scene",
  "thumbnailPath": "artworks/artwork_001/thumbnail.png",
  "fullImagePath": "artworks/artwork_001/image.png",
  "canvasDataPath": "artworks/artwork_001/canvas.json",
  "createdAt": "2025-09-25T10:00:00.000Z",
  "lastModified": "2025-09-25T10:30:00.000Z",
  "originalSize": {"width": 800, "height": 600},
  "tags": ["sunset", "landscape", "beginner"],
  "isCompleted": true,
  "strokeCount": 45
}
```

## Data Migration Strategy

### Version Management
- Schema versioning in all JSON files
- Automatic migration on app updates
- Backward compatibility for at least 2 versions
- Migration logs for debugging

### Data Integrity
- Checksum validation for critical files
- Atomic file operations for saves
- Backup creation before migrations
- Recovery procedures for corrupted data

## Performance Considerations

### Memory Management
- Lazy loading of artwork thumbnails
- Stroke data pagination for large drawings
- Canvas state caching with LRU eviction
- Background processing for non-critical operations

### Storage Optimization
- Image compression with quality settings
- JSON minification for metadata files
- Cleanup of temporary and orphaned files
- Storage usage monitoring and alerts

## Next Phase Readiness

All data models defined with clear relationships, validation rules, and storage schema. Ready for contract generation and API design in Phase 1 continuation.