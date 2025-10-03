import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/core/services/i_settings_service.dart';
import 'package:painter/shared/models/drawing_canvas.dart';
import 'package:painter/shared/models/drawing_stroke.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/coloring_progress.dart';

import 'package:painter/shared/models/user_gallery.dart';
import 'package:painter/shared/models/color_palette.dart';

/// State management setup with Provider pattern
/// Contains all application state providers and their configurations

/// Drawing state management - handles canvas operations and drawing tools
class DrawingState extends ChangeNotifier {
  DrawingCanvas _canvas = DrawingCanvas.empty(
    id: 'canvas_${DateTime.now().millisecondsSinceEpoch}',
    dimensions: const Size(800, 600),
  );

  DrawingTool _currentTool = DrawingTool.pencil;
  Color _currentColor = Colors.black;
  double _currentBrushSize = 8.0;
  List<DrawingStroke> _undoStack = [];
  List<DrawingStroke> _redoStack = [];
  bool _isDrawing = false;
  DrawingStroke? _currentStroke;

  // Getters
  DrawingCanvas get canvas => _canvas;
  DrawingTool get currentTool => _currentTool;
  Color get currentColor => _currentColor;
  double get currentBrushSize => _currentBrushSize;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isDrawing => _isDrawing;
  bool get hasUnsavedChanges => _canvas.isDirty;

  /// Set the current drawing tool
  void setTool(DrawingTool tool) {
    if (_currentTool != tool) {
      _currentTool = tool;
      _currentBrushSize = tool.defaultSize;
      _canvas = _canvas.copyWith(currentTool: tool);
      notifyListeners();
    }
  }

  /// Set the current drawing color
  void setColor(Color color) {
    if (_currentColor != color) {
      _currentColor = color;
      _canvas = _canvas.copyWith(currentColor: color);
      notifyListeners();
    }
  }

  /// Set the current brush size
  void setBrushSize(double size) {
    final clampedSize = size.clamp(_currentTool.minSize, _currentTool.maxSize);
    if (_currentBrushSize != clampedSize) {
      _currentBrushSize = clampedSize;
      _canvas = _canvas.copyWith(currentBrushSize: clampedSize);
      notifyListeners();
    }
  }

  /// Start a new stroke
  void startStroke(Offset position) {
    if (_isDrawing) return;

    _currentStroke = DrawingStroke(
      id: 'stroke_${DateTime.now().millisecondsSinceEpoch}',
      tool: _currentTool,
      color: _currentColor,
      brushSize: _currentBrushSize,
      points: [position],
      opacity: 1.0,
      blendMode: _currentTool.blendMode,
      timestamp: DateTime.now(),
    );

    _isDrawing = true;
    notifyListeners();
  }

  /// Continue current stroke with new point
  void continueStroke(Offset position) {
    if (!_isDrawing || _currentStroke == null) return;

    _currentStroke = _currentStroke!.copyWith(points: [..._currentStroke!.points, position]);

    notifyListeners();
  }

  /// End current stroke and add to canvas
  void endStroke() {
    if (!_isDrawing || _currentStroke == null) return;

    // Add current stroke to canvas
    final newStrokes = [..._canvas.strokes, _currentStroke!];
    _canvas = _canvas.copyWith(strokes: newStrokes, isDirty: true, lastModified: DateTime.now());

    // Add to undo stack
    _undoStack.add(_currentStroke!);
    _redoStack.clear(); // Clear redo stack when new action is performed

    _isDrawing = false;
    _currentStroke = null;
    notifyListeners();
  }

  /// Undo last stroke
  void undo() {
    if (_undoStack.isEmpty) return;

    final lastStroke = _undoStack.removeLast();
    _redoStack.add(lastStroke);

    // Remove stroke from canvas
    final newStrokes = _canvas.strokes.where((s) => s.id != lastStroke.id).toList();
    _canvas = _canvas.copyWith(strokes: newStrokes, isDirty: newStrokes.isNotEmpty, lastModified: DateTime.now());

    notifyListeners();
  }

