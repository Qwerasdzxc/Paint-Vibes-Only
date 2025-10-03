import 'package:flutter/material.dart';
import 'package:painter/shared/models/drawing_tool.dart';

/// Enhanced widget for selecting drawing tools with improved icons
class ToolSelector extends StatelessWidget {
  final DrawingTool selectedTool;
  final Function(DrawingTool) onToolSelected;
  final double? brushSize;
  final Function(double)? onBrushSizeChanged;
  final List<DrawingTool>? availableTools;
  final bool showLabels;
  final Axis direction;
  final double toolSize;

  const ToolSelector({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    this.brushSize,
    this.onBrushSizeChanged,
    this.availableTools,
    this.showLabels = true,
    this.direction = Axis.horizontal,
    this.toolSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final tools = availableTools ?? DrawingTool.allTools;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool buttons
          direction == Axis.horizontal
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: _buildToolButtons(tools)),
                )
              : Column(mainAxisSize: MainAxisSize.min, children: _buildToolButtons(tools)),

          // Brush size slider
          if (brushSize != null && onBrushSizeChanged != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.brush, size: 16),
                const SizedBox(width: 8),
                const Text('Brush Size', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const Spacer(),
                SizedBox(
                  width: 40,
                  child: Text(
                    brushSize!.round().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(value: brushSize!, min: 1.0, max: 50.0, divisions: 49, onChanged: onBrushSizeChanged!),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildToolButtons(List<DrawingTool> tools) {
    return tools.map((tool) {
      final isSelected = selectedTool.type == tool.type;

      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: _ToolButton(
          tool: tool,
          isSelected: isSelected,
          showLabel: showLabels,
          toolSize: toolSize,
          onPressed: () => onToolSelected(tool),
        ),
      );
    }).toList();
  }
}

class _ToolButton extends StatelessWidget {
  final DrawingTool tool;
  final bool isSelected;
  final bool showLabel;
  final double toolSize;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.tool,
    required this.isSelected,
    required this.onPressed,
    this.showLabel = true,
    this.toolSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: toolSize,
        height: toolSize,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getToolIcon(tool.type), color: isSelected ? Colors.white : Colors.grey[700], size: toolSize * 0.4),
            if (showLabel && toolSize >= 40) ...[
              const SizedBox(height: 4),
              Text(
                _getToolName(tool.type),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: toolSize > 50 ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.pencil:
        return Icons.edit;
      case ToolType.brush:
        return Icons.brush;
      case ToolType.eraser:
        return Icons.auto_fix_normal;
      case ToolType.bucketFill:
        return Icons.format_color_fill;
      case ToolType.eyedropper:
        return Icons.colorize;
      case ToolType.line:
        return Icons.timeline;
      case ToolType.rectangle:
        return Icons.rectangle_outlined;
      case ToolType.circle:
        return Icons.circle_outlined;
      case ToolType.wave:
        return Icons.waves;
    }
  }

  String _getToolName(ToolType type) {
    switch (type) {
      case ToolType.pencil:
        return 'Pencil';
      case ToolType.brush:
        return 'Brush';
      case ToolType.eraser:
        return 'Eraser';
      case ToolType.bucketFill:
        return 'Fill';
      case ToolType.eyedropper:
        return 'Dropper';
      case ToolType.line:
        return 'Line';
      case ToolType.rectangle:
        return 'Rectangle';
      case ToolType.circle:
        return 'Circle';
      case ToolType.wave:
        return 'Wave';
    }
  }
}

/// Compact tool selector for limited space
class CompactToolSelector extends StatelessWidget {
  final DrawingTool selectedTool;
  final ValueChanged<DrawingTool> onToolSelected;
  final List<DrawingTool> availableTools;

  CompactToolSelector({super.key, required this.selectedTool, required this.onToolSelected})
    : availableTools = DrawingTool.allTools;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableTools.map((tool) {
          final isSelected = tool.type == selectedTool.type;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onToolSelected(tool),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCompactToolIcon(tool.type),
                  size: 18,
                  color: isSelected ? Colors.white : Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getCompactToolIcon(ToolType type) {
    switch (type) {
      case ToolType.pencil:
        return Icons.edit;
      case ToolType.brush:
        return Icons.brush;
      case ToolType.eraser:
        return Icons.auto_fix_normal;
      case ToolType.bucketFill:
        return Icons.format_color_fill;
      case ToolType.eyedropper:
        return Icons.colorize;
      case ToolType.line:
        return Icons.timeline;
      case ToolType.rectangle:
        return Icons.rectangle_outlined;
      case ToolType.circle:
        return Icons.circle_outlined;
      case ToolType.wave:
        return Icons.waves;
    }
  }
}

/// Floating action tool selector
class FloatingToolSelector extends StatefulWidget {
  final DrawingTool selectedTool;
  final ValueChanged<DrawingTool> onToolSelected;
  final List<DrawingTool> availableTools;

  FloatingToolSelector({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    List<DrawingTool>? availableTools,
  }) : availableTools = availableTools ?? DrawingTool.allTools;

  @override
  State<FloatingToolSelector> createState() => _FloatingToolSelectorState();
}

class _FloatingToolSelectorState extends State<FloatingToolSelector> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expanded tools
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _animation,
              child: Column(
                children: widget.availableTools
                    .where((tool) => tool.type != widget.selectedTool.type)
                    .map(
                      (tool) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFloatingToolButton(tool, false),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),

        // Main selected tool button
        GestureDetector(onTap: _toggleExpansion, child: _buildFloatingToolButton(widget.selectedTool, true)),
      ],
    );
  }

  Widget _buildFloatingToolButton(DrawingTool tool, bool isMain) {
    final isSelected = tool.type == widget.selectedTool.type;

    return GestureDetector(
      onTap: isMain
          ? _toggleExpansion
          : () {
              widget.onToolSelected(tool);
              _toggleExpansion();
            },
      child: Container(
        width: isMain ? 56 : 48,
        height: isMain ? 56 : 48,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(
          _getFloatingToolIcon(tool.type),
          size: isMain ? 28 : 24,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  IconData _getFloatingToolIcon(ToolType type) {
    switch (type) {
      case ToolType.pencil:
        return Icons.edit;
      case ToolType.brush:
        return Icons.brush;
      case ToolType.eraser:
        return Icons.auto_fix_normal;
      case ToolType.bucketFill:
        return Icons.format_color_fill;
      case ToolType.eyedropper:
        return Icons.colorize;
      case ToolType.line:
        return Icons.timeline;
      case ToolType.rectangle:
        return Icons.rectangle_outlined;
      case ToolType.circle:
        return Icons.circle_outlined;
      case ToolType.wave:
        return Icons.waves;
    }
  }
}
