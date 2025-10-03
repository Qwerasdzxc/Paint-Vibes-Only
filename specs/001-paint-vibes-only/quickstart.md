# Quickstart Guide: Paint Vibes Only

**Phase 1**: Development Setup & Validation  
**Date**: 25 September 2025

## Prerequisites

Before starting development, ensure you have:

- **Flutter SDK**: Version 3.13+ installed
- **Dart SDK**: Version 3.1+ (included with Flutter)
- **IDE**: VS Code with Flutter extension or Android Studio
- **Platform Tools**: 
  - Xcode 14+ (for iOS development)
  - Android Studio with API 21+ SDK (for Android development)
- **Git**: For version control

## Quick Setup (5 minutes)

### 1. Clone and Initialize Project

```bash
# Clone the repository
git clone <repository-url> painter
cd painter

# Verify Flutter installation
flutter doctor -v

# Get dependencies
flutter pub get

# Generate required files (if any)
dart run build_runner build
```

### 2. Run the App

```bash
# List available devices
flutter devices

# Run on connected device or emulator
flutter run

# Or run on specific device
flutter run -d <device-id>

# For web development (optional)
flutter run -d chrome
```

### 3. Verify Core Features (2-minute test)

Once the app launches, quickly verify:

1. **Drawing Canvas**: 
   - Tap and drag to draw strokes
   - Verify strokes appear in real-time
   
2. **Color Selection**:
   - Tap different colors in palette
   - Verify next strokes use new color
   
3. **Undo/Redo**:
   - Draw some strokes
   - Tap undo button - last stroke should disappear
   - Tap redo button - stroke should reappear
   
4. **Save Functionality**:
   - Create a simple drawing
   - Tap save button
   - Verify success confirmation

## Development Workflow

### Daily Development Cycle

```bash
# 1. Start development server
flutter run --hot-reload

# 2. Make code changes
# Files auto-reload on save

# 3. Run tests frequently
flutter test

# 4. Check code quality
flutter analyze

# 5. Format code
dart format .

# 6. Run full test suite before commits
flutter test --coverage
```

### Testing Commands

```bash
# Unit tests only
flutter test test/unit/

# Widget tests only  
flutter test test/widget/

# Integration tests (requires device/simulator)
flutter test integration_test/

# Test with coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Golden file tests
flutter test --update-goldens
```

## Project Structure Overview

```
lib/
├── main.dart                 # App entry point
├── app/                     # App-level configuration
│   ├── app.dart            # Main app widget
│   ├── theme.dart          # App theming
│   └── routes.dart         # Navigation routes
├── features/               # Feature modules
│   ├── drawing/           # Drawing functionality
│   │   ├── models/        # Drawing data models
│   │   ├── services/      # Drawing business logic
│   │   ├── widgets/       # Drawing UI components
│   │   └── screens/       # Drawing screens
│   ├── coloring/          # Coloring functionality
│   │   ├── models/        # Coloring data models
│   │   ├── services/      # Coloring business logic
│   │   ├── widgets/       # Coloring UI components
│   │   └── screens/       # Coloring screens
│   └── gallery/           # Gallery functionality
│       ├── models/        # Gallery data models
│       ├── services/      # Gallery business logic
│       ├── widgets/       # Gallery UI components
│       └── screens/       # Gallery screens
├── shared/                # Shared utilities
│   ├── models/           # Common data models
│   ├── services/         # Common services
│   ├── widgets/          # Reusable UI components
│   └── utils/            # Utility functions
└── core/                 # Core infrastructure
    ├── storage/          # File and data storage
    ├── navigation/       # Navigation utilities
    └── dependency_injection/ # DI setup

test/
├── unit/                 # Unit tests
├── widget/               # Widget tests
├── integration/          # Integration tests
└── helpers/              # Test utilities

integration_test/
└── app_test.dart         # Full app integration tests
```

## Key Development Files

### Essential Files to Start With

1. **`lib/main.dart`** - App entry point and initialization
2. **`lib/features/drawing/screens/drawing_screen.dart`** - Main drawing interface
3. **`lib/features/drawing/widgets/drawing_canvas.dart`** - Core drawing widget
4. **`lib/features/drawing/services/drawing_service.dart`** - Drawing business logic
5. **`lib/shared/models/drawing_canvas.dart`** - Canvas data model

### Configuration Files

1. **`pubspec.yaml`** - Dependencies and assets
2. **`analysis_options.yaml`** - Code analysis rules
3. **`test/flutter_test_config.dart`** - Test configuration

## Feature Development Guidelines

### 1. Drawing Feature Implementation

