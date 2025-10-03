import 'package:flutter/material.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';
import 'package:painter/features/drawing/widgets/drawing_canvas.dart';
import 'package:painter/features/drawing/widgets/interactive_drawing_canvas.dart';
import 'package:painter/features/drawing/widgets/color_picker.dart';
import 'package:painter/features/drawing/widgets/tool_selector.dart';
import 'package:painter/shared/models/drawing_tool.dart';
import 'package:painter/shared/models/color_palette.dart';

/// Screen for coloring pre-made designs
class ColoringScreen extends StatefulWidget {
  final ColoringPage? coloringPage;
  final ColoringProgress? existingProgress;

  const ColoringScreen({super.key, this.coloringPage, this.existingProgress});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  ColoringPage? _currentPage;
  ColoringProgress? _progress;

  DrawingTool _currentTool = DrawingTool.brush;
  Color _currentColor = Colors.blue;
  double _currentBrushSize = 8.0;
  ColorPalette _colorPalette = ColorPalette.defaultPalette();

  bool _showPageSelector = false;
  double _completionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.coloringPage;
    _progress = widget.existingProgress;

    if (_currentPage == null && _progress == null) {
      _showPageSelector = true;
    }

    _updateCompletionProgress();
    _setupSuggestedColors();
  }

  void _updateCompletionProgress() {
    if (_progress != null) {
      _completionProgress = _progress!.completionPercent;
    }
  }

  void _setupSuggestedColors() {
    if (_currentPage != null && _currentPage!.suggestedColors.isNotEmpty) {
      final suggestedColors = _currentPage!.suggestedColors
          .map((colorHex) => _parseColor(colorHex))
          .where((color) => color != null)
          .cast<Color>()
          .toList();

      if (suggestedColors.isNotEmpty) {
        _colorPalette = _colorPalette.copyWith(predefinedColors: suggestedColors);
        _currentColor = suggestedColors.first;
      }
    }
  }

  Color? _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showPageSelector) {
      return _buildPageSelector();
    }

    if (_currentPage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coloring'), backgroundColor: Colors.purple, foregroundColor: Colors.white),
        body: const Center(child: Text('No coloring page selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage!.title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showPageSelector = true;
              });
            },
            icon: const Icon(Icons.grid_view),
            tooltip: 'Choose Page',
          ),
          IconButton(onPressed: _saveProgress, icon: const Icon(Icons.save), tooltip: 'Save Progress'),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(children: [Icon(Icons.refresh), SizedBox(width: 8), Text('Reset Page')]),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(children: [Icon(Icons.help), SizedBox(width: 8), Text('Help')]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_completionProgress > 0) _buildProgressIndicator(),

          // Tool and color controls
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Compact tool selector for coloring
                CompactToolSelector(
                  selectedTool: _currentTool,
                  onToolSelected: (tool) {
                    setState(() {
                      _currentTool = tool;
                      _currentBrushSize = tool.defaultSize * 1.5; // Larger brushes for coloring
                    });
                  },
                ),
                const SizedBox(width: 16),

                // Color picker with suggested colors
                Expanded(
                  child: ColorPicker(
                    selectedColor: _currentColor,
                    onColorSelected: (color) {
                      setState(() {
                        _currentColor = color;
                      });
                    },
                    palette: _colorPalette,
                    onPaletteUpdated: (palette) {
                      setState(() {
                        _colorPalette = palette;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Coloring canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Background outline
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: _currentPage!.outlinePath.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(_currentPage!.thumbnailPath), // Fallback to thumbnail
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.multiply),
                            )
                          : null,
                    ),
                  ),

                  // Drawing overlay
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.transparent,
                      child: InteractiveDrawingCanvas(
                        strokes: const [], // TODO: Load from progress
                        currentTool: _currentTool,
                        currentColor: _currentColor,
                        currentBrushSize: _currentBrushSize,
                        onStrokeCompleted: _onStrokeCompleted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status and tips
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Difficulty: ${_currentPage!.difficulty.displayName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _currentPage!.difficulty.color, fontWeight: FontWeight.bold),
                ),
                if (_completionProgress > 0)
                  Text(
                    '${(_completionProgress * 100).round()}% Complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${(_completionProgress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _completionProgress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_completionProgress == 1.0 ? Colors.green : Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildPageSelector() {
    final samplePages = ColoringPage.samplePages;
    final categories = ColoringPage.allCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Coloring Page'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: _currentPage != null
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _showPageSelector = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: Column(
        children: [
          // Category filter tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: true, // TODO: Implement category filtering
                      onSelected: (selected) {
                        // TODO: Filter by category
                      },
                    ),
                  );
                }

                final category = categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: false,
                    onSelected: (selected) {
                      // TODO: Filter by category
                    },
                  ),
                );
              },
            ),
          ),

          // Page grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: samplePages.length,
              itemBuilder: (context, index) {
                final page = samplePages[index];
                return _buildPageCard(page);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(ColoringPage page) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = page;
          _showPageSelector = false;
          _setupSuggestedColors();
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page thumbnail
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[100],
                ),
                child: page.thumbnailPath.isNotEmpty
                    ? Image.asset(
                        page.thumbnailPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 48, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.palette, size: 48, color: Colors.grey),
              ),
            ),

            // Page info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(page.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(page.difficulty.icon, size: 16, color: page.difficulty.color),
                            const SizedBox(width: 4),
                            Text(
                              page.difficulty.displayName,
                              style: TextStyle(fontSize: 12, color: page.difficulty.color, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        if (page.completionCount > 0)
                          Text('${page.completionCount}x', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStrokeCompleted(stroke) {
    // TODO: Update completion progress based on colored areas
    setState(() {
      _completionProgress = (_completionProgress + 0.05).clamp(0.0, 1.0);
    });
  }

  void _saveProgress() {
    // TODO: Save coloring progress to storage
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Progress saved!'), backgroundColor: Colors.green));
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reset':
        _showResetDialog();
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Page'),
        content: const Text('Are you sure you want to reset all coloring progress on this page?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _completionProgress = 0.0;
                // TODO: Clear coloring strokes
              });
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coloring Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Use suggested colors for best results'),
            Text('• Start with larger areas first'),
            Text('• Zoom in for detailed sections'),
            Text('• Save your progress regularly'),
            Text('• Try different brush sizes'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it'))],
      ),
    );
  }
}