  /// Redo last undone stroke
  void redo() {
    if (_redoStack.isEmpty) return;

    final stroke = _redoStack.removeLast();
    _undoStack.add(stroke);

    // Add stroke back to canvas
    final newStrokes = [..._canvas.strokes, stroke];
    _canvas = _canvas.copyWith(strokes: newStrokes, isDirty: true, lastModified: DateTime.now());

    notifyListeners();
  }

  /// Clear the entire canvas
  void clearCanvas() {
    if (_canvas.strokes.isNotEmpty) {
      // Save all strokes to undo stack for potential recovery
      _undoStack.addAll(_canvas.strokes);
      _redoStack.clear();

      _canvas = _canvas.copyWith(strokes: [], isDirty: false, lastModified: DateTime.now());

      notifyListeners();
    }
  }

  /// Load existing canvas
  void loadCanvas(DrawingCanvas canvas) {
    _canvas = canvas;
    _currentTool = canvas.currentTool;
    _currentColor = canvas.currentColor;
    _currentBrushSize = canvas.currentBrushSize;
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  /// Set canvas background color
  void setBackgroundColor(Color color) {
    _canvas = _canvas.copyWith(backgroundColor: color, isDirty: true, lastModified: DateTime.now());
    notifyListeners();
  }

  /// Mark canvas as saved (not dirty)
  void markSaved() {
    _canvas = _canvas.copyWith(isDirty: false);
    notifyListeners();
  }
}

/// Color state management - handles color palettes and selections
class ColorState extends ChangeNotifier {
  ColorPalette _palette = ColorPalette.defaultPalette();
  Color _selectedColor = Colors.black;
  bool _showColorPicker = false;

  // Getters
  ColorPalette get palette => _palette;
  Color get selectedColor => _selectedColor;
  List<Color> get predefinedColors => _palette.predefinedColors;
  List<Color> get customColors => _palette.customColors;
  List<Color> get recentColors => _palette.recentColors;
  bool get showColorPicker => _showColorPicker;

  /// Set the selected color and add to recent colors
  void selectColor(Color color) {
    if (_selectedColor != color) {
      _selectedColor = color;
      _palette = _palette.addToRecentColors(color);
      notifyListeners();
    }
  }

  /// Add custom color to palette
  void addCustomColor(Color color) {
    _palette = _palette.addCustomColor(color);
    notifyListeners();
  }

  /// Remove custom color from palette
  void removeCustomColor(Color color) {
    _palette = _palette.removeCustomColor(color);
    notifyListeners();
  }

  /// Load color palette
  void loadPalette(ColorPalette palette) {
    _palette = palette;
    notifyListeners();
  }

  /// Toggle color picker visibility
  void toggleColorPicker() {
    _showColorPicker = !_showColorPicker;
    notifyListeners();
  }

  /// Hide color picker
  void hideColorPicker() {
    if (_showColorPicker) {
      _showColorPicker = false;
      notifyListeners();
    }
  }

  /// Show color picker
  void showColorPickerDialog() {
    if (!_showColorPicker) {
      _showColorPicker = true;
      notifyListeners();
    }
  }
}

/// Gallery state management - handles artwork collections and viewing options
class GalleryState extends ChangeNotifier {
  List<Artwork> _artworks = [];
  List<Artwork> _filteredArtworks = [];
  List<ColoringProgress> _coloringProgress = [];
  UserGallery? _gallery;
  String _searchQuery = '';
  GalleryViewMode _viewMode = GalleryViewMode.grid;
  GallerySortOrder _sortOrder = GallerySortOrder.dateModified;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Artwork> get artworks => _artworks;
  List<Artwork> get filteredArtworks => _filteredArtworks;
  List<ColoringProgress> get coloringProgress => _coloringProgress;
  UserGallery? get gallery => _gallery;
  String get searchQuery => _searchQuery;
  GalleryViewMode get viewMode => _viewMode;
  GallerySortOrder get sortOrder => _sortOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasArtworks => _artworks.isNotEmpty;
  int get artworkCount => _artworks.length;