```dart
// Example: Adding a new drawing tool
class NewDrawingTool implements DrawingTool {
  @override
  ToolType get type => ToolType.newTool;
  
  @override
  void render(Canvas canvas, DrawingStroke stroke) {
    // Implement tool-specific rendering
  }
  
  @override
  DrawingStroke createStroke(List<Offset> points) {
    // Create stroke with tool-specific properties
    return DrawingStroke(
      tool: this,
      points: points,
      // ... other properties
    );
  }
}
```

### 2. Adding New Colors

```dart
// Add predefined colors in lib/shared/constants/colors.dart
class AppColors {
  static const List<Color> predefinedPalette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    // Add new colors here
  ];
}
```

### 3. Creating Custom Widgets

```dart
// Follow this pattern for new drawing widgets
class CustomDrawingWidget extends StatelessWidget {
  const CustomDrawingWidget({
    Key? key,
    required this.onDrawingUpdated,
  }) : super(key: key);
  
  final VoidCallback onDrawingUpdated;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget implementation
    );
  }
}
```

## Testing Strategy

### Unit Tests Example

```dart
// test/unit/drawing_service_test.dart
void main() {
  group('DrawingService', () {
    late DrawingService service;
    
    setUp(() {
      service = DrawingService();
    });
    
    test('should create empty canvas with correct dimensions', () async {
      final canvas = await service.createCanvas(Size(800, 600));
      
      expect(canvas.dimensions, equals(Size(800, 600)));
      expect(canvas.strokes, isEmpty);
    });
  });
}
```

### Widget Tests Example

```dart
// test/widget/drawing_canvas_test.dart
void main() {
  testWidgets('DrawingCanvas should respond to tap gestures', (tester) async {
    bool strokeAdded = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: DrawingCanvas(
          onStrokeAdded: (_) => strokeAdded = true,
        ),
      ),
    );
    
    await tester.tap(find.byType(DrawingCanvas));
    await tester.pumpAndSettle();
    
    expect(strokeAdded, isTrue);
  });
}
```

## Performance Monitoring

### Key Metrics to Track

```dart
// Add performance monitoring in debug builds
void trackDrawingPerformance() {
  final stopwatch = Stopwatch()..start();
  
  // Perform drawing operation
  
  stopwatch.stop();
  print('Drawing operation took: ${stopwatch.elapsedMilliseconds}ms');
  
  // Assert performance requirements
  assert(stopwatch.elapsedMilliseconds < 50, 'Drawing too slow');
}
```

### Memory Monitoring

```dart
// Monitor memory usage during development
void checkMemoryUsage() {
  final usage = ProcessInfo.currentRss;
  print('Current memory usage: ${usage / 1024 / 1024} MB');
  
  // Alert if memory usage is too high
  assert(usage < 500 * 1024 * 1024, 'Memory usage too high');
}
```

## Common Development Tasks

### Adding a New Drawing Tool

1. Define tool type in `ToolType` enum
2. Create tool class implementing `DrawingTool`
3. Add tool configuration to `ToolRegistry`
4. Update UI to show new tool icon
5. Write unit tests for tool behavior
6. Update documentation

### Adding New Color Features

1. Update `ColorPalette` model if needed
2. Implement color logic in `ColorService`
3. Update color picker UI components
4. Add color validation and conversion utilities
5. Write tests for color operations
6. Update user documentation

### Implementing Save/Load Features

1. Define file format and structure
2. Implement serialization/deserialization
3. Update `FileService` with new operations
4. Add error handling and validation
5. Write integration tests for file operations
6. Test cross-platform compatibility

## Troubleshooting

### Common Issues

1. **Hot reload not working**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Build errors after dependency changes**:
   ```bash
   flutter clean
   flutter pub deps
   flutter pub get
   ```

3. **iOS build issues**:
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   flutter run
   ```

4. **Android build issues**:
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter run
   ```

### Performance Issues

1. **Slow drawing response**:
   - Check canvas rendering optimization
   - Verify stroke data structure efficiency
   - Monitor memory allocations during drawing

2. **High memory usage**:
   - Review image caching strategy
   - Check for memory leaks in drawing operations
   - Optimize stroke data storage

## Next Steps

After completing quickstart setup:

1. **Review Architecture**: Read through `data-model.md` and `service-contracts.md`
2. **Start Implementation**: Begin with core drawing canvas functionality
3. **Follow TDD**: Write tests first, then implement features
4. **Regular Testing**: Run integration tests frequently to catch issues early
5. **Performance Testing**: Monitor key metrics throughout development

## Success Criteria

The quickstart is successful when you can:
- ✅ Run the app on target devices
- ✅ Draw strokes that appear in real-time  
- ✅ Change colors and see immediate effect
- ✅ Undo/redo operations work correctly
- ✅ Save functionality completes without errors
- ✅ All tests pass
- ✅ Code analysis shows no critical issues

This quickstart provides the foundation for efficient development and testing of the Paint Vibes Only drawing app.