import 'package:flutter/material.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';

/// Widget for displaying and interacting with a coloring page
class ColoringPageWidget extends StatefulWidget {
  final ColoringPage? coloringPage;
  final ColoringProgress? progress;
  final Function(Offset, Color)? onColorApplied;
  final Color currentColor;
  final bool enabled;

  const ColoringPageWidget({
    super.key,
    this.coloringPage,
    this.progress,
    this.onColorApplied,
    this.currentColor = Colors.black,
    this.enabled = true,
  });

  @override
  State<ColoringPageWidget> createState() => _ColoringPageWidgetState();
}

class _ColoringPageWidgetState extends State<ColoringPageWidget> {
  @override
  Widget build(BuildContext context) {
    final coloringPage = widget.coloringPage;

    if (coloringPage == null) {
      return const Center(child: Text('No coloring page loaded'));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTapDown: widget.enabled
            ? (details) {
                final offset = details.localPosition;
                widget.onColorApplied?.call(offset, widget.currentColor);
              }
            : null,
        child: Stack(
          children: [
            // Background outline
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: coloringPage.outlinePath.isNotEmpty
                  ? Image.asset(
                      coloringPage.outlinePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                    )
                  : const Center(child: Icon(Icons.palette, size: 64)),
            ),

            // Progress overlay (if exists)
            if (widget.progress != null && widget.progress!.progressImagePath.isNotEmpty)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Image.asset(
                  widget.progress!.progressImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),

            // Progress indicator
            if (widget.progress != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${(widget.progress!.completionPercent * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
