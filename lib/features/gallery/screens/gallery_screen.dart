import 'package:flutter/material.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/user_gallery.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/core/services/i_settings_service.dart';

/// Screen for displaying user's artwork collection
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  UserGallery? _gallery;
  List<Artwork> _artworks = [];
  List<Artwork> _filteredArtworks = [];
  String _searchQuery = '';
  GalleryViewMode _viewMode = GalleryViewMode.grid;
  GallerySortOrder _sortOrder = GallerySortOrder.dateModified;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from actual storage service
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    // Sample artworks for now
    _artworks = _generateSampleArtworks();
    _filteredArtworks = _artworks;

    setState(() {
      _isLoading = false;
    });
  }

  List<Artwork> _generateSampleArtworks() {
    final now = DateTime.now();
    return [
      Artwork(
        id: 'art1',
        title: 'Mountain Sunrise',
        description: 'A breathtaking sunrise over snow-capped mountains',
        thumbnailPath: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop',
        canvasDataPath: 'assets/data/sunrise.json',
        createdAt: now.subtract(const Duration(days: 5)),
        lastModified: now.subtract(const Duration(days: 2)),
        originalSize: const Size(800, 600),
        tags: ['landscape', 'sunrise', 'mountains', 'nature'],
        isCompleted: true,
        strokeCount: 45,
      ),
      Artwork(
        id: 'art2',
        title: 'Urban Street Art',
        description: 'Vibrant graffiti-style urban artwork',
        thumbnailPath: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=600&h=800&fit=crop',
        canvasDataPath: 'assets/data/urban.json',
        createdAt: now.subtract(const Duration(days: 10)),
        lastModified: now.subtract(const Duration(days: 7)),
        originalSize: const Size(600, 800),
        tags: ['urban', 'colorful', 'street-art', 'graffiti'],
        isCompleted: true,
        strokeCount: 67,
      ),
      Artwork(
        id: 'art3',
        title: 'Abstract Ocean Waves',
        description: 'Flowing abstract representation of ocean waves',
        thumbnailPath: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600&h=400&fit=crop',
        canvasDataPath: 'assets/data/waves.json',
        createdAt: now.subtract(const Duration(days: 3)),
        lastModified: now.subtract(const Duration(days: 1)),
        originalSize: const Size(600, 400),
        tags: ['abstract', 'ocean', 'waves', 'blue'],
        isCompleted: true,
        strokeCount: 38,
      ),
      Artwork(
        id: 'art4',
        title: 'Forest Path Sketch',
        description: 'Work in progress - peaceful forest walking path',
        thumbnailPath: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=600&fit=crop',
        canvasDataPath: 'assets/data/forest.json',
        createdAt: now.subtract(const Duration(days: 1)),
        lastModified: now.subtract(const Duration(hours: 2)),
        originalSize: const Size(400, 600),
        tags: ['nature', 'forest', 'sketch', 'work-in-progress'],
        isCompleted: false,
        strokeCount: 23,
      ),
      Artwork(
        id: 'art5',
        title: 'Watercolor Flowers',
        description: 'Delicate watercolor-style floral painting',
        thumbnailPath: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=500&h=700&fit=crop',
        canvasDataPath: 'assets/data/flowers.json',
        createdAt: now.subtract(const Duration(days: 8)),
        lastModified: now.subtract(const Duration(days: 6)),
        originalSize: const Size(500, 700),
        tags: ['floral', 'watercolor', 'delicate', 'pink'],
        isCompleted: true,
        strokeCount: 89,
      ),
      Artwork(
        id: 'art6',
        title: 'Digital Portrait',
        description: 'Modern digital portrait with vibrant colors',
        thumbnailPath: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=200&h=200&fit=crop',
        fullImagePath: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=500&fit=crop',
        canvasDataPath: 'assets/data/portrait.json',
        createdAt: now.subtract(const Duration(days: 15)),
        lastModified: now.subtract(const Duration(days: 12)),
        originalSize: const Size(400, 500),
        tags: ['portrait', 'digital', 'face', 'colorful'],
        isCompleted: true,
        strokeCount: 156,
      ),
    ];
  }

  void _filterArtworks() {
    setState(() {
      _filteredArtworks = _artworks.where((artwork) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            artwork.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artwork.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
        return matchesSearch;
      }).toList();

      _sortArtworks();
    });
  }

  void _sortArtworks() {
    _filteredArtworks.sort((a, b) {
      switch (_sortOrder) {
        case GallerySortOrder.dateCreated:
          return b.createdAt.compareTo(a.createdAt);
        case GallerySortOrder.dateModified:
          return b.lastModified.compareTo(a.lastModified);
        case GallerySortOrder.title:
          return a.title.compareTo(b.title);
        case GallerySortOrder.strokeCount:
          return b.strokeCount.compareTo(a.strokeCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () => _showSortMenu(), icon: const Icon(Icons.sort), tooltip: 'Sort'),
          IconButton(
            onPressed: () => _toggleViewMode(),
            icon: Icon(_viewMode == GalleryViewMode.grid ? Icons.list : Icons.grid_view),
            tooltip: _viewMode == GalleryViewMode.grid ? 'List View' : 'Grid View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (query) {
                _searchQuery = query;
                _filterArtworks();
              },
              decoration: InputDecoration(
                hintText: 'Search artworks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Content
          Expanded(child: _isLoading ? _buildLoadingView() : _buildGalleryContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewArtwork(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildGalleryContent() {
    if (_filteredArtworks.isEmpty) {
      return _buildEmptyState();
    }

    return _viewMode == GalleryViewMode.grid ? _buildGridView() : _buildListView();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No artworks yet' : 'No artworks match your search',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'Start creating your first masterpiece!' : 'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewArtwork,
              icon: const Icon(Icons.add),
              label: const Text('Create Artwork'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredArtworks.length,
      itemBuilder: (context, index) {
        final artwork = _filteredArtworks[index];
        return _buildArtworkCard(artwork);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredArtworks.length,
      itemBuilder: (context, index) {
        final artwork = _filteredArtworks[index];
        return _buildArtworkListItem(artwork);
      },
    );
  }

  Widget _buildArtworkCard(Artwork artwork) {
    return GestureDetector(
      onTap: () => _openArtwork(artwork),
      onLongPress: () => _showArtworkOptions(artwork),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Artwork thumbnail
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: artwork.thumbnailPath.isNotEmpty
                          ? Image.asset(
                              artwork.thumbnailPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, size: 48, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.palette, size: 48, color: Colors.grey),
                    ),
                    if (!artwork.isCompleted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'WIP',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Artwork info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(_formatDate(artwork.lastModified), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${artwork.strokeCount} strokes', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
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

  Widget _buildArtworkListItem(Artwork artwork) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
          child: artwork.thumbnailPath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    artwork.thumbnailPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.palette, color: Colors.grey),
        ),
        title: Text(artwork.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(artwork.lastModified)),
            Text('${artwork.strokeCount} strokes'),
            if (artwork.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: artwork.tags
                    .take(3)
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleArtworkAction(artwork, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Row(children: [Icon(Icons.open_in_new), SizedBox(width: 8), Text('Open')]),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(children: [Icon(Icons.share), SizedBox(width: 8), Text('Share')]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _openArtwork(artwork),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == GalleryViewMode.grid ? GalleryViewMode.list : GalleryViewMode.grid;
    });
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...GallerySortOrder.values.map(
              (order) => ListTile(
                leading: Radio<GallerySortOrder>(
                  value: order,
                  groupValue: _sortOrder,
                  onChanged: (value) {
                    setState(() {
                      _sortOrder = value!;
                      _filterArtworks();
                    });
                    Navigator.pop(context);
                  },
                ),
                title: Text(_getSortOrderName(order)),
                onTap: () {
                  setState(() {
                    _sortOrder = order;
                    _filterArtworks();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortOrderName(GallerySortOrder order) {
    switch (order) {
      case GallerySortOrder.dateCreated:
        return 'Date Created';
      case GallerySortOrder.dateModified:
        return 'Last Modified';
      case GallerySortOrder.title:
        return 'Title';
      case GallerySortOrder.strokeCount:
        return 'Stroke Count';
    }
  }

  void _createNewArtwork() {
    // TODO: Navigate to drawing screen
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening drawing screen...')));
  }

  void _openArtwork(Artwork artwork) {
    // TODO: Navigate to drawing screen with artwork
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${artwork.title}...')));
  }

  void _showArtworkOptions(Artwork artwork) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(context);
                _openArtwork(artwork);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _handleArtworkAction(artwork, 'share');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _handleArtworkAction(artwork, 'rename');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleArtworkAction(artwork, 'delete');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleArtworkAction(Artwork artwork, String action) {
    switch (action) {
      case 'open':
        _openArtwork(artwork);
        break;
      case 'share':
        // TODO: Implement sharing
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sharing ${artwork.title}...')));
        break;
      case 'rename':
        _showRenameDialog(artwork);
        break;
      case 'delete':
        _showDeleteConfirmation(artwork);
        break;
    }
  }

  void _showRenameDialog(Artwork artwork) {
    final controller = TextEditingController(text: artwork.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Artwork'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: Update artwork title
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artwork renamed!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Artwork artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: Text('Are you sure you want to delete "${artwork.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: Delete artwork
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Artwork deleted!'), backgroundColor: Colors.red));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
