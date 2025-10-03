import 'package:flutter/material.dart';
import 'package:painter/features/drawing/screens/drawing_screen.dart';
import 'package:painter/features/coloring/screens/coloring_screen.dart';
import 'package:painter/features/gallery/screens/gallery_screen.dart';
import 'package:painter/features/home/screens/home_screen.dart';
import 'package:painter/shared/models/artwork.dart';
import 'package:painter/shared/models/coloring_page.dart';
import 'package:painter/shared/models/coloring_progress.dart';

/// Navigation routing configuration for the Paint Vibes app
/// Handles screen transitions and route management
class AppRoutes {
  static const String home = '/';
  static const String drawing = '/drawing';
  static const String coloring = '/coloring';
  static const String gallery = '/gallery';
  static const String artworkViewer = '/artwork-viewer';
  static const String coloringPageViewer = '/coloring-page-viewer';

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen(), settings);

      case drawing:
        // TODO: Add support for loading existing artwork
        return _buildRoute(const DrawingScreen(), settings);

      case coloring:
        final args = settings.arguments as ColoringScreenArgs?;
        return _buildRoute(
          ColoringScreen(coloringPage: args?.coloringPage, existingProgress: args?.existingProgress),
          settings,
        );

      case gallery:
        return _buildRoute(const GalleryScreen(), settings);

      case artworkViewer:
        final args = settings.arguments as ArtworkViewerArgs?;
        if (args?.artwork == null) {
          return _buildErrorRoute('Artwork not provided', settings);
        }
        return _buildRoute(ArtworkViewerScreen(artwork: args!.artwork), settings);

      case coloringPageViewer:
        final args = settings.arguments as ColoringPageViewerArgs?;
        if (args?.coloringPage == null) {
          return _buildErrorRoute('Coloring page not provided', settings);
        }
        return _buildRoute(ColoringPageViewerScreen(coloringPage: args!.coloringPage), settings);

      default:
        return _buildErrorRoute('Route not found: ${settings.name}', settings);
    }
  }

  /// Build a route with custom transition
  static PageRoute<dynamic> _buildRoute(Widget screen, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use slide transition for screen changes
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

        return SlideTransition(position: tween.animate(curvedAnimation), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Build error route for invalid navigation
  static Route<dynamic> _buildErrorRoute(String message, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed(home),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation helper class for easy route management
class AppNavigator {
  /// Navigate to home screen
  static Future<void> toHome(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  /// Navigate to drawing screen
  static Future<void> toDrawing(BuildContext context, {Artwork? existingArtwork}) {
    // TODO: Support existingArtwork parameter when DrawingScreen is updated
    return Navigator.of(context).pushNamed(AppRoutes.drawing);
  }

  /// Navigate to coloring screen
  static Future<void> toColoring(
    BuildContext context, {
    ColoringPage? coloringPage,
    ColoringProgress? existingProgress,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.coloring,
      arguments: ColoringScreenArgs(coloringPage: coloringPage, existingProgress: existingProgress),
    );
  }

  /// Navigate to gallery screen
  static Future<void> toGallery(BuildContext context) {
    return Navigator.of(context).pushNamed(AppRoutes.gallery);
  }

  /// Navigate to artwork viewer
  static Future<void> toArtworkViewer(BuildContext context, Artwork artwork) {
    return Navigator.of(context).pushNamed(AppRoutes.artworkViewer, arguments: ArtworkViewerArgs(artwork: artwork));
  }

  /// Navigate to coloring page viewer
  static Future<void> toColoringPageViewer(BuildContext context, ColoringPage coloringPage) {
    return Navigator.of(
      context,
    ).pushNamed(AppRoutes.coloringPageViewer, arguments: ColoringPageViewerArgs(coloringPage: coloringPage));
  }

  /// Pop current screen
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  /// Pop until home screen
  static void popToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.home);
  }

  /// Replace current screen
  static Future<void> replace(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

/// Route arguments classes

class DrawingScreenArgs {
  final Artwork? existingArtwork;

  DrawingScreenArgs({this.existingArtwork});
}

class ColoringScreenArgs {
  final ColoringPage? coloringPage;
  final ColoringProgress? existingProgress;

  ColoringScreenArgs({this.coloringPage, this.existingProgress});
}

class ArtworkViewerArgs {
  final Artwork artwork;

  ArtworkViewerArgs({required this.artwork});
}

class ColoringPageViewerArgs {
  final ColoringPage coloringPage;

  ColoringPageViewerArgs({required this.coloringPage});
}

/// Artwork viewer screen for displaying full artwork details
class ArtworkViewerScreen extends StatelessWidget {
  final Artwork artwork;

  const ArtworkViewerScreen({super.key, required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artwork.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => AppNavigator.toDrawing(context, existingArtwork: artwork),
            tooltip: 'Edit Artwork',
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () => _shareArtwork(context), tooltip: 'Share Artwork'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork image
            if (artwork.fullImagePath.isNotEmpty)
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    artwork.fullImagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Artwork details
            Text('Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Created', _formatDate(artwork.createdAt)),
            _buildDetailRow(context, 'Modified', _formatDate(artwork.lastModified)),
            _buildDetailRow(context, 'Stroke Count', '${artwork.strokeCount}'),
            _buildDetailRow(
              context,
              'Size',
              '${artwork.originalSize.width.toInt()} x ${artwork.originalSize.height.toInt()}',
            ),
            _buildDetailRow(context, 'Status', artwork.isCompleted ? 'Completed' : 'In Progress'),

            if (artwork.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Description', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(artwork.description, style: Theme.of(context).textTheme.bodyMedium),
            ],

            if (artwork.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Tags', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: artwork.tags.map((tag) => Chip(label: Text(tag), backgroundColor: Colors.blue[50])).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareArtwork(BuildContext context) {
    // TODO: Implement artwork sharing
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing feature coming soon!')));
  }
}

/// Coloring page viewer screen for displaying page details
class ColoringPageViewerScreen extends StatelessWidget {
  final ColoringPage coloringPage;

  const ColoringPageViewerScreen({super.key, required this.coloringPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coloringPage.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => AppNavigator.toColoring(context, coloringPage: coloringPage),
            tooltip: 'Start Coloring',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coloring page preview
            if (coloringPage.thumbnailPath.isNotEmpty)
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(coloringPage.thumbnailPath, fit: BoxFit.contain),
                ),
              ),
            const SizedBox(height: 24),

            // Page details
            Text('Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Category', coloringPage.category),
            _buildDetailRow(context, 'Difficulty', _getDifficultyText(coloringPage.difficulty)),
            _buildDetailRow(context, 'Completed', '${coloringPage.completionCount} times'),

            if (coloringPage.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Description', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(coloringPage.description, style: Theme.of(context).textTheme.bodyMedium),
            ],

            // Start coloring button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => AppNavigator.toColoring(context, coloringPage: coloringPage),
                icon: const Icon(Icons.palette),
                label: const Text('Start Coloring'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
