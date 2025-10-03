import 'package:flutter/material.dart';
import 'package:painter/shared/models/artwork.dart';

/// Widget for displaying artwork thumbnails in a grid layout
class GalleryGrid extends StatelessWidget {
  final List<Artwork>? artworks;
  final Function(String)? onArtworkSelected;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const GalleryGrid({
    super.key,
    this.artworks,
    this.onArtworkSelected,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final displayArtworks = artworks ?? [];

    if (displayArtworks.isEmpty) {
      return const Center(child: Text('No artworks to display'));
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: displayArtworks.length,
        itemBuilder: (context, index) {
          final artwork = displayArtworks[index];
          return GestureDetector(
            onTap: () => onArtworkSelected?.call(artwork.id),
            child: Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        color: Colors.grey[200],
                      ),
                      child: artwork.thumbnailPath.isNotEmpty
                          ? Image.asset(
                              artwork.thumbnailPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      artwork.title,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
