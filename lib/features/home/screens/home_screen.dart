import 'package:flutter/material.dart';
import 'package:painter/features/drawing/screens/drawing_screen.dart';
import 'package:painter/features/coloring/screens/coloring_screen.dart';
import 'package:painter/features/gallery/screens/gallery_screen.dart';

/// Main navigation hub with bottom navigation bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeTab(onNavigateToTab: _navigateToTab),
      const DrawingScreen(),
      const ColoringScreen(),
      const GalleryScreen(),
    ];
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(icon: Icons.home, label: 'Home', tooltip: 'Home'),
    NavigationItem(icon: Icons.brush, label: 'Draw', tooltip: 'Free Drawing'),
    NavigationItem(icon: Icons.palette, label: 'Color', tooltip: 'Coloring Pages'),
    NavigationItem(icon: Icons.photo_library, label: 'Gallery', tooltip: 'My Artworks'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label, tooltip: item.tooltip))
            .toList(),
      ),
    );
  }
}

/// Navigation item configuration
class NavigationItem {
  final IconData icon;
  final String label;
  final String tooltip;

  NavigationItem({required this.icon, required this.label, required this.tooltip});
}

/// Home tab content with app overview and quick actions
class _HomeTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const _HomeTab({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Vibes Only'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Paint Vibes!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Express your creativity with our intuitive drawing and coloring tools.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => onNavigateToTab(1), // Drawing screen
                    icon: const Icon(Icons.brush),
                    label: const Text('Start Drawing'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick actions
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _QuickActionCard(
                  icon: Icons.brush,
                  title: 'Free Draw',
                  subtitle: 'Create original artwork',
                  color: Colors.blue,
                  onTap: () => onNavigateToTab(1),
                ),
                _QuickActionCard(
                  icon: Icons.palette,
                  title: 'Color Pages',
                  subtitle: 'Relax with coloring',
                  color: Colors.purple,
                  onTap: () => onNavigateToTab(2),
                ),
                _QuickActionCard(
                  icon: Icons.photo_library,
                  title: 'My Gallery',
                  subtitle: 'View saved artworks',
                  color: Colors.green,
                  onTap: () => onNavigateToTab(3),
                ),
                _QuickActionCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Customize your experience',
                  color: Colors.orange,
                  onTap: () => _showSettings(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Features section
            const Text('Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _FeatureCard(
              icon: Icons.touch_app,
              title: 'Intuitive Drawing',
              description: 'Natural drawing experience with pressure sensitivity and smooth strokes.',
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.color_lens,
              title: 'Rich Color Palette',
              description: 'Choose from a wide range of colors and create custom palettes.',
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.layers,
              title: 'Layered Canvas',
              description: 'Work with multiple layers for complex artwork creation.',
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.undo,
              title: 'Unlimited Undo',
              description: 'Experiment freely with unlimited undo and redo functionality.',
            ),

            const SizedBox(height: 24),

            // Recent activity placeholder
            const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('No recent activity', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    'Start creating to see your recent artworks here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings screen coming soon!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature card widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.indigo, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
