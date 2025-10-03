import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for undo/redo controls with history management
class UndoRedoControls extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onClear;
  final bool canUndo;
  final bool canRedo;
  final int? historyCount;
  final bool showClear;
  final bool compact;
  final String? undoTooltip;
  final String? redoTooltip;
  final String? clearTooltip;

  const UndoRedoControls({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onClear,
    this.canUndo = false,
    this.canRedo = false,
    this.historyCount,
    this.showClear = false,
    this.compact = false,
    this.undoTooltip = 'Undo',
    this.redoTooltip = 'Redo',
    this.clearTooltip = 'Clear All',
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactControls(context);
    } else {
      return _buildStandardControls(context);
    }
  }

  Widget _buildStandardControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Undo button
          _buildControlButton(
            context: context,
            icon: Icons.undo,
            onPressed: canUndo ? onUndo : null,
            tooltip: undoTooltip!,
          ),

          const SizedBox(width: 8),

          // Redo button
          _buildControlButton(
            context: context,
            icon: Icons.redo,
            onPressed: canRedo ? onRedo : null,
            tooltip: redoTooltip!,
          ),

          // Clear button
          if (showClear) ...[
            const SizedBox(width: 8),
            const VerticalDivider(width: 16),
            const SizedBox(width: 8),
            _buildControlButton(
              context: context,
              icon: Icons.clear_all,
              onPressed: onClear,
              tooltip: clearTooltip!,
              isDestructive: true,
            ),
          ],

          // History count
          if (historyCount != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Text(
                '$historyCount steps',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Undo button
          _buildCompactButton(context: context, icon: Icons.undo, onPressed: canUndo ? onUndo : null),

          const SizedBox(width: 4),

          // Redo button
          _buildCompactButton(context: context, icon: Icons.redo, onPressed: canRedo ? onRedo : null),

          // Clear button
          if (showClear) ...[
            const SizedBox(width: 4),
            _buildCompactButton(context: context, icon: Icons.clear_all, onPressed: onClear, isDestructive: true),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isDestructive = false,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEnabled ? (isDestructive ? Colors.red[50] : Colors.grey[50]) : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? (isDestructive ? Colors.red[600] : Colors.grey[700]) : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled ? (isDestructive ? Colors.red[100] : Colors.grey[100]) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? (isDestructive ? Colors.red[600] : Colors.grey[700]) : Colors.grey[300],
        ),
      ),
    );
  }
}

/// Advanced undo/redo controls with history preview
class AdvancedUndoRedoControls extends StatefulWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onClear;
  final bool canUndo;
  final bool canRedo;
  final List<String> historyActions;
  final int currentHistoryIndex;
  final ValueChanged<int>? onHistoryJump;

  const AdvancedUndoRedoControls({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onClear,
    this.canUndo = false,
    this.canRedo = false,
    this.historyActions = const [],
    this.currentHistoryIndex = -1,
    this.onHistoryJump,
  });

  @override
  State<AdvancedUndoRedoControls> createState() => _AdvancedUndoRedoControlsState();
}

class _AdvancedUndoRedoControlsState extends State<AdvancedUndoRedoControls> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // History preview
        if (_showHistory && widget.historyActions.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: _buildHistoryList(),
          ),
        ],

        // Main controls
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Standard controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAdvancedButton(
                    icon: Icons.undo,
                    label: 'Undo',
                    onPressed: widget.canUndo ? widget.onUndo : null,
                  ),
                  const SizedBox(width: 12),
                  _buildAdvancedButton(
                    icon: Icons.redo,
                    label: 'Redo',
                    onPressed: widget.canRedo ? widget.onRedo : null,
                  ),
                  const SizedBox(width: 12),
                  _buildAdvancedButton(
                    icon: Icons.clear_all,
                    label: 'Clear',
                    onPressed: widget.onClear,
                    isDestructive: true,
                  ),
                ],
              ),

              // History toggle
              if (widget.historyActions.isNotEmpty) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_showHistory ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'History (${widget.historyActions.length})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.historyActions.length,
      itemBuilder: (context, index) {
        final isCurrent = index == widget.currentHistoryIndex;
        final action = widget.historyActions[index];

        return GestureDetector(
          onTap: widget.onHistoryJump != null ? () => widget.onHistoryJump!(index) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.blue[50] : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isCurrent ? Border.all(color: Colors.blue[200]!) : null,
            ),
            child: Row(
              children: [
                Icon(_getActionIcon(action), size: 16, color: isCurrent ? Colors.blue[600] : Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrent ? Colors.blue[600] : Colors.grey[700],
                      fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrent) Icon(Icons.arrow_back, size: 16, color: Colors.blue[600]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? (isDestructive ? Colors.red[50] : Colors.grey[50]) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? (isDestructive ? Colors.red[200]! : Colors.grey[200]!) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isEnabled ? (isDestructive ? Colors.red[600] : Colors.grey[700]) : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isEnabled ? (isDestructive ? Colors.red[600] : Colors.grey[700]) : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.toLowerCase().contains('draw')) {
      return Icons.edit;
    } else if (action.toLowerCase().contains('erase')) {
      return Icons.auto_fix_normal;
    } else if (action.toLowerCase().contains('color')) {
      return Icons.palette;
    } else if (action.toLowerCase().contains('clear')) {
      return Icons.clear_all;
    } else {
      return Icons.circle;
    }
  }
}

/// Floating undo/redo controls
class FloatingUndoRedoControls extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  const FloatingUndoRedoControls({super.key, this.onUndo, this.onRedo, this.canUndo = false, this.canRedo = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Undo button
        if (canUndo)
          FloatingActionButton.small(
            heroTag: "undo",
            onPressed: onUndo,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            child: const Icon(Icons.undo),
          ),

        if (canUndo && canRedo) const SizedBox(height: 8),

        // Redo button
        if (canRedo)
          FloatingActionButton.small(
            heroTag: "redo",
            onPressed: onRedo,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            child: const Icon(Icons.redo),
          ),
      ],
    );
  }
}

/// Keyboard shortcut handler for undo/redo operations
class UndoRedoShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const UndoRedoShortcuts({super.key, required this.child, this.onUndo, this.onRedo});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ): const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ): const RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyY): const RedoIntent(),
      },
      child: Actions(
        actions: {
          UndoIntent: CallbackAction<UndoIntent>(onInvoke: (intent) => onUndo?.call()),
          RedoIntent: CallbackAction<RedoIntent>(onInvoke: (intent) => onRedo?.call()),
        },
        child: child,
      ),
    );
  }
}

/// Undo intent for keyboard shortcuts
class UndoIntent extends Intent {
  const UndoIntent();
}

/// Redo intent for keyboard shortcuts
class RedoIntent extends Intent {
  const RedoIntent();
}