  /// Load artworks from storage
  Future<void> loadArtworks(List<Artwork> artworks) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _artworks = artworks;
      _filterAndSortArtworks();
    } catch (e) {
      _error = 'Failed to load artworks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new artwork to collection
  void addArtwork(Artwork artwork) {
    _artworks.insert(0, artwork); // Add to beginning for recent-first display
    _filterAndSortArtworks();
    notifyListeners();
  }

  /// Update existing artwork
  void updateArtwork(Artwork updatedArtwork) {
    final index = _artworks.indexWhere((a) => a.id == updatedArtwork.id);
    if (index != -1) {
      _artworks[index] = updatedArtwork;
      _filterAndSortArtworks();
      notifyListeners();
    }
  }

  /// Remove artwork from collection
  void removeArtwork(String artworkId) {
    _artworks.removeWhere((a) => a.id == artworkId);
    _filterAndSortArtworks();
    notifyListeners();
  }

  /// Set search query and filter artworks
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _filterAndSortArtworks();
      notifyListeners();
    }
  }

  /// Set view mode (grid/list/timeline)
  void setViewMode(GalleryViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  /// Set sort order
  void setSortOrder(GallerySortOrder order) {
    if (_sortOrder != order) {
      _sortOrder = order;
      _filterAndSortArtworks();
      notifyListeners();
    }
  }

  /// Load coloring progress
  void loadColoringProgress(List<ColoringProgress> progress) {
    _coloringProgress = progress;
    notifyListeners();
  }

  /// Add coloring progress
  void addColoringProgress(ColoringProgress progress) {
    _coloringProgress.add(progress);
    notifyListeners();
  }

  /// Update coloring progress
  void updateColoringProgress(ColoringProgress updatedProgress) {
    final index = _coloringProgress.indexWhere((p) => p.id == updatedProgress.id);
    if (index != -1) {
      _coloringProgress[index] = updatedProgress;
      notifyListeners();
    }
  }

  /// Load gallery settings
  void loadGallery(UserGallery gallery) {
    _gallery = gallery;
    _viewMode = gallery.defaultViewMode;
    _sortOrder = gallery.defaultSortOrder;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helper methods

  void _filterAndSortArtworks() {
    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredArtworks = List.from(_artworks);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredArtworks = _artworks.where((artwork) {
        return artwork.title.toLowerCase().contains(query) ||
            artwork.description.toLowerCase().contains(query) ||
            artwork.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply sort order
    switch (_sortOrder) {
      case GallerySortOrder.dateCreated:
        _filteredArtworks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case GallerySortOrder.dateModified:
        _filteredArtworks.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case GallerySortOrder.title:
        _filteredArtworks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case GallerySortOrder.strokeCount:
        _filteredArtworks.sort((a, b) => b.strokeCount.compareTo(a.strokeCount));
        break;
    }
  }
}

/// Application state provider - combines all state providers
class AppProviders {
  /// Create and configure all application providers
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<DrawingState>(create: (_) => DrawingState()),
      ChangeNotifierProvider<ColorState>(create: (_) => ColorState()),
      ChangeNotifierProvider<GalleryState>(create: (_) => GalleryState()),
    ];
  }

  /// Wrap app with all required providers
  static Widget wrapApp(Widget app) {
    return MultiProvider(providers: getProviders(), child: app);
  }
}

/// Extension methods for easy provider access in widgets
extension BuildContextProviders on BuildContext {
  DrawingState get drawingState => watch<DrawingState>();
  ColorState get colorState => watch<ColorState>();
  GalleryState get galleryState => watch<GalleryState>();

  DrawingState get drawingStateRead => read<DrawingState>();
  ColorState get colorStateRead => read<ColorState>();
  GalleryState get galleryStateRead => read<GalleryState>();
}
